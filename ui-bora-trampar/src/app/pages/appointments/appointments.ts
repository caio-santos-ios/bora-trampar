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
      const response = await api.get('/api/appointments');
      const result = response.data.result;
      this.appointments = result.data;
    } catch {
      this.appointments = [];
    } finally {
      this.isLoading = false;
      this.cdr.detectChanges();
    }
  }

  // get filteredList(): AppointmentItem[] {
  //   return this.appointments.filter(item => {
  //     const matchStatus = this.filterStatus === 'all' || item.status === this.filterStatus;
  //     const matchQuery = !this.searchQuery ||
  //       item.id.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
  //       item.customerName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
  //       item.professionalName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
  //       item.serviceName.toLowerCase().includes(this.searchQuery.toLowerCase());
  //     return matchStatus && matchQuery;
  //   });
  // }

  viewDetails(item: AppointmentItem) {
    this.selectedItem = item;
    this.isDetailsModalOpen = true;
  }

  closeDetailsModal() {
    this.isDetailsModalOpen = false;
  }
}
