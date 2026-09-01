import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface VerificationItem {
  id: string;
  professionalId: string;
  professionalName: string;
  email: string;
  phone: string;
  category: string;
  documentType: 'RG' | 'CNH';
  documentNumber: string;
  submittedAt: string;
  status: 'pending' | 'analysis' | 'approved' | 'correction' | 'rejected';
  statusLabel: string;
  rgFrontUrl?: string;
  rgBackUrl?: string;
  selfieUrl?: string;
  reviewNotes?: string;
  reviewedBy?: string;
  reviewedAt?: string;
}

@Component({
  selector: 'app-verifications',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './verifications.html',
  styleUrl: './verifications.css'
})
export class Verifications implements OnInit {
  isLoading = false;
  filterStatus = 'all';
  searchQuery = '';

  selectedItem: VerificationItem | null = null;
  isModalOpen = false;
  isActionModalOpen = false;
  actionType: 'approve' | 'correction' | 'reject' = 'approve';
  actionJustification = '';

  verifications: VerificationItem[] = [];

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
      const [resApprovals, resUsers] = await Promise.allSettled([
        api.get('/api/approvals'),
        api.get('/api/users')
      ]);

      const users: any[] = resUsers.status === 'fulfilled' && resUsers.value.data?.result ? resUsers.value.data.result : [];
      const userMap = new Map<string, any>(users.map(u => [u.id || u._id, u]));

      if (resApprovals.status === 'fulfilled' && resApprovals.value.data?.result && Array.isArray(resApprovals.value.data.result)) {
        this.verifications = resApprovals.value.data.result.map((appr: any) => {
          const user = userMap.get(appr.profissional_id || appr.profissionalId) || {};
          const status = appr.approved ? 'approved' : (appr.status || 'analysis');
          return {
            id: appr.id || appr._id,
            professionalId: appr.profissional_id || appr.profissionalId || '',
            professionalName: user.name || 'Profissional',
            email: user.email || 'Não informado',
            phone: user.whatsApp || user.phone || 'Não informado',
            category: 'Profissional Autônomo',
            documentType: 'CNH',
            documentNumber: appr.documentNumber || 'Não cadastrado',
            submittedAt: appr.createdAt || new Date().toISOString(),
            status: status as any,
            statusLabel: status === 'approved' ? 'Aprovado' : status === 'correction' ? 'Necessita Correção' : status === 'rejected' ? 'Reprovado' : 'Em Análise',
            rgFrontUrl: appr.rgFrontUrl || '',
            rgBackUrl: appr.rgBackUrl || '',
            selfieUrl: appr.selfieUrl || user.photo || '',
            reviewNotes: appr.reviewNotes || '',
            reviewedBy: appr.reviewedBy || '',
            reviewedAt: appr.reviewedAt || ''
          };
        });
      } else {
        this.verifications = [];
      }
    } catch {
      this.verifications = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): VerificationItem[] {
    return this.verifications.filter(item => {
      const matchStatus = this.filterStatus === 'all' || item.status === this.filterStatus;
      const matchQuery = !this.searchQuery ||
        item.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.documentNumber.includes(this.searchQuery) ||
        item.category.toLowerCase().includes(this.searchQuery.toLowerCase());
      return matchStatus && matchQuery;
    });
  }

  openDetails(item: VerificationItem) {
    this.selectedItem = item;
    this.isModalOpen = true;
  }

  closeDetails() {
    this.isModalOpen = false;
  }

  openActionModal(type: 'approve' | 'correction' | 'reject') {
    this.actionType = type;
    this.actionJustification = '';
    this.isActionModalOpen = true;
  }

  closeActionModal() {
    this.isActionModalOpen = false;
  }

  async confirmAction() {
    if (!this.selectedItem) return;

    if (this.actionType !== 'approve' && !this.actionJustification.trim()) {
      this.toastr.warning('Por favor, informe a justificativa da decisão.');
      return;
    }

    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const payload = {
        id: this.selectedItem.id,
        approved: this.actionType === 'approve',
        status: this.actionType === 'approve' ? 'approved' : this.actionType,
        reviewNotes: this.actionJustification
      };

      try {
        await api.put('/api/approvals', payload);
      } catch {}

      if (this.actionType === 'approve') {
        this.selectedItem.status = 'approved';
        this.selectedItem.statusLabel = 'Aprovado';
        this.toastr.success(`Cadastro de ${this.selectedItem.professionalName} aprovado com sucesso!`);
      } else if (this.actionType === 'correction') {
        this.selectedItem.status = 'correction';
        this.selectedItem.statusLabel = 'Necessita Correção';
        this.selectedItem.reviewNotes = this.actionJustification;
        this.toastr.info(`Solicitação de correção enviada ao profissional.`);
      } else if (this.actionType === 'reject') {
        this.selectedItem.status = 'rejected';
        this.selectedItem.statusLabel = 'Reprovado';
        this.selectedItem.reviewNotes = this.actionJustification;
        this.toastr.error(`Cadastro reprovado.`);
      }

      this.selectedItem.reviewedBy = 'Admin Logado';
      this.selectedItem.reviewedAt = new Date().toLocaleString('pt-BR');

      this.closeActionModal();
      this.closeDetails();
    } catch {
      this.toastr.error('Erro ao atualizar aprovação.');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }
}
