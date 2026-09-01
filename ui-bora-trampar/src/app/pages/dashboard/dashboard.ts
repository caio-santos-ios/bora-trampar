import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { Chart, registerables } from 'chart.js';
import { GlobalService } from '../../services/global.service';
import { api } from '../../services/api';

Chart.register(...registerables);

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css'
})
export class Dashboard implements OnInit, AfterViewInit {
  @ViewChild('revenueChart') revenueChartRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('categoryChart') categoryChartRef!: ElementRef<HTMLCanvasElement>;

  chart: Chart | null = null;
  donutChart: Chart | null = null;

  stats = {
    totalRevenue: 48920,
    monthAppointments: 284,
    activePros: 142,
    pendingVerifications: 12,
    openDisputes: 2,
    satisfactionRate: 98.6
  };

  recentAppointments: any[] = [
    {
      id: 'APT-1082',
      customer: 'Carlos Eduardo Silva',
      professional: 'Marcos Eletricista',
      service: 'Instalação de Tomadas & Disjuntores',
      date: '01/09/2026 14:00',
      value: 280.0,
      status: 'confirmed',
      statusText: 'Confirmado'
    },
    {
      id: 'APT-1081',
      customer: 'Juliana Mendes',
      professional: 'Cláudio Pintor Profissional',
      service: 'Pintura Residencial Sala',
      date: '01/09/2026 10:30',
      value: 650.0,
      status: 'completed',
      statusText: 'Concluído'
    },
    {
      id: 'APT-1080',
      customer: 'Roberto Fernandes',
      professional: 'Ana Paula Faxina & Cuidados',
      service: 'Limpeza Pós-Obra',
      date: '02/09/2026 08:00',
      value: 320.0,
      status: 'pending',
      statusText: 'Aguardando Pix'
    },
    {
      id: 'APT-1079',
      customer: 'Camila Rodrigues',
      professional: 'Lucas Pedreiro & Reformas',
      service: 'Revestimento e Assentamento de Piso',
      date: '03/09/2026 09:00',
      value: 950.0,
      status: 'confirmed',
      statusText: 'Confirmado'
    }
  ];

  constructor(public global: GlobalService) {}

  ngOnInit() {
    this.fetchData();
  }

  ngAfterViewInit() {
    this.initCharts();
  }

  async fetchData() {
    try {
      // In real mode fetch from /api/categories, /api/services, /api/appointments
      const [resCat, resServ] = await Promise.allSettled([
        api.get('/api/categories'),
        api.get('/api/services')
      ]);
    } catch (e) {
      console.warn('Using dashboard default statistics');
    }
  }

  initCharts() {
    if (this.revenueChartRef) {
      const ctx = this.revenueChartRef.nativeElement.getContext('2d');
      if (ctx) {
        this.chart = new Chart(ctx, {
          type: 'line',
          data: {
            labels: ['Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set'],
            datasets: [
              {
                label: 'Faturamento Pix (R$)',
                data: [18500, 24300, 31200, 39800, 44100, 48920],
                borderColor: '#fdbf0f',
                backgroundColor: 'rgba(253, 191, 15, 0.1)',
                borderWidth: 3,
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#fdbf0f',
                pointRadius: 4
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                labels: { color: '#94a3b8', font: { family: 'Plus Jakarta Sans', weight: 'bold' } }
              }
            },
            scales: {
              x: {
                grid: { color: 'rgba(255, 255, 255, 0.05)' },
                ticks: { color: '#94a3b8' }
              },
              y: {
                grid: { color: 'rgba(255, 255, 255, 0.05)' },
                ticks: {
                  color: '#94a3b8',
                  callback: (value) => 'R$ ' + Number(value) / 1000 + 'k'
                }
              }
            }
          }
        });
      }
    }

    if (this.categoryChartRef) {
      const ctxDonut = this.categoryChartRef.nativeElement.getContext('2d');
      if (ctxDonut) {
        this.donutChart = new Chart(ctxDonut, {
          type: 'doughnut',
          data: {
            labels: ['Construção & Reformas', 'Pintura', 'Eletricista', 'Limpeza', 'Cuidados Infantis'],
            datasets: [
              {
                data: [35, 25, 20, 12, 8],
                backgroundColor: ['#fdbf0f', '#38bdf8', '#4ade80', '#a855f7', '#fb7185'],
                borderWidth: 0
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'bottom',
                labels: { color: '#94a3b8', boxWidth: 12, padding: 12, font: { family: 'Plus Jakarta Sans' } }
              }
            }
          }
        });
      }
    }
  }
}
