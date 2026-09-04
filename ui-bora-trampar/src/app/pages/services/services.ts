import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface ServiceItem {
  id: string;
  name: string;
  categoryId: string;
  categoryName?: string;
  icon: string;
  createdAt?: string;
}

export interface CategoryRef {
  id: string;
  name: string;
}

@Component({
  selector: 'app-services',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './services.html',
  styleUrl: './services.css'
})
export class Services implements OnInit {
  isLoading = false;
  isSaving = false;
  searchQuery = '';
  selectedCategoryFilter = 'all';

  isModalOpen = false;
  isDeleteModalOpen = false;
  modalMode: 'create' | 'edit' = 'create';

  formData: ServiceItem = {
    id: '',
    name: '',
    categoryId: '',
    icon: 'fa-briefcase'
  };

  serviceToDelete: ServiceItem | null = null;

  categoriesList: CategoryRef[] = [];
  services: ServiceItem[] = [];

  availableIcons = [
    { label: 'Serviço Geral', value: 'fa-briefcase' },
    { label: 'Martelo / Obra', value: 'fa-hammer' },
    { label: 'Chave de Fenda', value: 'fa-screwdriver' },
    { label: 'Rolo de Pintura', value: 'fa-paint-roller' },
    { label: 'Raio / Elétrica', value: 'fa-bolt' },
    { label: 'Torneira / Cano', value: 'fa-faucet' },
    { label: 'Vassoura / Faxina', value: 'fa-broom' },
    { label: 'Coração / Babá', value: 'fa-heart' },
    { label: 'Engrenagem / Reparo', value: 'fa-gear' }
  ];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const [resCat, resServ] = await Promise.allSettled([
        api.get('/api/categories?pageSize=100'),
        api.get('/api/services')
      ]);

      if (resCat.status === 'fulfilled' && resCat.value.data) {
        const catData = resCat.value.data?.result || resCat.value.data?.data || resCat.value.data;
        const catList = Array.isArray(catData)
          ? catData
          : (Array.isArray(catData?.data?.data)
              ? catData.data.data
              : (Array.isArray(catData?.data) ? catData.data : []));
        this.categoriesList = catList.map((c: any) => ({
          id: c.id || c._id,
          name: c.name
        }));
      } else {
        this.categoriesList = [];
      }

      if (resServ.status === 'fulfilled' && resServ.value.data) {
        const servData = resServ.value.data?.result || resServ.value.data?.data || resServ.value.data;
        const servList = Array.isArray(servData) ? servData : (Array.isArray(servData?.data) ? servData.data : []);
        this.services = servList.map((s: any) => {
          const cat = this.categoriesList.find(c => c.id === s.categoryId);
          return {
            id: s.id || s._id,
            name: s.name,
            categoryId: s.categoryId,
            categoryName: cat?.name || 'Geral',
            icon: s.icon || 'fa-briefcase',
            createdAt: s.createdAt || s.created_at || new Date().toISOString()
          };
        });
      } else {
        this.services = [];
      }
    } catch {
      this.services = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): ServiceItem[] {
    return this.services.filter(s => {
      const matchCat = this.selectedCategoryFilter === 'all' || s.categoryId === this.selectedCategoryFilter;
      const matchQuery = !this.searchQuery ||
        s.name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        (s.categoryName && s.categoryName.toLowerCase().includes(this.searchQuery.toLowerCase()));
      return matchCat && matchQuery;
    });
  }

  getCategoryName(id: string): string {
    const cat = this.categoriesList.find(c => c.id === id);
    return cat ? cat.name : 'Categoria Geral';
  }

  openCreateModal() {
    if (this.categoriesList.length === 0) {
      this.toastr.warning('Cadastre ao menos uma categoria antes de adicionar serviços.');
    }
    this.modalMode = 'create';
    this.formData = {
      id: '',
      name: '',
      categoryId: this.categoriesList[0]?.id || '',
      icon: 'fa-briefcase'
    };
    this.isModalOpen = true;
  }

  openEditModal(item: ServiceItem) {
    this.modalMode = 'edit';
    this.formData = { ...item };
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }

  async saveService() {
    if (!this.formData.name.trim() || !this.formData.categoryId) {
      this.toastr.warning('Preencha o nome do serviço e selecione a categoria.');
      return;
    }

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      if (this.modalMode === 'create') {
        const payload = {
          name: this.formData.name,
          categoryId: this.formData.categoryId,
          icon: this.formData.icon
        };

        await api.post('/api/services', payload);
        this.toastr.success('Serviço cadastrado com sucesso!');
      } else {
        const payload = {
          id: this.formData.id,
          name: this.formData.name,
          categoryId: this.formData.categoryId,
          icon: this.formData.icon
        };

        await api.put('/api/services', payload);
        this.toastr.success('Serviço atualizado com sucesso!');
      }

      this.closeModal();
      await this.loadData();
    } catch {
      this.toastr.error('Erro ao salvar serviço.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }

  confirmDelete(item: ServiceItem) {
    this.serviceToDelete = item;
    this.isDeleteModalOpen = true;
  }

  closeDeleteModal() {
    this.isDeleteModalOpen = false;
    this.serviceToDelete = null;
  }

  async executeDelete() {
    if (!this.serviceToDelete) return;

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      await api.delete(`/api/services/${this.serviceToDelete.id}`);
      this.toastr.success('Serviço removido com sucesso!');
      this.closeDeleteModal();
      await this.loadData();
    } catch {
      this.toastr.error('Erro ao excluir serviço.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }
}
