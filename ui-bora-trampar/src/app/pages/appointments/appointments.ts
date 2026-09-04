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

  getStatusCount(status: string): number {
    if (!this.appointments) return 0;
    if (status === 'all') return this.appointments.length;
    return this.appointments.filter(item => (item.status || '').toLowerCase().trim() === status.toLowerCase().trim()).length;
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
        const rawStatus = (item.status || 'confirmed').toString().toLowerCase().trim();

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
          status: rawStatus,
          statusLabel: rawStatus === 'completed'
            ? 'Concluído'
            : rawStatus === 'cancelled'
              ? 'Cancelado'
              : rawStatus === 'in_progress'
                ? 'Em Execução'
                : rawStatus === 'pending_pix'
                  ? 'Pendente Pix'
                  : rawStatus === 'disputed'
                    ? 'Contestado'
                    : 'Confirmado',
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
