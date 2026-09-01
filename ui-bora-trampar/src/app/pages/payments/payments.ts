import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface PaymentTransaction {
  id: string;
  txId: string;
  appointmentId: string;
  customerName: string;
  professionalName: string;
  date: string;
  grossValue: number;
  platformFee: number;
  netTransferValue: number;
  status: 'pending' | 'held' | 'released' | 'refunded' | 'expired';
  statusLabel: string;
}

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './payments.html',
  styleUrl: './payments.css'
})
export class Payments implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterStatus = 'all';

  totals = {
    gross: 48920,
    held: 4580,
    released: 41240,
    fees: 3100
  };

  transactions: PaymentTransaction[] = [
    {
      id: 'PAY-901',
      txId: 'PIX-E2E-9841289410',
      appointmentId: 'APT-1082',
      customerName: 'Carlos Eduardo Silva',
      professionalName: 'Marcos Vinícius Eletricista',
      date: '01/09/2026 14:02',
      grossValue: 280.0,
      platformFee: 28.0,
      netTransferValue: 252.0,
      status: 'held',
      statusLabel: 'Retido (Em Execução)'
    },
    {
      id: 'PAY-900',
      txId: 'PIX-E2E-7712093841',
      appointmentId: 'APT-1081',
      customerName: 'Juliana Mendes',
      professionalName: 'Cláudio Silva Pinturas',
      date: '01/09/2026 11:45',
      grossValue: 650.0,
      platformFee: 65.0,
      netTransferValue: 585.0,
      status: 'released',
      statusLabel: 'Repassado'
    },
    {
      id: 'PAY-899',
      txId: 'PIX-E2E-4481029381',
      appointmentId: 'APT-1079',
      customerName: 'Camila Rodrigues',
      professionalName: 'Lucas Pedreiro & Reformas',
      date: '30/08/2026 17:10',
      grossValue: 950.0,
      platformFee: 95.0,
      netTransferValue: 855.0,
      status: 'held',
      statusLabel: 'Retido (Em Execução)'
    },
    {
      id: 'PAY-898',
      txId: 'PIX-E2E-3391028341',
      appointmentId: 'APT-1078',
      customerName: 'Fernando Costa',
      professionalName: 'Lucas Pedreiro & Reformas',
      date: '28/08/2026 09:20',
      grossValue: 480.0,
      platformFee: 48.0,
      netTransferValue: 432.0,
      status: 'held',
      statusLabel: 'Bloqueado (Contestação)'
    },
    {
      id: 'PAY-897',
      txId: 'PIX-E2E-1109283741',
      appointmentId: 'APT-1075',
      customerName: 'Mariana Lima',
      professionalName: 'Ana Paula Faxina',
      date: '27/08/2026 16:30',
      grossValue: 250.0,
      platformFee: 25.0,
      netTransferValue: 225.0,
      status: 'released',
      statusLabel: 'Repassado'
    }
  ];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService
  ) {}

  ngOnInit() {
    this.loadPayments();
  }

  async loadPayments() {
    this.isLoading = true;
    try {
      await api.get('/api/payments');
    } catch {
      // Demo mock fallback
    } finally {
      this.isLoading = false;
    }
  }

  get filteredList(): PaymentTransaction[] {
    return this.transactions.filter(item => {
      const matchStatus = this.filterStatus === 'all' || item.status === this.filterStatus;
      const matchQuery = !this.searchQuery ||
        item.txId.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.customerName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        item.appointmentId.toLowerCase().includes(this.searchQuery.toLowerCase());
      return matchStatus && matchQuery;
    });
  }

  releaseTransfer(item: PaymentTransaction) {
    item.status = 'released';
    item.statusLabel = 'Repassado';
    this.toastr.success(`Repasse de ${this.global.formatCurrency(item.netTransferValue)} liberado para ${item.professionalName}!`);
  }
}
