import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule, CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface AppointmentItem {
  id: string;
  customerName: string;
  customerPhone?: string;
  professionalName: string;
  professionalPhone?: string;
  serviceName: string;
  service_names?: string;
  category_name?: string;
  date: string;
  hour: string;
  address: string;
  value: number;
  total_price: number;
  totalPrice?: number;
  status: string;
  statusLabel?: string;
  paymentMethod?: string;
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
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadAppointments();
  }

  async loadAppointments() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const response = await api.get('/api/appointments');
      const result = response.data.result;
      const list = result.data || [];
      this.appointments = list.map((item: any) => ({
        ...item,
        customerName: item.customerName || item.customer_name || 'Cliente',
        customerPhone: item.customerPhone || item.customer_phone || '-',
        professionalName: item.professionalName || item.professional_name || 'Profissional',
        professionalPhone: item.professionalPhone || item.professional_phone || '-',
        serviceName: item.serviceName || item.service_names || 'Serviço',
        categoryName: item.categoryName || item.category_name || '',
        total_price: item.total_price ?? item.totalPrice ?? item.value ?? 0,
        value: item.total_price ?? item.totalPrice ?? item.value ?? 0,
        statusLabel: this.getStatusLabel(item.status)
      }));
    } catch {
      this.appointments = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  getStatusLabel(status: string): string {
    const s = (status || '').toLowerCase();
    switch (s) {
      case 'accepted':
      case 'aceito':
      case 'confirmed':
      case 'confirmado':
        return 'Confirmado';
      case 'declined':
      case 'recusado':
      case 'cancelled':
      case 'cancelado':
        return 'Cancelado';
      case 'pendingpayment':
      case 'pending_pix':
      case 'pendente':
        return 'Pendente';
      case 'completed':
      case 'concluido':
        return 'Concluído';
      default:
        return status || 'Pendente';
    }
  }

  get filteredList(): AppointmentItem[] {
    return (this.appointments || []).filter(item => {
      const matchStatus = this.filterStatus === 'all' || item.status === this.filterStatus;
      const matchQuery = !this.searchQuery ||
        (item.id && item.id.toLowerCase().includes(this.searchQuery.toLowerCase())) ||
        (item.customerName && item.customerName.toLowerCase().includes(this.searchQuery.toLowerCase())) ||
        (item.professionalName && item.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase())) ||
        ((item.serviceName || item.service_names) && (item.serviceName || item.service_names || '').toLowerCase().includes(this.searchQuery.toLowerCase()));
      return matchStatus && matchQuery;
    });
  }

  viewDetails(item: AppointmentItem) {
    this.selectedItem = item;
    this.isDetailsModalOpen = true;
  }

  closeDetailsModal() {
    this.isDetailsModalOpen = false;
  }
}
