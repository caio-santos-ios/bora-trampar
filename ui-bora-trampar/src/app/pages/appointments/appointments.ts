import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
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
  status: 'pending_pix' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'disputed';
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
      const [resAppts, resUsers] = await Promise.allSettled([
        api.get('/api/appointments'),
        api.get('/api/users')
      ]);

      const users: any[] = resUsers.status === 'fulfilled' && resUsers.value.data?.result ? resUsers.value.data.result : [];
      const userMap = new Map<string, any>(users.map(u => [u.id || u._id, u]));

      if (resAppts.status === 'fulfilled' && resAppts.value.data?.result && Array.isArray(resAppts.value.data.result)) {
        this.appointments = resAppts.value.data.result.map((apt: any) => {
          const customer = userMap.get(apt.customer_id || apt.customerId) || {};
          const pro = userMap.get(apt.profissional_id || apt.profissionalId) || {};

          let status: any = 'confirmed';
          let statusLabel = 'Confirmado';

          if (apt.status === 2 || apt.status === 'completed') {
            status = 'completed';
            statusLabel = 'Concluído';
          } else if (apt.status === 1 || apt.status === 'cancelled') {
            status = 'cancelled';
            statusLabel = 'Cancelado';
          } else if (apt.status === 'pending_pix' || apt.status === 0) {
            status = 'pending_pix';
            statusLabel = 'Aguardando Pix';
          } else if (apt.status === 'in_progress') {
            status = 'in_progress';
            statusLabel = 'Em Execução';
          } else if (apt.status === 'disputed') {
            status = 'disputed';
            statusLabel = 'Contestado';
          }

          const rawDate = apt.date ? new Date(apt.date) : new Date();
          const formattedDate = !isNaN(rawDate.getTime()) ? rawDate.toLocaleDateString('pt-BR') : 'Data não informada';

          return {
            id: apt.id || apt._id,
            customerName: customer.name || apt.customerName || 'Cliente',
            customerPhone: customer.whatsApp || customer.phone || 'Não informado',
            professionalName: pro.name || apt.professionalName || 'Profissional',
            professionalPhone: pro.whatsApp || pro.phone || 'Não informado',
            serviceName: apt.serviceName || apt.service?.name || 'Serviço Solicitado',
            date: formattedDate,
            hour: apt.hour || 'Horário a combinar',
            address: apt.address || 'Endereço do cliente',
            value: Number(apt.price || apt.value || 150.0),
            status: status,
            statusLabel: statusLabel,
            paymentMethod: 'Pix Instantâneo',
            pixTxId: apt.pixTxId || `PIX-${apt.id || 'E2E'}`,
            createdAt: apt.createdAt || new Date().toISOString()
          };
        });
      } else {
        this.appointments = [];
      }
    } catch {
      this.appointments = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  get filteredList(): AppointmentItem[] {
    return this.appointments.filter(item => {
      const matchStatus = this.filterStatus === 'all' || item.status === this.filterStatus;
      const matchQuery = !this.searchQuery ||
        item.id.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.customerName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.serviceName.toLowerCase().includes(this.searchQuery.toLowerCase());
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
