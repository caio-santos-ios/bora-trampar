import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface AppointmentItem {
  id: string;
  customerName: string;
  customerPhone: string;
  professionalName: string;
  professionalPhone: string;
  serviceName: string;
  date: string;
  hour: string;
  address: string;
  value: number;
  total_price?: number;
  totalPrice?: number;
  status: 'pending_pix' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'disputed' | string;
  statusLabel: string;
  paymentMethod: string;
  pixTxId?: string;
  createdAt: string;
}

@Component({
  selector: 'app-appointments',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './appointments.html',
  styleUrl: './appointments.css'
})
export class Appointments implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterStatus = 'all';

  selectedItem: AppointmentItem | null = null;
  isDetailsModalOpen = false;

  appointments: AppointmentItem[] = [];

  constructor(
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadAppointments();
  }

  currentPage = 1;
  pageSize = 10;

  get filteredList(): AppointmentItem[] {
    let list = this.appointments || [];

    if (this.filterStatus !== 'all') {
      list = list.filter(item => {
        const s = (item.status || '').toLowerCase().trim();
        return s === this.filterStatus.toLowerCase().trim();
      });
    }

    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      list = list.filter(item =>
        (item.id && item.id.toLowerCase().includes(q)) ||
        (item.customerName && item.customerName.toLowerCase().includes(q)) ||
        (item.professionalName && item.professionalName.toLowerCase().includes(q)) ||
        (item.serviceName && item.serviceName.toLowerCase().includes(q)) ||
        (item.address && item.address.toLowerCase().includes(q))
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

  get paginatedList(): AppointmentItem[] {
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

  getStatusCount(status: string): number {
    if (!this.appointments) return 0;
    if (status === 'all') return this.appointments.length;
    return this.appointments.filter(item => (item.status || '').toLowerCase().trim() === status.toLowerCase().trim()).length;
  }

  normalizeStatus(raw: any, value: number = 0): { status: string; label: string } {
    const s = (raw || '').toString().toLowerCase().replace(/[-_ ]/g, '').trim();

    if (s === 'completed' || s === 'finished' || s === 'done') {
      return { status: 'completed', label: 'Concluído' };
    }
    if (s === 'cancelled' || s === 'canceled' || s === 'cancelledbycustomer' || s === 'declined' || s === 'rejected') {
      return { status: 'cancelled', label: 'Cancelado' };
    }
    if (s === 'inprogress' || s === 'ongoing' || s === 'executing' || s === 'inservice') {
      return { status: 'in_progress', label: 'Em Execução' };
    }
    if (s === 'disputed' || s === 'underreview' || s === 'analysis') {
      return { status: 'disputed', label: 'Contestado' };
    }
    if (s === 'pendingpayment' || s === 'pendingpix' || s === 'pending') {
      if (value === 0) {
        return { status: 'confirmed', label: 'Confirmado' };
      }
      return { status: 'pending_pix', label: 'Pendente Pix' };
    }
    if (s === 'pendingacceptance' || s === 'accepted' || s === 'confirmed' || s === 'approved' || s === 'paid') {
      return { status: 'confirmed', label: 'Confirmado' };
    }

    return { status: 'confirmed', label: 'Confirmado' };
  }

  async loadAppointments() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const response = await api.get('/api/appointments');
      const payload = response.data?.result || response.data?.data || response.data;
      const rawList = Array.isArray(payload)
        ? payload
        : (payload?.data && Array.isArray(payload.data) ? payload.data : []);

      this.appointments = rawList.map((item: any) => {
        const val = item.total_price ?? item.totalPrice ?? item.value ?? 0;
        const numVal = typeof val === 'number' ? val : (parseFloat(val) || 0);
        const { status, label } = this.normalizeStatus(item.status, numVal);

        return {
          id: item.id || (typeof item._id === 'string' ? item._id : (item._id?.$oid || '')),
          customerName: item.customerName || item.customer_name || 'Cliente',
          customerPhone: item.customerPhone || item.customer_phone || item.customerWhatsApp || item.customer_whatsapp || '',
          professionalName: item.professionalName || item.professional_name || 'Profissional',
          professionalPhone: item.professionalPhone || item.professional_phone || item.professionalWhatsApp || item.professional_whatsapp || '',
          serviceName: item.serviceNames || item.service_names || item.serviceName || item.service_name || 'Serviço',
          date: item.date || '',
          hour: item.hour || '',
          address: item.address || '',
          value: numVal,
          total_price: numVal,
          totalPrice: numVal,
          status: status,
          statusLabel: label,
          paymentMethod: item.paymentMethod || item.payment_method || 'PIX',
          pixTxId: item.pixTxId || item.pix_tx_id || item.asaasPaymentId || item.asaas_payment_id || '',
          createdAt: item.createdAt || item.created_at || ''
        };
      });
    } catch {
      this.appointments = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  viewDetails(item: AppointmentItem) {
    this.selectedItem = item;
    this.isDetailsModalOpen = true;
  }

  closeDetailsModal() {
    this.isDetailsModalOpen = false;
  }
}
