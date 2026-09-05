import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface ProfessionalData {
  id: string;
  userId: string;
  name: string;
  email: string;
  phone: string;
  profession: string;
  rating: number;
  reviewCount: number;
  basePrice: number;
  completedServicesCount: number;
  region: string;
  radiusKm: number;
  avatarUrl: string;
  photo: string;
  bio: string;
  services: string[];
  isAvailable: boolean;
  verificationStatus: 'approved' | 'pending' | 'rejected' | 'not_sent';
  verificationStatusLabel: string;
  status: 'active' | 'blocked';
  statusLabel: string;
  createdAt: string;
}

@Component({
  selector: 'app-professionals',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './professionals.html',
  styleUrl: './professionals.css'
})
export class Professionals implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterStatus = 'all';

  professionals: ProfessionalData[] = [];
  selectedPro: ProfessionalData | null = null;
  proAppointments: any[] = [];
  loadingAppointments = false;

  stats = {
    totalPros: 0,
    activePros: 0,
    verifiedPros: 0,
    unverifiedPros: 0,
    pendingPros: 0,
    avgRating: 0
  };

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
      const [usersRes, profilesRes, apptsRes, approvalsRes] = await Promise.all([
        api.get('/api/users'),
        api.get('/api/profile-professionals').catch(() => ({ data: { result: [] } })),
        api.get('/api/appointments').catch(() => ({ data: { result: [] } })),
        api.get('/api/approvals').catch(() => ({ data: { result: [] } }))
      ]);

      const rawUsers = usersRes.data.result?.data || usersRes.data.result || [];
      const rawProfiles = profilesRes.data.result?.data || profilesRes.data.result || [];
      const rawAppointments = apptsRes.data.result?.data || apptsRes.data.result || [];
      const rawApprovals = approvalsRes.data?.result?.data || approvalsRes.data?.result || approvalsRes.data || [];

      const approvalMap: { [key: string]: any } = {};
      if (Array.isArray(rawApprovals)) {
        for (const a of rawApprovals) {
          const pId = (a.profissional_id || a.profissionalId || a.userId || '').toString();
          if (pId) approvalMap[pId] = a;
        }
      }

      const profileMap: { [key: string]: any } = {};
      if (Array.isArray(rawProfiles)) {
        for (const p of rawProfiles) {
          if (p.userId) profileMap[p.userId.toString()] = p;
          if (p.user_id) profileMap[p.user_id.toString()] = p;
          if (p.id) profileMap[p.id.toString()] = p;
          if (p._id) profileMap[p._id.toString()] = p;
        }
      }

      const apptCountByPro: { [key: string]: number } = {};
      if (Array.isArray(rawAppointments)) {
        for (const a of rawAppointments) {
          const pId = a.profissional_id || a.profissionalId;
          if (pId) {
            apptCountByPro[pId] = (apptCountByPro[pId] || 0) + 1;
          }
        }
      }

      this.professionals = rawUsers
        .filter((u: any) => {
          const role = (u.role || '').toString().toLowerCase();
          return role.includes('prof') || role.includes('prestador') || u.role === 2;
        })
        .map((u: any) => {
          const uId = u.id || u._id || '';
          const prof = profileMap[uId] || {};
          const approval = approvalMap[uId] || (prof.userId && approvalMap[prof.userId.toString()]) || {};
          const approvalStatus = (approval.status || (approval.approved ? 'approved' : '')).toString().toLowerCase().trim();
          const profStatus = (prof.identityVerificationStatus || prof.identity_verification_status || '').toString().toLowerCase().trim();
          const isBlocked = u.blocked === true || u.blocked === 'true' || u.isBlocked === true || u.isBlocked === 'true' || u.deleted === true || u.status === 'blocked' || u.active === false;

          let verStatus: 'approved' | 'pending' | 'rejected' | 'not_sent' = 'not_sent';
          let verLabel = 'Não Verificado';

          if (
            approval.approved === true ||
            approvalStatus === 'approved' ||
            approvalStatus === 'approve' ||
            profStatus === 'approved' ||
            prof.isVerified === true ||
            u.isVerified === true
          ) {
            verStatus = 'approved';
            verLabel = 'Verificado';
          } else if (
            approvalStatus === 'analysis' ||
            approvalStatus === 'pending' ||
            profStatus === 'pending' ||
            prof.identityDocumentFrontUrl ||
            prof.identityFrontUrl ||
            prof.identityBackUrl ||
            prof.identityDocumentBackUrl ||
            prof.identitySelfieUrl ||
            prof.selfieUrl
          ) {
            verStatus = 'pending';
            verLabel = 'Em Análise';
          } else if (approvalStatus === 'rejected' || profStatus === 'rejected') {
            verStatus = 'rejected';
            verLabel = 'Reprovado';
          }

          const rawBasePrice = prof.dailyRate || prof.basePrice || u.dailyRate || u.basePrice || u.price || 0;
          const price = typeof rawBasePrice === 'number' ? rawBasePrice : (parseFloat(rawBasePrice) || 0);

          const servicesList: string[] = [];
          if (Array.isArray(prof.services)) {
            for (const s of prof.services) {
              const sName = s.serviceName || s.name || s.title;
              if (sName) servicesList.push(sName);
            }
          }

          const city = prof.address?.city || u.city || '';
          const state = prof.address?.state || u.state || '';
          const regionStr = [city, state].filter(Boolean).join(', ') || 'Não informada';

          return {
            id: prof.id || uId,
            userId: uId,
            name: u.name || prof.name || 'Sem nome',
            email: u.email || 'Não informado',
            phone: u.whatsApp || u.whatsapp || u.phone || 'Não informado',
            profession: prof.profession || u.profession || 'Prestador de Serviços',
            rating: prof.rating || u.rating || 5.0,
            reviewCount: prof.reviewCount || u.reviewCount || 0,
            basePrice: price,
            completedServicesCount: apptCountByPro[uId] || u.completedServicesCount || 0,
            region: regionStr,
            radiusKm: prof.address?.serviceRadiusKm || 25,
            avatarUrl: (u.photo || '').trim(),
            photo: (u.photo || '').trim(),
            bio: prof.bio || u.bio || '',
            services: servicesList,
            isAvailable: prof.isAvailableNow ?? true,
            verificationStatus: verStatus,
            verificationStatusLabel: verLabel,
            status: isBlocked ? 'blocked' : 'active',
            statusLabel: isBlocked ? 'Bloqueado' : 'Ativo',
            createdAt: u.createdAt || new Date().toISOString()
          };
        });

      this.calculateStats();
    } catch (error) {
      this.toastr.error('Erro ao carregar lista de profissionais');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  calculateStats() {
    this.stats.totalPros = this.professionals.length;
    this.stats.activePros = this.professionals.filter(p => p.status === 'active').length;
    this.stats.verifiedPros = this.professionals.filter(p => p.verificationStatus === 'approved').length;
    this.stats.pendingPros = this.professionals.filter(p => p.verificationStatus === 'pending').length;
    this.stats.unverifiedPros = this.professionals.filter(p => p.verificationStatus !== 'approved').length;

    const ratedPros = this.professionals.filter(p => p.rating > 0);
    this.stats.avgRating = ratedPros.length > 0
      ? Number((ratedPros.reduce((sum, p) => sum + p.rating, 0) / ratedPros.length).toFixed(1))
      : 5.0;
  }

  currentPage = 1;
  pageSize = 10;

  get filteredList(): ProfessionalData[] {
    let list = this.professionals;

    if (this.filterStatus === 'verified') {
      list = list.filter(p => p.verificationStatus === 'approved');
    } else if (this.filterStatus === 'unverified') {
      list = list.filter(p => p.verificationStatus !== 'approved');
    } else if (this.filterStatus === 'pending') {
      list = list.filter(p => p.verificationStatus === 'pending');
    } else if (this.filterStatus === 'blocked') {
      list = list.filter(p => p.status === 'blocked');
    }

    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      list = list.filter(p =>
        p.name.toLowerCase().includes(q) ||
        p.profession.toLowerCase().includes(q) ||
        p.email.toLowerCase().includes(q) ||
        p.phone.toLowerCase().includes(q) ||
        p.region.toLowerCase().includes(q)
      );
    }

    return list;
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

  get paginatedList(): ProfessionalData[] {
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

  proToBlock: ProfessionalData | null = null;
  isBlockModalOpen = false;

  openBlockModal(pro: ProfessionalData) {
    this.proToBlock = pro;
    this.isBlockModalOpen = true;
    this.cdr.detectChanges();
  }

  closeBlockModal() {
    this.proToBlock = null;
    this.isBlockModalOpen = false;
    this.cdr.detectChanges();
  }

  async executeBlock() {
    if (!this.proToBlock) return;
    const pro = this.proToBlock;
    const isBlocking = pro.status !== 'blocked';
    const newStatus = isBlocking ? 'blocked' : 'active';
    const actionLabel = isBlocking ? 'bloquear' : 'desbloquear';

    try {
      await api.put('/api/users', {
        id: pro.userId,
        name: pro.name,
        email: pro.email,
        blocked: isBlocking
      });

      pro.status = newStatus;
      pro.statusLabel = isBlocking ? 'Bloqueado' : 'Ativo';
      this.calculateStats();
      this.toastr.success(`Profissional ${pro.name} ${isBlocking ? 'bloqueado' : 'desbloqueado'} com sucesso!`);
    } catch {
      this.toastr.error(`Erro ao ${actionLabel} profissional`);
    } finally {
      this.closeBlockModal();
      this.cdr.detectChanges();
    }
  }

  async openDetails(pro: ProfessionalData) {
    this.selectedPro = pro;
    this.loadingAppointments = true;
    this.proAppointments = [];

    try {
      const res = await api.get('/api/appointments');
      const all = res.data.result?.data || res.data.result || [];
      if (Array.isArray(all)) {
        this.proAppointments = all.filter((a: any) =>
          (a.profissional_id || a.profissionalId) === pro.userId ||
          (a.profissional_id || a.profissionalId) === pro.id
        );
      }
    } catch {
      this.proAppointments = [];
    } finally {
      this.loadingAppointments = false;
      this.cdr.detectChanges();
    }
  }

  closeDetails() {
    this.selectedPro = null;
    this.proAppointments = [];
  }

  cleanPhone(phone: string): string {
    return phone.replace(/\D/g, '');
  }
}
