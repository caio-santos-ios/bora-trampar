import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { Loading } from '../../components/loading/loading';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

export interface UserAccount {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: 'customer' | 'professional' | 'admin';
  roleLabel: string;
  status: 'active' | 'blocked' | 'pending';
  statusLabel: string;
  totalOrders: number;
  riskScore: 'low' | 'medium' | 'high';
  createdAt: string;
}

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, Loading],
  templateUrl: './users.html',
  styleUrl: './users.css'
})
export class Users implements OnInit {
  isLoading = false;
  searchQuery = '';
  filterRole = 'all';

  users: UserAccount[] = [
    {
      id: 'USR-001',
      name: 'Carlos Eduardo Silva',
      email: 'carlos.silva@email.com',
      phone: '(11) 98111-2233',
      role: 'customer',
      roleLabel: 'Cliente',
      status: 'active',
      statusLabel: 'Ativo',
      totalOrders: 6,
      riskScore: 'low',
      createdAt: '2026-07-15T10:00:00Z'
    },
    {
      id: 'USR-002',
      name: 'Marcos Vinícius Eletricista',
      email: 'marcos.eletrica@email.com',
      phone: '(11) 98765-4321',
      role: 'professional',
      roleLabel: 'Profissional',
      status: 'active',
      statusLabel: 'Verificado',
      totalOrders: 42,
      riskScore: 'low',
      createdAt: '2026-06-20T14:30:00Z'
    },
    {
      id: 'USR-003',
      name: 'Fernando Costa',
      email: 'fernando.costa@email.com',
      phone: '(11) 94555-6677',
      role: 'customer',
      roleLabel: 'Cliente',
      status: 'active',
      statusLabel: 'Ativo',
      totalOrders: 2,
      riskScore: 'medium',
      createdAt: '2026-08-10T12:00:00Z'
    },
    {
      id: 'USR-004',
      name: 'Lucas Pedreiro & Reformas',
      email: 'lucas.construcao@email.com',
      phone: '(11) 99887-6655',
      role: 'professional',
      roleLabel: 'Profissional',
      status: 'active',
      statusLabel: 'Verificado',
      totalOrders: 28,
      riskScore: 'low',
      createdAt: '2026-05-18T09:00:00Z'
    },
    {
      id: 'USR-005',
      name: 'Administrador Bora Trampar',
      email: 'admin@boratrampar.com',
      phone: '(11) 90000-0000',
      role: 'admin',
      roleLabel: 'Administrador',
      status: 'active',
      statusLabel: 'Super Admin',
      totalOrders: 0,
      riskScore: 'low',
      createdAt: '2026-01-01T00:00:00Z'
    }
  ];

  constructor(
    private toastr: ToastrService,
    public global: GlobalService
  ) {}

  ngOnInit() {
    this.loadUsers();
  }

  async loadUsers() {
    this.isLoading = true;
    try {
      await api.get('/api/users');
    } catch {
      // Demo mock fallback
    } finally {
      this.isLoading = false;
    }
  }

  get filteredList(): UserAccount[] {
    return this.users.filter(u => {
      const matchRole = this.filterRole === 'all' || u.role === this.filterRole;
      const matchQuery = !this.searchQuery ||
        u.name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        u.email.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        u.phone.includes(this.searchQuery);
      return matchRole && matchQuery;
    });
  }

  toggleBlock(user: UserAccount) {
    if (user.status === 'blocked') {
      user.status = 'active';
      user.statusLabel = 'Ativo';
      this.toastr.success(`Usuário ${user.name} desbloqueado.`);
    } else {
      user.status = 'blocked';
      user.statusLabel = 'Bloqueado';
      this.toastr.warning(`Usuário ${user.name} bloqueado preventivamente.`);
    }
  }
}
