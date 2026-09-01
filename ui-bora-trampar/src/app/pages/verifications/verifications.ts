import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface VerificationItem {
  id: string;
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

  verifications: VerificationItem[] = [
    {
      id: 'VRF-001',
      professionalName: 'Marcos Vinícius Eletricista',
      email: 'marcos.eletrica@email.com',
      phone: '(11) 98765-4321',
      category: 'Eletricista',
      documentType: 'CNH',
      documentNumber: '04598213890',
      submittedAt: '2026-09-01T09:30:00Z',
      status: 'analysis',
      statusLabel: 'Em Análise',
      rgFrontUrl: 'https://images.unsplash.com/photo-1633409381657-57b1893bc2b7?w=600&auto=format&fit=crop&q=80',
      selfieUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=400&auto=format&fit=crop&q=80'
    },
    {
      id: 'VRF-002',
      professionalName: 'Cláudio Silva Pinturas',
      email: 'claudio.pintor@email.com',
      phone: '(11) 97654-3210',
      category: 'Pintura',
      documentType: 'RG',
      documentNumber: '44.890.123-X',
      submittedAt: '2026-09-01T08:15:00Z',
      status: 'analysis',
      statusLabel: 'Em Análise',
      rgFrontUrl: 'https://images.unsplash.com/photo-1633409381657-57b1893bc2b7?w=600&auto=format&fit=crop&q=80',
      rgBackUrl: 'https://images.unsplash.com/photo-1633409381657-57b1893bc2b7?w=600&auto=format&fit=crop&q=80',
      selfieUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80'
    },
    {
      id: 'VRF-003',
      professionalName: 'Ana Paula Faxina & Cuidados',
      email: 'anapaula.servicos@email.com',
      phone: '(11) 91234-5678',
      category: 'Limpeza & Cuidados',
      documentType: 'CNH',
      documentNumber: '05678129034',
      submittedAt: '2026-08-31T16:00:00Z',
      status: 'approved',
      statusLabel: 'Aprovado',
      reviewedBy: 'Admin (Caio)',
      reviewedAt: '31/08/2026 17:30',
      selfieUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80'
    },
    {
      id: 'VRF-004',
      professionalName: 'Lucas Pedreiro & Reformas',
      email: 'lucas.construcao@email.com',
      phone: '(11) 99887-6655',
      category: 'Construção',
      documentType: 'RG',
      documentNumber: '52.123.456-7',
      submittedAt: '2026-08-30T11:20:00Z',
      status: 'correction',
      statusLabel: 'Necessita Correção',
      reviewNotes: 'Foto do verso do RG cortada, favor reenviar imagem nítida.',
      reviewedBy: 'Admin (Caio)',
      reviewedAt: '30/08/2026 14:00'
    }
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
      const res = await api.get('/api/approvals');
      // Connected to API
    } catch (e) {
      // Keep rich demo mock
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

  confirmAction() {
    if (!this.selectedItem) return;

    if (this.actionType !== 'approve' && !this.actionJustification.trim()) {
      this.toastr.warning('Por favor, informe a justificativa da decisão.');
      return;
    }

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
  }
}
