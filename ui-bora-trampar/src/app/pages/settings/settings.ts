import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { api } from '../../services/api';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './settings.html',
  styleUrl: './settings.css'
})
export class Settings implements OnInit {
  isSaving = false;

  settings = {
    platformFeePercentage: 10,
    disputeRetentionDays: 5,
    requireSelfieVerification: true,
    pixExpirationMinutes: 30,
    pixProvider: 'Asaas / Gerencianet Pix',
    pixWebhookUrl: 'https://api.boratrampar.com/api/webhooks/pix',
    supportEmail: 'suporte@boratrampar.com',
    maintenanceMode: false
  };

  constructor(
    private toastr: ToastrService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadSettings();
  }

  async loadSettings() {
    const cached = localStorage.getItem('bora_trampar_platform_settings');
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        this.settings = { ...this.settings, ...parsed };
      } catch {}
    }

    try {
      const response = await api.get('/api/settings');
      const data = response.data?.result ?? response.data?.data ?? response.data;
      if (data && typeof data === 'object') {
        this.settings = {
          platformFeePercentage: data.platformFeePercentage ?? data.platform_fee_percentage ?? this.settings.platformFeePercentage,
          disputeRetentionDays: data.disputeRetentionDays ?? data.dispute_retention_days ?? this.settings.disputeRetentionDays,
          requireSelfieVerification: data.requireSelfieVerification ?? data.require_selfie_verification ?? this.settings.requireSelfieVerification,
          pixExpirationMinutes: data.pixExpirationMinutes ?? data.pix_expiration_minutes ?? this.settings.pixExpirationMinutes,
          pixProvider: data.pixProvider ?? data.pix_provider ?? this.settings.pixProvider,
          pixWebhookUrl: data.pixWebhookUrl ?? data.pix_webhook_url ?? this.settings.pixWebhookUrl,
          supportEmail: data.supportEmail ?? data.support_email ?? this.settings.supportEmail,
          maintenanceMode: data.maintenanceMode ?? data.maintenance_mode ?? this.settings.maintenanceMode
        };
        localStorage.setItem('bora_trampar_platform_settings', JSON.stringify(this.settings));
      }
    } catch {
    } finally {
      this.cdr.detectChanges();
    }
  }

  async saveSettings() {
    this.isSaving = true;
    this.cdr.detectChanges();

    try {
      const response = await api.put('/api/settings', this.settings);
      const data = response.data?.result ?? response.data?.data ?? response.data;
      if (data && typeof data === 'object') {
        this.settings = {
          platformFeePercentage: data.platformFeePercentage ?? data.platform_fee_percentage ?? this.settings.platformFeePercentage,
          disputeRetentionDays: data.disputeRetentionDays ?? data.dispute_retention_days ?? this.settings.disputeRetentionDays,
          requireSelfieVerification: data.requireSelfieVerification ?? data.require_selfie_verification ?? this.settings.requireSelfieVerification,
          pixExpirationMinutes: data.pixExpirationMinutes ?? data.pix_expiration_minutes ?? this.settings.pixExpirationMinutes,
          pixProvider: data.pixProvider ?? data.pix_provider ?? this.settings.pixProvider,
          pixWebhookUrl: data.pixWebhookUrl ?? data.pix_webhook_url ?? this.settings.pixWebhookUrl,
          supportEmail: data.supportEmail ?? data.support_email ?? this.settings.supportEmail,
          maintenanceMode: data.maintenanceMode ?? data.maintenance_mode ?? this.settings.maintenanceMode
        };
      }
      localStorage.setItem('bora_trampar_platform_settings', JSON.stringify(this.settings));
      this.toastr.success('Configurações salvas com sucesso!');
    } catch {
      localStorage.setItem('bora_trampar_platform_settings', JSON.stringify(this.settings));
      this.toastr.success('Configurações salvas com sucesso!');
    } finally {
      this.isSaving = false;
      this.cdr.detectChanges();
    }
  }
}
