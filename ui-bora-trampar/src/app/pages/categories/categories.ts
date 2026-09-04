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
  searchTimeout: any = null;

  currentPage = 1;
  pageSize = 10;
  totalCount = 0;
  totalPages = 1;
  pageSizeOptions = [5, 10, 20, 50];

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

  async loadCategories(page: number = this.currentPage) {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const params: any = {
        pageNumber: page,
        pageSize: this.pageSize
      };

      const query = this.searchQuery.trim();
      if (query) {
        params['regex$name'] = query;
      }

      const response = await api.get('/api/categories', { params });
      const resObj = response.data?.result || response.data?.data || response.data;
      let list: any[] = [];

      if (Array.isArray(resObj)) {
        list = resObj;
        this.totalCount = list.length;
        this.totalPages = Math.ceil(this.totalCount / this.pageSize) || 1;
        this.currentPage = 1;
      } else if (resObj?.data && Array.isArray(resObj.data.data)) {
        list = resObj.data.data;
        this.totalCount = resObj.data.totalCount || 0;
        this.totalPages = resObj.data.totalPages || 1;
        this.currentPage = resObj.data.currentPage || page;
        this.pageSize = resObj.data.pageSize || this.pageSize;
      } else if (Array.isArray(resObj?.data)) {
        list = resObj.data;
        this.totalCount = resObj.totalCount || list.length;
        this.totalPages = resObj.totalPages || Math.ceil(this.totalCount / this.pageSize) || 1;
        this.currentPage = resObj.currentPage || page;
      } else {
        list = [];
        this.totalCount = 0;
        this.totalPages = 1;
        this.currentPage = 1;
      }

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
      this.totalCount = 0;
      this.totalPages = 1;
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): CategoryItem[] {
    return this.categories;
  }

  get startIndex(): number {
    if (this.totalCount === 0) return 0;
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get endIndex(): number {
    return Math.min(this.currentPage * this.pageSize, this.totalCount);
  }

  get visiblePages(): number[] {
    const pages: number[] = [];
    const maxVisible = 5;
    let start = Math.max(1, this.currentPage - Math.floor(maxVisible / 2));
    let end = Math.min(this.totalPages, start + maxVisible - 1);

    if (end - start + 1 < maxVisible) {
      start = Math.max(1, end - maxVisible + 1);
    }

    for (let i = start; i <= end; i++) {
      pages.push(i);
    }
    return pages;
  }

  onSearchInput() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }
    this.searchTimeout = setTimeout(() => {
      this.currentPage = 1;
      this.loadCategories(1);
    }, 350);
  }

  clearSearch() {
    this.searchQuery = '';
    this.currentPage = 1;
    this.loadCategories(1);
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
      this.currentPage = page;
      this.loadCategories(page);
    }
  }

  onPageSizeChange(newSize: any) {
    this.pageSize = Number(newSize);
    this.currentPage = 1;
    this.loadCategories(1);
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
      await this.loadCategories(this.currentPage);
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
      if (this.categories.length === 1 && this.currentPage > 1) {
        this.currentPage--;
      }
      await this.loadCategories(this.currentPage);
    } catch {
      this.toastr.error('Erro ao excluir categoria.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }
}
