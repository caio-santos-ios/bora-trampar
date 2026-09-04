import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class GlobalService {
  formatCurrency(value: number | string): string {
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) return 'R$ 0,00';
    return num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  }

  formatDate(dateStr: string | Date): string {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  }

  formatDateTime(dateStr: string | Date): string {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  normalizeStatus(status: string): string {
    switch ((status || '').toLowerCase().trim()) {
      case 'pending':
      case 'pending_pix':
        return 'Pendente';
      case 'confirmed':
      case 'accepted':
        return 'Confirmado';
      case 'in_progress':
      case 'ongoing':
        return 'Em Andamento';
      case 'completed':
      case 'finished':
        return 'Concluído';
      case 'cancelled':
      case 'canceled':
        return 'Cancelado';
      case 'rejected':
        return 'Recusado';
      case 'disputed':
        return 'Em Disputa';
      case 'active':
        return 'Ativo';
      case 'blocked':
        return 'Bloqueado';
      default:
        return status || 'Pendente';
    }
  }
}
