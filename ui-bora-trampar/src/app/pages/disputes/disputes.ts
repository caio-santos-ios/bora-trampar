import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';

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

  disputes: DisputeItem[] = [
    {
      id: 'DISP-042',
      appointmentId: 'APT-1078',
      customerName: 'Fernando Costa',
      professionalName: 'Lucas Pedreiro & Reformas',
      serviceName: 'Troca de Piso Banheiro',
      totalValue: 480.0,
      openedAt: '2026-08-28T14:30:00Z',
      reason: 'O profissional assentou 4 peças com desnível visível e deixou rejunte incompleto.',
      customerEvidenceUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600&auto=format&fit=crop&q=80',
      proNotes: 'O cliente comprou piso fora de esquadro, mas me comprometi a voltar para aplicar o rejunte faltante.',
      status: 'under_review',
      statusLabel: 'Em Análise'
    },
    {
      id: 'DISP-041',
      appointmentId: 'APT-1060',
      customerName: 'Patrícia Queiroz',
      professionalName: 'Marcos Vinícius Eletricista',
      serviceName: 'Troca de Chuveiro e Disjuntor',
      totalValue: 180.0,
      openedAt: '2026-08-25T11:00:00Z',
      reason: 'O chuveiro queimou 1 hora após a instalação.',
      proNotes: 'A voltagem do aparelho comprado era 110V e a rede era 220V, avisei a cliente antes.',
      status: 'released_pro',
      statusLabel: 'Liberado ao Profissional',
      adminDecision: 'Contestação improcedente. Erro de especificação do produto pelo cliente.',
      decidedBy: 'Admin (Caio)',
      decidedAt: '26/08/2026 15:00'
    }
  ];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDisputes();
  }

  loadDisputes() {
    this.isLoading = false;
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

  applyDecision() {
    if (!this.selectedItem) return;
    if (!this.decisionJustification.trim()) {
      this.toastr.warning('A justificativa da decisão administrativa é obrigatória.');
      return;
    }

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
    this.cdr.detectChanges();
  }
}
