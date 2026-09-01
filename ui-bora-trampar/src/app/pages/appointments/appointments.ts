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

  appointments: AppointmentItem[] = [
    {
      id: 'APT-1082',
      customerName: 'Carlos Eduardo Silva',
      customerPhone: '(11) 98111-2233',
      professionalName: 'Marcos Vinícius Eletricista',
      professionalPhone: '(11) 98765-4321',
      serviceName: 'Instalação de Tomadas & Disjuntores',
      date: '01/09/2026',
      hour: '14:00',
      address: 'Rua das Flores, 120 - Apto 42, Jardins, São Paulo/SP',
      value: 280.0,
      status: 'confirmed',
      statusLabel: 'Confirmado',
      paymentMethod: 'Pix (Aprovado)',
      pixTxId: 'PIX-E2E-9841289410',
      createdAt: '2026-09-01T08:30:00Z'
    },
    {
      id: 'APT-1081',
      customerName: 'Juliana Mendes',
      customerPhone: '(11) 97222-3344',
      professionalName: 'Cláudio Silva Pinturas',
      professionalPhone: '(11) 97654-3210',
      serviceName: 'Pintura Completa de Sala e Corredor',
      date: '01/09/2026',
      hour: '10:30',
      address: 'Av. Paulista, 1578 - Bela Vista, São Paulo/SP',
      value: 650.0,
      status: 'completed',
      statusLabel: 'Concluído',
      paymentMethod: 'Pix (Repassado)',
      pixTxId: 'PIX-E2E-7712093841',
      createdAt: '2026-08-31T14:10:00Z'
    },
    {
      id: 'APT-1080',
      customerName: 'Roberto Fernandes',
      customerPhone: '(11) 96333-4455',
      professionalName: 'Ana Paula Faxina & Cuidados',
      professionalPhone: '(11) 91234-5678',
      serviceName: 'Limpeza e Faxina Pós-Obra',
      date: '02/09/2026',
      hour: '08:00',
      address: 'Rua Augusta, 900 - Consolação, São Paulo/SP',
      value: 320.0,
      status: 'pending_pix',
      statusLabel: 'Aguardando Pix',
      paymentMethod: 'Pix (Pendente)',
      pixTxId: 'PIX-E2E-Pending',
      createdAt: '2026-09-01T10:15:00Z'
    },
    {
      id: 'APT-1079',
      customerName: 'Camila Rodrigues',
      customerPhone: '(11) 95444-5566',
      professionalName: 'Lucas Pedreiro & Reformas',
      professionalPhone: '(11) 99887-6655',
      serviceName: 'Assentamento de Porcelanato 60x60',
      date: '03/09/2026',
      hour: '09:00',
      address: 'Rua Oscar Freire, 340 - Cerqueira César, São Paulo/SP',
      value: 950.0,
      status: 'in_progress',
      statusLabel: 'Em Execução',
      paymentMethod: 'Pix (Retido)',
      pixTxId: 'PIX-E2E-4481029381',
      createdAt: '2026-08-30T17:00:00Z'
    },
    {
      id: 'APT-1078',
      customerName: 'Fernando Costa',
      customerPhone: '(11) 94555-6677',
      professionalName: 'Lucas Pedreiro & Reformas',
      professionalPhone: '(11) 99887-6655',
      serviceName: 'Troca de Piso Banheiro',
      date: '28/08/2026',
      hour: '11:00',
      address: 'Rua Vergueiro, 2000 - Vila Mariana, São Paulo/SP',
      value: 480.0,
      status: 'disputed',
      statusLabel: 'Contestado',
      paymentMethod: 'Pix (Bloqueado p/ Análise)',
      pixTxId: 'PIX-E2E-3391028341',
      createdAt: '2026-08-28T09:00:00Z'
    }
  ];

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
      const res = await api.get('/api/appointments');
      if (res.data?.result && Array.isArray(res.data.result) && res.data.result.length > 0) {
        // Map backend appointments if present
      }
    } catch {
      // Demo mock fallback
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
