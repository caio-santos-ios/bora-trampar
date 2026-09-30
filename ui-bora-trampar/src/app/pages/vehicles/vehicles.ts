import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface VehicleItem {
  id: string;
  professionalId: string;
  professionalName: string;
  professionalEmail: string;
  professionalPhone: string;
  vehicleType: string;
  brand: string;
  model: string;
  year: number;
  plateNumber: string;
  approximateCapacityKg: number;
  dimensions: string;
  photoUrl: string;
  documentUrl: string;
  isDefault: boolean;
  isActive: boolean;
  approvalStatus: 'Pending' | 'Approved' | 'Rejected' | string;
  approvalStatusLabel: string;
  approvalNotes: string;
  createdAt: string;
}

@Component({
  selector: 'app-vehicles',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './vehicles.html',
  styleUrl: './vehicles.css'
})
export class Vehicles implements OnInit {
  isLoading = false;
  filterStatus = 'all';
  searchQuery = '';

  selectedItem: VehicleItem | null = null;
  isModalOpen = false;
  isActionModalOpen = false;
  actionType: 'approve' | 'reject' = 'approve';
  actionJustification = '';

  previewImageUrl: string | null = null;

  vehicles: VehicleItem[] = [];

  currentPage = 1;
  pageSize = 10;

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
      const [resVehicles, resUsers] = await Promise.allSettled([
        api.get('/api/vehicles?limit=500'),
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

      let vehiclesList: any[] = [];
      if (resVehicles.status === 'fulfilled' && resVehicles.value.data) {
        const vPayload = resVehicles.value.data;
        if (Array.isArray(vPayload)) vehiclesList = vPayload;
        else if (Array.isArray(vPayload.result)) vehiclesList = vPayload.result;
        else if (vPayload.result && Array.isArray(vPayload.result.data)) vehiclesList = vPayload.result.data;
        else if (Array.isArray(vPayload.data)) vehiclesList = vPayload.data;
      }

      if (vehiclesList.length > 0) {
        this.vehicles = vehiclesList.map((v: any) => {
          const proId = v.professionalId || v.professional_id || '';
          const user = userMap.get(proId) || {};
          const rawStatus = (v.approvalStatus || v.approval_status || 'Pending').toString();
          const cleanStatus = rawStatus.toLowerCase() === 'approved'
            ? 'Approved'
            : rawStatus.toLowerCase() === 'rejected'
              ? 'Rejected'
              : 'Pending';

          const label = cleanStatus === 'Approved'
            ? 'Aprovado'
            : cleanStatus === 'Rejected'
              ? 'Reprovado'
              : 'Pendente';

          return {
            id: v.id || v._id || '',
            professionalId: proId,
            professionalName: user.name || 'Motorista / Prestador',
            professionalEmail: user.email || 'Não informado',
            professionalPhone: user.whatsApp || user.phone || 'Não informado',
            vehicleType: v.vehicleType || v.vehicle_type || 'Não especificado',
            brand: v.brand || '',
            model: v.model || '',
            year: v.year || 0,
            plateNumber: v.plateNumber || v.plate_number || '',
            approximateCapacityKg: v.approximateCapacityKg || v.approximate_capacity_kg || 0,
            dimensions: v.dimensions || '',
            photoUrl: v.photoUrl || v.photo_url || '',
            documentUrl: v.documentUrl || v.document_url || '',
            isDefault: v.isDefault === true || v.is_default === true,
            isActive: v.isActive !== false && v.is_active !== false,
            approvalStatus: cleanStatus,
            approvalStatusLabel: label,
            approvalNotes: v.approvalNotes || v.approval_notes || '',
            createdAt: v.createdAt || v.created_at || new Date().toISOString()
          };
        });
      } else {
        this.vehicles = [];
      }
    } catch {
      this.vehicles = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): VehicleItem[] {
    return this.vehicles.filter(item => {
      const matchStatus =
        this.filterStatus === 'all' ||
        item.approvalStatus.toLowerCase() === this.filterStatus.toLowerCase();

      const q = this.searchQuery.toLowerCase().trim();
      const matchQuery =
        !q ||
        item.professionalName.toLowerCase().includes(q) ||
        item.brand.toLowerCase().includes(q) ||
        item.model.toLowerCase().includes(q) ||
        item.plateNumber.toLowerCase().includes(q) ||
        item.vehicleType.toLowerCase().includes(q);

      return matchStatus && matchQuery;
    });
  }

  get paginatedList(): VehicleItem[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredList.slice(start, start + this.pageSize);
  }

  get totalPages(): number {
    return Math.ceil(this.filteredList.length / this.pageSize) || 1;
  }

  onFilterChange() {
    this.currentPage = 1;
  }

  openDetails(item: VehicleItem) {
    this.selectedItem = item;
    this.isModalOpen = true;
  }

  closeDetails() {
    this.isModalOpen = false;
  }

  openActionModal(type: 'approve' | 'reject') {
    this.actionType = type;
    this.actionJustification = '';
    this.isActionModalOpen = true;
  }

  closeActionModal() {
    this.isActionModalOpen = false;
  }

  openImagePreview(url: string) {
    if (url) {
      this.previewImageUrl = url;
    }
  }

  closeImagePreview() {
    this.previewImageUrl = null;
  }

  async confirmAction() {
    if (!this.selectedItem) return;

    if (this.actionType === 'reject' && !this.actionJustification.trim()) {
      this.toastr.warning('Por favor, informe o motivo da reprovação do veículo.');
      return;
    }

    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const newStatus = this.actionType === 'approve' ? 'Approved' : 'Rejected';
      const payload: any = {
        id: this.selectedItem.id,
        approvalStatus: newStatus,
        approvalNotes: this.actionJustification
      };

      await api.put('/api/vehicles', payload);

      if (this.actionType === 'approve') {
        this.selectedItem.approvalStatus = 'Approved';
        this.selectedItem.approvalStatusLabel = 'Aprovado';
        this.selectedItem.approvalNotes = this.actionJustification;
        this.toastr.success(`Veículo ${this.selectedItem.brand} ${this.selectedItem.model} aprovado com sucesso!`);
      } else {
        this.selectedItem.approvalStatus = 'Rejected';
        this.selectedItem.approvalStatusLabel = 'Reprovado';
        this.selectedItem.approvalNotes = this.actionJustification;
        this.toastr.error(`Veículo reprovado.`);
      }

      this.closeActionModal();
      this.closeDetails();
      await this.loadData();
    } catch (err: any) {
      const msg = err?.response?.data?.message || err?.message || 'Erro ao atualizar status do veículo.';
      this.toastr.error(msg);
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }
}
