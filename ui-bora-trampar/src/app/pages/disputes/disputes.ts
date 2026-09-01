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
  customerEvidenceUrl?: string;
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
      const [resAppts, resUsers] = await Promise.allSettled([
        api.get('/api/appointments'),
        api.get('/api/users')
      ]);

      const users: any[] = resUsers.status === 'fulfilled' && resUsers.value.data?.result ? resUsers.value.data.result : [];
      const userMap = new Map<string, any>(users.map(u => [u.id || u._id, u]));

      if (resAppts.status === 'fulfilled' && resAppts.value.data?.result && Array.isArray(resAppts.value.data.result)) {
        const appts: any[] = resAppts.value.data.result;
        const disputed = appts.filter(a => a.status === 'disputed' || a.disputed);

        this.disputes = disputed.map((apt: any) => {
          const customer = userMap.get(apt.customer_id || apt.customerId) || {};
          const pro = userMap.get(apt.profissional_id || apt.profissionalId) || {};

          return {
            id: `DISP-${apt.id?.substring(0, 4) || '001'}`,
            appointmentId: apt.id || apt._id,
            customerName: customer.name || 'Cliente',
            professionalName: pro.name || 'Profissional',
            serviceName: apt.serviceName || 'Serviço Prestado',
            totalValue: Number(apt.price || apt.value || 150.0),
            openedAt: apt.updatedAt || apt.createdAt || new Date().toISOString(),
            reason: apt.disputeReason || 'Contestação sobre a qualidade ou entrega do serviço.',
            customerEvidenceUrl: apt.customerEvidenceUrl || '',
            proNotes: apt.proNotes || '',
            status: 'under_review',
            statusLabel: 'Em Análise'
          };
        });
      } else {
        this.disputes = [];
      }
    } catch {
      this.disputes = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

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
      this.selectedItem.status = this.decisionType;
      if (this.decisionType === 'released_pro') {
        this.selectedItem.statusLabel = 'Liberado ao Profissional';
        this.toastr.success(`Pagamento de ${this.global.formatCurrency(this.selectedItem.totalValue)} liberado ao profissional.`);
      } else if (this.decisionType === 'refunded_full') {
        this.selectedItem.statusLabel = 'Reembolso Total Cliente';
        this.toastr.info(`Reembolso integral autorizado ao cliente.`);
      } else if (this.decisionType === 'refunded_partial') {
        this.selectedItem.statusLabel = `Reembolso Parcial (${this.partialRefundPercentage}%)`;
        this.toastr.info(`Reembolso parcial de ${this.partialRefundPercentage}% aplicado.`);
      } else {
        this.selectedItem.statusLabel = 'Aguardando Informações';
        this.toastr.warning(`Prazo para envio de informações adicionais aberto.`);
      }

      this.selectedItem.adminDecision = this.decisionJustification;
      this.selectedItem.decidedBy = 'Super Admin';
      this.selectedItem.decidedAt = new Date().toLocaleString('pt-BR');

      this.closeDecisionModal();
      this.closeDetails();
    } catch {
      this.toastr.error('Erro ao registrar decisão.');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }
}
