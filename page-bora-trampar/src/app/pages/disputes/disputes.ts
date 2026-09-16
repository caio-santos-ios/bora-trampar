import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface DisputeItem {
  id: string;
  appointmentId: string;
  customerName: string;
  professionalName: string;
  serviceName: string;
  totalValue: number;
  openedAt: string;
  reason: string;
  description?: string;
  customerEvidenceUrl?: string;
  photos?: string[];
  videoUrl?: string;
  proNotes?: string;
  status: 'under_review' | 'released_pro' | 'refunded_full' | 'refunded_partial' | 'info_requested';
  statusLabel: string;
  adminDecision?: string;
  decidedBy?: string;
  decidedAt?: string;
}

@Component({
  selector: 'app-disputes',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './disputes.html',
  styleUrl: './disputes.css'
})
export class Disputes implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterStatus = 'all';

  selectedItem: DisputeItem | null = null;
  isModalOpen = false;
  isDecisionModalOpen = false;
  decisionType: 'released_pro' | 'refunded_full' | 'refunded_partial' | 'info_requested' = 'released_pro';
  decisionJustification = '';
  partialRefundPercentage = 50;

  disputes: DisputeItem[] = [];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDisputes();
  }

  async loadDisputes() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const response = await api.get('/api/contestations');
      const resObj = response.data?.result || response.data?.data || response.data;
      let list: any[] = [];

      if (Array.isArray(resObj)) {
        list = resObj;
      } else if (resObj?.data && Array.isArray(resObj.data.data)) {
        list = resObj.data.data;
      } else if (Array.isArray(resObj?.data)) {
        list = resObj.data;
      } else {
        list = [];
      }

      this.disputes = list.map((item: any) => {
        return {
          id: item.id || item._id,
          appointmentId: item.appointmentId || item.appointment_id || '',
          customerName: item.customerName || item.customer_name || 'Cliente',
          professionalName: item.professionalName || item.professional_name || 'Profissional',
          serviceName: item.serviceName || item.service_name || 'Serviço Prestado',
          totalValue: Number(item.value || item.totalValue || 0),
          openedAt: item.openedAt || item.createdAt || item.created_at || new Date().toISOString(),
          reason: item.reason || 'Contestação sobre a qualidade ou entrega do serviço.',
          description: item.description || '',
          customerEvidenceUrl: item.customerEvidenceUrl || item.customer_evidence_url || '',
          photos: Array.isArray(item.photos) ? item.photos : (item.customerEvidenceUrl ? [item.customerEvidenceUrl] : []),
          videoUrl: item.videoUrl || item.video_url || '',
          proNotes: item.proNotes || item.pro_notes || '',
          status: item.status || 'under_review',
          statusLabel: item.statusLabel || item.status_label || 'Em Análise',
          adminDecision: item.adminDecision || item.admin_decision || '',
          decidedBy: item.decidedBy || item.decided_by || '',
          decidedAt: item.decidedAt || item.decided_at || ''
        };
      });
    } catch {
      this.disputes = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  currentPage = 1;
  pageSize = 10;

  get filteredList(): DisputeItem[] {
    return this.disputes.filter(d => {
      const matchStatus = this.filterStatus === 'all' || d.status === this.filterStatus;
      const matchQuery = !this.searchQuery ||
        d.id.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        d.customerName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        d.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        d.appointmentId.toLowerCase().includes(this.searchQuery.toLowerCase());
      return matchStatus && matchQuery;
    });
  }

  get totalCount(): number {
    return this.filteredList.length;
  }

  get totalPages(): number {
    return Math.ceil(this.totalCount / this.pageSize) || 1;
  }

  get startIndex(): number {
    if (this.totalCount === 0) return 0;
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get endIndex(): number {
    return Math.min(this.currentPage * this.pageSize, this.totalCount);
  }

  get paginatedList(): DisputeItem[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredList.slice(start, start + this.pageSize);
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

  goToPage(page: number) {
    if (page < 1 || page > this.totalPages || page === this.currentPage) return;
    this.currentPage = page;
  }

  onFilterChange() {
    this.currentPage = 1;
  }

  openDetails(item: DisputeItem) {
    this.selectedItem = item;
    this.isModalOpen = true;
  }

  closeDetails() {
    this.isModalOpen = false;
  }

  openDecisionModal(type: 'released_pro' | 'refunded_full' | 'refunded_partial' | 'info_requested') {
    this.decisionType = type;
    this.decisionJustification = '';
    this.isDecisionModalOpen = true;
  }

  closeDecisionModal() {
    this.isDecisionModalOpen = false;
  }

  async applyDecision() {
    if (!this.selectedItem) return;
    if (!this.decisionJustification.trim()) {
      this.toastr.warning('A justificativa da decisão administrativa é obrigatória.');
      return;
    }

    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      let statusLabel = 'Em Análise';
      if (this.decisionType === 'released_pro') {
        statusLabel = 'Liberado ao Profissional';
      } else if (this.decisionType === 'refunded_full') {
        statusLabel = 'Reembolso Total Cliente';
      } else if (this.decisionType === 'refunded_partial') {
        statusLabel = `Reembolso Parcial (${this.partialRefundPercentage}%)`;
      } else {
        statusLabel = 'Aguardando Informações';
      }

      await api.put('/api/contestations', {
        id: this.selectedItem.id,
        status: this.decisionType,
        statusLabel: statusLabel,
        adminDecision: this.decisionJustification,
        decidedBy: 'Super Admin',
        partialRefundPercentage: this.partialRefundPercentage
      });

      this.selectedItem.status = this.decisionType;
      this.selectedItem.statusLabel = statusLabel;
      this.selectedItem.adminDecision = this.decisionJustification;
      this.selectedItem.decidedBy = 'Super Admin';
      this.selectedItem.decidedAt = new Date().toLocaleString('pt-BR');

      if (this.decisionType === 'released_pro') {
        this.toastr.success(`Pagamento de ${this.global.formatCurrency(this.selectedItem.totalValue)} liberado ao profissional.`);
      } else if (this.decisionType === 'refunded_full') {
        this.toastr.info(`Reembolso integral autorizado e creditado na carteira do cliente.`);
      } else if (this.decisionType === 'refunded_partial') {
        this.toastr.info(`Reembolso parcial de ${this.partialRefundPercentage}% aplicado com sucesso.`);
      } else {
        this.toastr.warning(`Prazo para envio de informações adicionais aberto.`);
      }

      this.closeDecisionModal();
      this.closeDetails();
      await this.loadDisputes();
    } catch {
      this.toastr.error('Erro ao registrar decisão.');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }
}
