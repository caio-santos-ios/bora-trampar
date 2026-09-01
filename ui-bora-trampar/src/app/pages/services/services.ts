import { Component, OnInit } from '@angular/core';
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

  categoriesList: CategoryRef[] = [
    { id: 'cat_01', name: 'Construção & Reformas' },
    { id: 'cat_02', name: 'Pintura Residencial & Predial' },
    { id: 'cat_03', name: 'Instalações Elétricas' },
    { id: 'cat_04', name: 'Limpeza & Cuidados' }
  ];

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

  services: ServiceItem[] = [
    {
      id: 'srv_01',
      name: 'Assentamento de Pisos e Porcelanato',
      categoryId: 'cat_01',
      categoryName: 'Construção & Reformas',
      icon: 'fa-hammer',
      createdAt: '2026-08-01T12:00:00Z'
    },
    {
      id: 'srv_02',
      name: 'Pintura Completa de Paredes e Tetos',
      categoryId: 'cat_02',
      categoryName: 'Pintura Residencial & Predial',
      icon: 'fa-paint-roller',
      createdAt: '2026-08-02T13:00:00Z'
    },
    {
      id: 'srv_03',
      name: 'Instalação de Tomadas, Interruptores e Lustres',
      categoryId: 'cat_03',
      categoryName: 'Instalações Elétricas',
      icon: 'fa-bolt',
      createdAt: '2026-08-03T15:00:00Z'
    },
    {
      id: 'srv_04',
      name: 'Faxina Geral e Limpeza Pós-Obra',
      categoryId: 'cat_04',
      categoryName: 'Limpeza & Cuidados',
      icon: 'fa-broom',
      createdAt: '2026-08-05T10:00:00Z'
    },
    {
      id: 'srv_05',
      name: 'Reparo e Troca de Fiação Elétrica',
      categoryId: 'cat_03',
      categoryName: 'Instalações Elétricas',
      icon: 'fa-bolt',
      createdAt: '2026-08-06T14:30:00Z'
    }
  ];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService
  ) {}

  ngOnInit() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      const [resCat, resServ] = await Promise.allSettled([
        api.get('/api/categories'),
        api.get('/api/services')
      ]);

      if (resCat.status === 'fulfilled' && resCat.value.data?.result) {
        this.categoriesList = resCat.value.data.result.map((c: any) => ({
          id: c.id || c._id,
          name: c.name
        }));
      }

      if (resServ.status === 'fulfilled' && resServ.value.data?.result) {
        this.services = resServ.value.data.result.map((s: any) => {
          const cat = this.categoriesList.find(c => c.id === s.categoryId);
          return {
            id: s.id || s._id,
            name: s.name,
            categoryId: s.categoryId,
            categoryName: cat?.name || 'Geral',
            icon: s.icon || 'fa-briefcase',
            createdAt: s.createdAt || new Date().toISOString()
          };
        });
      }
    } catch (e) {
      console.warn('Fallback to local services');
    } finally {
      this.isLoading = false;
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
    this.modalMode = 'create';
    this.formData = {
      id: '',
      name: '',
      categoryId: this.categoriesList[0]?.id || 'cat_01',
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

    try {
      if (this.modalMode === 'create') {
        const payload = {
          name: this.formData.name,
          categoryId: this.formData.categoryId,
          icon: this.formData.icon
        };

        try {
          const res = await api.post('/api/services', payload);
          const created = res.data?.result;
          this.services.unshift({
            id: created?.id || 'srv_' + Date.now(),
            name: this.formData.name,
            categoryId: this.formData.categoryId,
            categoryName: this.getCategoryName(this.formData.categoryId),
            icon: this.formData.icon,
            createdAt: new Date().toISOString()
          });
        } catch {
          this.services.unshift({
            id: 'srv_' + Date.now(),
            name: this.formData.name,
            categoryId: this.formData.categoryId,
            categoryName: this.getCategoryName(this.formData.categoryId),
            icon: this.formData.icon,
            createdAt: new Date().toISOString()
          });
        }

        this.toastr.success('Serviço cadastrado com sucesso!');
      } else {
        const payload = {
          id: this.formData.id,
          name: this.formData.name,
          categoryId: this.formData.categoryId,
          icon: this.formData.icon
        };

        try {
          await api.put('/api/services', payload);
        } catch {}

        const index = this.services.findIndex(s => s.id === this.formData.id);
        if (index !== -1) {
          this.services[index] = {
            ...this.formData,
            categoryName: this.getCategoryName(this.formData.categoryId)
          };
        }

        this.toastr.success('Serviço atualizado com sucesso!');
      }
      this.closeModal();
    } catch {
      this.toastr.error('Erro ao salvar serviço.');
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

    try {
      try {
        await api.delete(`/api/services/${this.serviceToDelete.id}`);
      } catch {}

      this.services = this.services.filter(s => s.id !== this.serviceToDelete!.id);
      this.toastr.success('Serviço removido com sucesso!');
      this.closeDeleteModal();
    } catch {
      this.toastr.error('Erro ao excluir serviço.');
    }
  }
}
