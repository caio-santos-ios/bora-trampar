import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';

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

  ngOnInit() {}

  saveSettings() {
    this.isSaving = true;
    this.cdr.detectChanges();

    setTimeout(() => {
      this.isSaving = false;
      this.toastr.success('Configurações salvas com sucesso!');
      this.cdr.detectChanges();
    }, 600);
  }
}
