import { Injectable, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

export interface UserSession {
  id?: string;
  name?: string;
  email?: string;
  role?: string;
}

@Injectable({
  providedIn: 'root'
})
export class Auth {
  private isBrowser: boolean;

  constructor(@Inject(PLATFORM_ID) platformId: Object) {
    this.isBrowser = isPlatformBrowser(platformId);
  }

  setToken(token: string) {
    if (this.isBrowser) {
      localStorage.setItem('token', token);
    }
  }

  getToken(): string | null {
    return this.isBrowser ? localStorage.getItem('token') : null;
  }

  setUser(user: UserSession) {
    if (this.isBrowser) {
      localStorage.setItem('user', JSON.stringify(user));
    }
  }

  getUser(): UserSession | null {
    if (this.isBrowser) {
      const data = localStorage.getItem('user');
      return data ? JSON.parse(data) : null;
    }
    return null;
  }

  clearSession() {
    if (this.isBrowser) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
    }
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }
}
