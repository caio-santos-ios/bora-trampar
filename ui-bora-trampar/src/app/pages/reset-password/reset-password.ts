import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './reset-password.html',
  styleUrl: './reset-password.css'
})
export class ResetPassword {
  email = '';
  isSubmitted = false;
  isLoading = false;

  constructor(private toastr: ToastrService) {}

  async onSubmit() {
    if (!this.email) {
      this.toastr.warning('Informe seu e-mail cadastrado.');
      return;
    }

    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
      this.isSubmitted = true;
      this.toastr.success('Link de recuperação enviado com sucesso!');
    }, 800);
  }
}
