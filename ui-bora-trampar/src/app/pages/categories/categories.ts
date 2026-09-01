import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface CategoryItem {
  id: string;
  name: string;
  icon: string;
  description?: string;
  servicesCount?: number;
  createdAt?: string;
}

@Component({
  selector: 'app-categories',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './categories.html',
  styleUrl: './categories.css'
})
export class Categories implements OnInit {
  isLoading = false;
  isSaving = false;
  searchQuery = '';

  isModalOpen = false;
  isDeleteModalOpen = false;
  modalMode: 'create' | 'edit' = 'create';

  formData: CategoryItem = {
    id: '',
    name: '',
    icon: 'fa-hammer',
    description: ''
  };

  categoryToDelete: CategoryItem | null = null;

  availableIcons = [
    { label: 'Construção', value: 'fa-hammer' },
    { label: 'Pintura', value: 'fa-paint-roller' },
    { label: 'Eletricista', value: 'fa-bolt' },
    { label: 'Encanamento', value: 'fa-faucet-drip' },
    { label: 'Limpeza', value: 'fa-broom' },
    { label: 'Jardinagem', value: 'fa-seedling' },
    { label: 'Montagem', value: 'fa-screwdriver-wrench' },
    { label: 'Cuidados', value: 'fa-heart' },
    { label: 'Geral', value: 'fa-layer-group' }
  ];

  categories: CategoryItem[] = [];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadCategories();
  }

  async loadCategories() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const response = await api.get('/api/categories');
      const resObj = response.data?.result || response.data?.data || response.data;
      const list = Array.isArray(resObj) ? resObj : (Array.isArray(resObj?.data) ? resObj.data : []);

      this.categories = list.map((cat: any) => ({
        id: cat.id || cat._id,
        name: cat.name,
        icon: cat.icon || 'fa-layer-group',
        description: cat.description || '',
        servicesCount: cat.servicesCount || 0,
        createdAt: cat.createdAt || cat.created_at || new Date().toISOString()
      }));
    } catch {
      this.categories = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): CategoryItem[] {
    return this.categories.filter(c =>
      !this.searchQuery ||
      c.name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
      (c.description && c.description.toLowerCase().includes(this.searchQuery.toLowerCase()))
    );
  }

  openCreateModal() {
    this.modalMode = 'create';
    this.formData = {
      id: '',
      name: '',
      icon: 'fa-hammer',
      description: ''
    };
    this.isModalOpen = true;
  }

  openEditModal(item: CategoryItem) {
    this.modalMode = 'edit';
    this.formData = { ...item };
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }

  async saveCategory() {
    if (!this.formData.name.trim()) {
      this.toastr.warning('O nome da categoria é obrigatório.');
      return;
    }

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      if (this.modalMode === 'create') {
        const payload = {
          name: this.formData.name,
          icon: this.formData.icon,
          description: this.formData.description
        };

        await api.post('/api/categories', payload);
        this.toastr.success('Categoria criada com sucesso!');
      } else {
        const payload = {
          id: this.formData.id,
          name: this.formData.name,
          icon: this.formData.icon,
          description: this.formData.description
        };

        await api.put('/api/categories', payload);
        this.toastr.success('Categoria atualizada com sucesso!');
      }

      this.closeModal();
      await this.loadCategories();
    } catch (err: any) {
      const msg = err.response?.data?.message || 'Erro ao salvar categoria.';
      this.toastr.error(msg);
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }

  confirmDelete(item: CategoryItem) {
    this.categoryToDelete = item;
    this.isDeleteModalOpen = true;
  }

  closeDeleteModal() {
    this.isDeleteModalOpen = false;
    this.categoryToDelete = null;
  }

  async executeDelete() {
    if (!this.categoryToDelete) return;

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      await api.delete(`/api/categories/${this.categoryToDelete.id}`);
      this.toastr.success('Categoria removida com sucesso!');
      this.closeDeleteModal();
      await this.loadCategories();
    } catch {
      this.toastr.error('Erro ao excluir categoria.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }
}
