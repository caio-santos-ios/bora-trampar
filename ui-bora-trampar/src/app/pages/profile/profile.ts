import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Auth, UserSession } from '../../services/auth';
import { api } from '../../services/api';
import { Loading } from '../../components/loading/loading';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './profile.html',
  styleUrl: './profile.css'
})
export class Profile implements OnInit {
  isLoading = false;
  isSaving = false;
  isUploading = false;

  userId = '';
  name = '';
  email = '';
  whatsapp = '';
  photo = '';
  role = 'Administrador';

  constructor(
    private auth: Auth,
    private toastr: ToastrService,
    private cdr: ChangeDetectorRef
  ) {}

  async ngOnInit() {
    await this.loadUserProfile();
  }

  async loadUserProfile() {
    this.isLoading = true;
    this.cdr.detectChanges();

    const sessionUser = this.auth.getUser();
    if (sessionUser) {
      this.userId = sessionUser.id || '';
      this.name = sessionUser.name || '';
      this.email = sessionUser.email || '';
      this.whatsapp = sessionUser.whatsapp || '';
      this.photo = sessionUser.photo || '';
      this.role = sessionUser.role === 'Admin' || sessionUser.role === 'admin' ? 'Administrador' : (sessionUser.role || 'Administrador');
    }

    try {
      const response = await api.get('/api/users/me');
      const u = response.data?.result?.data || response.data?.result || response.data;
      if (u) {
        this.userId = u.id || u._id || this.userId;
        this.name = u.name || this.name;
        this.email = u.email || this.email;
        this.whatsapp = u.whatsApp || u.whatsapp || this.whatsapp;
        this.photo = u.photo || this.photo;
        if (u.role) {
          this.role = u.role === 'Admin' || u.role === 'admin' || u.role === 1 ? 'Administrador' : u.role;
        }

        const updatedSession: UserSession = {
          id: this.userId,
          name: this.name,
          email: this.email,
          whatsapp: this.whatsapp,
          photo: this.photo,
          role: this.role
        };
        this.auth.setUser(updatedSession);
      }
    } catch {
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  async onFileSelected(event: any) {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      this.toastr.warning('Por favor selecione um arquivo de imagem válido.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      this.toastr.warning('A imagem deve ter no máximo 5MB.');
      return;
    }

    this.isUploading = true;
    this.cdr.detectChanges();

    try {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('folder', 'profiles');

      try {
        const uploadRes = await api.post('/api/uploads/image', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        if (uploadRes.data?.url) {
          this.photo = uploadRes.data.url;
          this.toastr.success('Foto carregada com sucesso!');
          this.isUploading = false;
          this.cdr.detectChanges();
          return;
        }
      } catch {}

      const reader = new FileReader();
      reader.onload = async (e: any) => {
        const base64 = e.target.result;
        try {
          const base64Res = await api.post('/api/uploads/base64', {
            base64,
            folder: 'profiles'
          });
          this.photo = base64Res.data?.url || base64;
        } catch {
          this.photo = base64;
        }
        this.toastr.success('Foto carregada!');
        this.isUploading = false;
        this.cdr.detectChanges();
      };
      reader.onerror = () => {
        this.toastr.error('Erro ao ler a imagem.');
        this.isUploading = false;
        this.cdr.detectChanges();
      };
      reader.readAsDataURL(file);
    } catch {
      this.toastr.error('Erro ao processar upload da foto.');
      this.isUploading = false;
      this.cdr.detectChanges();
    }
  }

  removePhoto() {
    this.photo = '';
    this.cdr.detectChanges();
  }

  async saveProfile() {
    if (!this.name.trim()) {
      this.toastr.warning('O nome é obrigatório.');
      return;
    }
    if (!this.email.trim()) {
      this.toastr.warning('O e-mail é obrigatório.');
      return;
    }

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      const payload: any = {
        id: this.userId,
        name: this.name.trim(),
        email: this.email.trim(),
        whatsApp: this.whatsapp?.trim() || '',
        photo: this.photo
      };

      await api.put('/api/users', payload);

      const updatedSession: UserSession = {
        id: this.userId,
        name: this.name,
        email: this.email,
        whatsapp: this.whatsapp,
        photo: this.photo,
        role: this.role
      };
      this.auth.setUser(updatedSession);

      this.toastr.success('Perfil atualizado com sucesso!');
    } catch (err: any) {
      const msg = err.response?.data?.message || err.message || 'Erro ao atualizar perfil.';
      this.toastr.error(msg);
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }
}
