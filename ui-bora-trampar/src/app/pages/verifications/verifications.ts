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

      let usersList: any[] = [];
      if (resUsers.status === 'fulfilled' && resUsers.value.data) {
        const uPayload = resUsers.value.data;
        if (Array.isArray(uPayload)) usersList = uPayload;
        else if (Array.isArray(uPayload.result)) usersList = uPayload.result;
        else if (uPayload.result && Array.isArray(uPayload.result.data)) usersList = uPayload.result.data;
        else if (Array.isArray(uPayload.data)) usersList = uPayload.data;
      }
      const userMap = new Map<string, any>(usersList.map(u => [u.id || u._id, u]));

      let approvalsList: any[] = [];
      if (resApprovals.status === 'fulfilled' && resApprovals.value.data) {
        const aPayload = resApprovals.value.data;
        if (Array.isArray(aPayload)) approvalsList = aPayload;
        else if (Array.isArray(aPayload.result)) approvalsList = aPayload.result;
        else if (aPayload.result && Array.isArray(aPayload.result.data)) approvalsList = aPayload.result.data;
        else if (Array.isArray(aPayload.data)) approvalsList = aPayload.data;
      }

      if (approvalsList.length > 0) {
        this.verifications = approvalsList.map((appr: any) => {
          const user = userMap.get(appr.profissional_id || appr.profissionalId) || {};
          const rawStatus = (appr.status || (appr.approved ? 'approved' : 'analysis')).toString().toLowerCase().trim();
          const status = (rawStatus === 'approved' || rawStatus === 'approve')
            ? 'approved'
            : (rawStatus === 'rejected' || rawStatus === 'reject')
              ? 'rejected'
              : rawStatus === 'correction'
                ? 'correction'
                : 'analysis';

          const rawId = appr.id || appr._id;
          const cleanId = (rawId && typeof rawId === 'object') ? (rawId.$oid || rawId.toString?.() || '') : (rawId?.toString?.() || '');

          return {
            id: cleanId,
            professionalId: appr.profissional_id || appr.profissionalId || '',
            professionalName: user.name || 'Profissional',
            email: user.email || 'Não informado',
            phone: user.whatsApp || user.phone || 'Não informado',
            category: 'Profissional Autônomo',
            documentType: appr.documentType || appr.document_type || 'CNH',
            documentNumber: appr.documentNumber || appr.document_number || 'Não cadastrado',
            submittedAt: appr.createdAt || appr.created_at || new Date().toISOString(),
            status: status as any,
            statusLabel: status === 'approved' ? 'Aprovado' : status === 'correction' ? 'Necessita Correção' : status === 'rejected' ? 'Reprovado' : 'Em Análise',
            rgFrontUrl: appr.rgFrontUrl || appr.rg_front_url || '',
            rgBackUrl: appr.rgBackUrl || appr.rg_back_url || '',
            selfieUrl: appr.selfieUrl || appr.selfie_url || user.photo || '',
            reviewNotes: appr.reviewNotes || appr.review_notes || '',
            reviewedBy: appr.reviewedBy || appr.reviewed_by || '',
            reviewedAt: appr.reviewedAt || appr.reviewed_at || ''
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
      const normalizedStatus = this.actionType === 'approve' ? 'approved' : this.actionType === 'reject' ? 'rejected' : 'correction';
      const payload = {
        id: this.selectedItem.id,
        approved: this.actionType === 'approve',
        status: normalizedStatus,
        reviewNotes: this.actionJustification
      };

      await api.put('/api/approvals', payload);

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
      await this.loadData();
    } catch {
      this.toastr.error('Erro ao atualizar aprovação.');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }
}
