import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface DailyWordItem {
  id: string;
  title: string;
  verse: string;
  reference: string;
  message: string;
  targetAudience: 'both' | 'customer' | 'professional' | string;
  isActive: boolean;
  startDate: string;
  endDate?: string | null;
  createdAt?: string;
}

@Component({
  selector: 'app-daily-words',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './daily-words.html',
  styleUrl: './daily-words.css'
})
export class DailyWords implements OnInit {
  isLoading = false;
  isSaving = false;
  searchQuery = '';
  selectedAudienceFilter = 'all';
  searchTimeout: any = null;

  currentPage = 1;
  pageSize = 10;
  totalCount = 0;
  totalPages = 1;
  pageSizeOptions = [5, 10, 20, 50];

  isModalOpen = false;
  isDeleteModalOpen = false;
  modalMode: 'create' | 'edit' = 'create';

  formData: DailyWordItem = {
    id: '',
    title: 'PALAVRA DO DIA',
    verse: '',
    reference: '',
    message: '',
    targetAudience: 'both',
    isActive: true,
    startDate: new Date().toISOString().substring(0, 10),
    endDate: null
  };

  itemToDelete: DailyWordItem | null = null;
  items: DailyWordItem[] = [];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDailyWords();
  }

  async loadDailyWords(page: number = this.currentPage) {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const params: any = {
        pageNumber: page,
        pageSize: this.pageSize,
        deleted: false
      };

      const query = this.searchQuery.trim();
      if (query) {
        params['regex$verse'] = query;
      }

      if (this.selectedAudienceFilter && this.selectedAudienceFilter !== 'all') {
        params['target_audience'] = this.selectedAudienceFilter;
      }

      const response = await api.get('/api/daily-words', { params });
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

      this.items = list.map((item: any) => ({
        id: item.id || item._id,
        title: item.title || 'PALAVRA DO DIA',
        verse: item.verse || '',
        reference: item.reference || '',
        message: item.message || '',
        targetAudience: item.targetAudience || item.target_audience || 'both',
        isActive: item.isActive !== undefined ? item.isActive : (item.is_active !== undefined ? item.is_active : true),
        startDate: item.startDate || item.start_date || '',
        endDate: item.endDate || item.end_date || null,
        createdAt: item.createdAt || item.created_at || new Date().toISOString()
      }));
    } catch {
      this.items = [];
      this.totalCount = 0;
      this.totalPages = 1;
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): DailyWordItem[] {
    return this.items;
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
      this.loadDailyWords(1);
    }, 350);
  }

  clearSearch() {
    this.searchQuery = '';
    this.currentPage = 1;
    this.loadDailyWords(1);
  }

  onFilterAudienceChange() {
    this.currentPage = 1;
    this.loadDailyWords(1);
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
      this.currentPage = page;
      this.loadDailyWords(page);
    }
  }

  onPageSizeChange(newSize: any) {
    this.pageSize = Number(newSize);
    this.currentPage = 1;
    this.loadDailyWords(1);
  }

  openCreateModal() {
    this.modalMode = 'create';
    this.formData = {
      id: '',
      title: 'PALAVRA DO DIA',
      verse: '',
      reference: '',
      message: '',
      targetAudience: 'both',
      isActive: true,
      startDate: new Date().toISOString().substring(0, 10),
      endDate: null
    };
    this.isModalOpen = true;
  }

  openEditModal(item: DailyWordItem) {
    this.modalMode = 'edit';
    this.formData = {
      ...item,
      startDate: item.startDate ? item.startDate.substring(0, 10) : '',
      endDate: item.endDate ? item.endDate.substring(0, 10) : null
    };
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }

  async saveDailyWord() {
    if (!this.formData.verse.trim()) {
      this.toastr.warning('O versículo bíblico é obrigatório.');
      return;
    }
    if (!this.formData.reference.trim()) {
      this.toastr.warning('A referência bíblica é obrigatória (ex: Salmos 37:5).');
      return;
    }

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      const payload: any = {
        title: this.formData.title?.trim() || 'PALAVRA DO DIA',
        verse: this.formData.verse.trim(),
        reference: this.formData.reference.trim(),
        message: this.formData.message.trim(),
        targetAudience: this.formData.targetAudience,
        isActive: this.formData.isActive,
        startDate: this.formData.startDate ? new Date(this.formData.startDate).toISOString() : new Date().toISOString(),
        endDate: this.formData.endDate ? new Date(this.formData.endDate).toISOString() : null
      };

      if (this.modalMode === 'create') {
        await api.post('/api/daily-words', payload);
        this.toastr.success('Palavra do Dia cadastrada com sucesso!');
      } else {
        payload.id = this.formData.id;
        await api.put('/api/daily-words', payload);
        this.toastr.success('Palavra do Dia atualizada com sucesso!');
      }

      this.closeModal();
      await this.loadDailyWords(this.currentPage);
    } catch (err: any) {
      const msg = err.response?.data?.message || 'Erro ao salvar Palavra do Dia.';
      this.toastr.error(msg);
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }

  async toggleStatus(item: DailyWordItem) {
    this.isSaving = true;
    try {
      const updatedStatus = !item.isActive;
      const payload = {
        id: item.id,
        title: item.title,
        verse: item.verse,
        reference: item.reference,
        message: item.message,
        targetAudience: item.targetAudience,
        isActive: updatedStatus,
        startDate: item.startDate,
        endDate: item.endDate
      };

      await api.put('/api/daily-words', payload);
      item.isActive = updatedStatus;
      this.toastr.success(updatedStatus ? 'Palavra do Dia ativada!' : 'Palavra do Dia pausada!');
    } catch {
      this.toastr.error('Erro ao alternar status da Palavra do Dia.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }

  confirmDelete(item: DailyWordItem) {
    this.itemToDelete = item;
    this.isDeleteModalOpen = true;
  }

  closeDeleteModal() {
    this.isDeleteModalOpen = false;
    this.itemToDelete = null;
  }

  async executeDelete() {
    if (!this.itemToDelete) return;

    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      await api.delete(`/api/daily-words/${this.itemToDelete.id}`);
      this.toastr.success('Palavra do Dia removida com sucesso!');
      this.closeDeleteModal();
      if (this.items.length === 1 && this.currentPage > 1) {
        this.currentPage--;
      }
      await this.loadDailyWords(this.currentPage);
    } catch {
      this.toastr.error('Erro ao excluir Palavra do Dia.');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }

  getAudienceLabel(audience: string): string {
    switch (audience) {
      case 'customer':
        return 'Apenas Clientes';
      case 'professional':
        return 'Apenas Profissionais';
      case 'both':
      default:
        return 'Ambos';
    }
  }

  getAudienceBadgeClass(audience: string): string {
    switch (audience) {
      case 'customer':
        return 'badge-customer';
      case 'professional':
        return 'badge-professional';
      case 'both':
      default:
        return 'badge-both';
    }
  }
}
