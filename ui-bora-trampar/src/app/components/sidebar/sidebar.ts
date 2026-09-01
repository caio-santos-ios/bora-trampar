import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { Auth, UserSession } from '../../services/auth';
import { ThemeService } from '../../services/theme';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css'
})
export class Sidebar {
  @Input() isOpen: boolean = false;
  @Output() closeSidebar = new EventEmitter<void>();

  user: UserSession | null = null;
  currentTheme: 'light' | 'dark' = 'dark';

  constructor(
    private auth: Auth,
    private router: Router,
    public themeService: ThemeService
  ) {
    this.user = this.auth.getUser() || { name: 'Administrador', email: 'admin@boratrampar.com', role: 'admin' };
    this.currentTheme = this.themeService.getTheme();
  }

  toggleTheme() {
    this.currentTheme = this.themeService.toggleTheme();
  }

  logout() {
    this.auth.clearSession();
    this.router.navigate(['/login']);
  }

  onNavigate() {
    this.closeSidebar.emit();
  }
}
