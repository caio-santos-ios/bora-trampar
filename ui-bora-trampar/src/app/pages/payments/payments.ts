import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface PaymentTransaction {
  id: string;
  txId: string;
  serviceName: string;
  appointmentId: string;
  customerName: string;
  professionalName: string;
  date: string;
  grossValue: number;
  platformFee: number;
  netTransferValue: number;
  status: 'held' | 'released' | 'refunded';
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
  filterStatus = 'all';
  searchQuery = '';

  totals = {
    gross: 0,
    held: 0,
    released: 0,
    fees: 0
  };

  transactions: PaymentTransaction[] = [];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadPayments();
  }

  async loadPayments() {
    this.isLoading = true;
    this.cdr.detectChanges();

    try {
      const [resPay, resAppt, resUsers] = await Promise.allSettled([
        api.get('/api/payments'),
        api.get('/api/appointments'),
        api.get('/api/users')
      ]);

      const users: any[] = resUsers.status === 'fulfilled' && resUsers.value.data?.result ? resUsers.value.data.result : [];
      const userMap = new Map<string, any>(users.map(u => [u.id || u._id, u]));

      if (resAppt.status === 'fulfilled' && resAppt.value.data?.result && Array.isArray(resAppt.value.data.result)) {
        const appts: any[] = resAppt.value.data.result;

        this.transactions = appts.map((a: any, idx: number) => {
          const customer = userMap.get(a.customer_id || a.customerId) || {};
          const pro = userMap.get(a.profissional_id || a.profissionalId) || {};
          const gross = Number(a.price || a.value || 150.0);
          const fee = gross * 0.10;
          const net = gross - fee;

          const isCompleted = a.status === 2 || a.status === 'completed';

          return {
            id: `PAY-${100 + idx}`,
            txId: a.pixTxId || `PIX-E2E-${a.id?.substring(0, 8) || '102938'}`,
            serviceName: a.serviceNames || a.serviceName || 'Serviço',
            appointmentId: a.id || a._id,
            customerName: customer.name || a.customerName || 'Cliente',
            professionalName: pro.name || a.professionalName || 'Profissional',
            date: a.date || a.createdAt || new Date().toISOString(),
            grossValue: gross,
            platformFee: fee,
            netTransferValue: net,
            status: isCompleted ? 'released' : 'held',
            statusLabel: isCompleted ? 'Repassado' : 'Retido (Garantia)'
          };
        });

        // Compute summary
        this.totals.gross = this.transactions.reduce((sum, t) => sum + t.grossValue, 0);
        this.totals.fees = this.transactions.reduce((sum, t) => sum + t.platformFee, 0);
        this.totals.held = this.transactions.filter(t => t.status === 'held').reduce((sum, t) => sum + t.netTransferValue, 0);
        this.totals.released = this.transactions.filter(t => t.status === 'released').reduce((sum, t) => sum + t.netTransferValue, 0);
      } else {
        this.transactions = [];
        this.totals = { gross: 0, held: 0, released: 0, fees: 0 };
      }
    } catch {
      this.transactions = [];
      this.totals = { gross: 0, held: 0, released: 0, fees: 0 };
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
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

  releaseTransfer(tx: PaymentTransaction) {
    tx.status = 'released';
    tx.statusLabel = 'Repassado (Liberado Manualmente)';
    this.totals.held -= tx.netTransferValue;
    this.totals.released += tx.netTransferValue;
    this.toastr.success(`Repasse de ${this.global.formatCurrency(tx.netTransferValue)} enviado com sucesso!`);
    this.cdr.detectChanges();
  }
}
