import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface CustomerAccount {
  id: string;
  name: string;
  email: string;
  phone: string;
  document: string;
  walletBalance: number;
  totalOrders: number;
  status: 'active' | 'blocked' | 'pending';
  statusLabel: string;
  riskScore: 'low' | 'medium' | 'high';
  photo: string;
  createdAt: string;
}

@Component({
  selector: 'app-customers',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './customers.html',
  styleUrl: './customers.css'
})
export class Customers implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterStatus = 'all';

  customers: CustomerAccount[] = [];
  selectedCustomer: CustomerAccount | null = null;
  customerAppointments: any[] = [];
  loadingAppointments = false;

  stats = {
    totalCustomers: 0,
    activeCustomers: 0,
    totalOrders: 0,
    totalWalletBalance: 0
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
      const [usersRes, apptsRes] = await Promise.all([
        api.get('/api/users'),
        api.get('/api/appointments').catch(() => ({ data: { result: [] } }))
      ]);

      const rawUsers = usersRes.data.result?.data || usersRes.data.result || [];
      const rawAppointments = apptsRes.data.result?.data || apptsRes.data.result || [];

      const apptCountByCustomer: { [key: string]: number } = {};
      if (Array.isArray(rawAppointments)) {
        for (const a of rawAppointments) {
          const cId = a.customer_id || a.customerId;
          if (cId) {
            apptCountByCustomer[cId] = (apptCountByCustomer[cId] || 0) + 1;
          }
        }
      }

      this.customers = rawUsers
        .filter((u: any) => {
          const role = (u.role || '').toString().toLowerCase();
          return role !== 'professional' && role !== 'admin' && u.role !== 2 && u.role !== 1;
        })
        .map((u: any) => {
          const cId = u.id || u._id || '';
          const orders = apptCountByCustomer[cId] || u.completedServicesCount || 0;
          const isBlocked = u.isBlocked === true || u.status === 'blocked';
          const balance = typeof u.walletBalance === 'number' ? u.walletBalance : (typeof u.wallet_balance === 'number' ? u.wallet_balance : 0);

          let risk: 'low' | 'medium' | 'high' = 'low';
          if (isBlocked) risk = 'high';
          else if (orders === 0) risk = 'medium';

          return {
            id: cId,
            name: u.name || 'Sem nome',
            email: u.email || 'Não informado',
            phone: u.whatsApp || u.whatsapp || u.phone || 'Não informado',
            document: u.document || 'Não informado',
            walletBalance: balance,
            totalOrders: orders,
            status: isBlocked ? 'blocked' : 'active',
            statusLabel: isBlocked ? 'Bloqueado' : 'Ativo',
            riskScore: risk,
            photo: u.photo || '',
            createdAt: u.createdAt || new Date().toISOString()
          };
        });

      this.calculateStats();
    } catch (error) {
      this.toastr.error('Erro ao carregar lista de clientes');
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  calculateStats() {
    this.stats.totalCustomers = this.customers.length;
    this.stats.activeCustomers = this.customers.filter(c => c.status === 'active').length;
    this.stats.totalOrders = this.customers.reduce((sum, c) => sum + c.totalOrders, 0);
    this.stats.totalWalletBalance = this.customers.reduce((sum, c) => sum + c.walletBalance, 0);
  }

  get filteredList(): CustomerAccount[] {
    let list = this.customers;

    if (this.filterStatus === 'active') {
      list = list.filter(c => c.status === 'active');
    } else if (this.filterStatus === 'blocked') {
      list = list.filter(c => c.status === 'blocked');
    }

    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      list = list.filter(c =>
        c.name.toLowerCase().includes(q) ||
        c.email.toLowerCase().includes(q) ||
        c.phone.toLowerCase().includes(q) ||
        c.document.toLowerCase().includes(q)
      );
    }

    return list;
  }

  async toggleBlock(customer: CustomerAccount) {
    const newStatus = customer.status === 'blocked' ? 'active' : 'blocked';
    const actionLabel = newStatus === 'blocked' ? 'bloquear' : 'desbloquear';

    if (!confirm(`Deseja realmente ${actionLabel} o cliente ${customer.name}?`)) return;

    try {
      await api.put('/api/users', {
        id: customer.id,
        isBlocked: newStatus === 'blocked',
        status: newStatus
      });

      customer.status = newStatus;
      customer.statusLabel = newStatus === 'blocked' ? 'Bloqueado' : 'Ativo';
      customer.riskScore = newStatus === 'blocked' ? 'high' : 'low';
      this.calculateStats();
      this.toastr.success(`Cliente ${customer.name} ${newStatus === 'blocked' ? 'bloqueado' : 'desbloqueado'} com sucesso!`);
    } catch {
      this.toastr.error(`Erro ao ${actionLabel} cliente`);
    }
  }

  async openDetails(customer: CustomerAccount) {
    this.selectedCustomer = customer;
    this.loadingAppointments = true;
    this.customerAppointments = [];

    try {
      const res = await api.get('/api/appointments');
      const all = res.data.result?.data || res.data.result || [];
      if (Array.isArray(all)) {
        this.customerAppointments = all.filter((a: any) => (a.customer_id || a.customerId) === customer.id);
      }
    } catch {
      this.customerAppointments = [];
    } finally {
      this.loadingAppointments = false;
      this.cdr.detectChanges();
    }
  }

  closeDetails() {
    this.selectedCustomer = null;
    this.customerAppointments = [];
  }

  cleanPhone(phone: string): string {
    return phone.replace(/\D/g, '');
  }
}
