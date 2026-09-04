import { Routes } from '@angular/router';
import { DashboardLayout } from './layouts/dashboard-layout/dashboard-layout';
import { Dashboard } from './pages/dashboard/dashboard';
import { Verifications } from './pages/verifications/verifications';
import { Categories } from './pages/categories/categories';
import { Services } from './pages/services/services';
import { Appointments } from './pages/appointments/appointments';
import { Payments } from './pages/payments/payments';
import { Disputes } from './pages/disputes/disputes';
import { Users } from './pages/users/users';
import { Customers } from './pages/customers/customers';
import { Professionals } from './pages/professionals/professionals';
import { Settings } from './pages/settings/settings';
import { Profile } from './pages/profile/profile';
import { Login } from './pages/login/login';
import { ResetPassword } from './pages/reset-password/reset-password';
import { Confirmation } from './pages/confirmation/confirmation';
import { AuthGuard } from './guards/auth-guard';

export const routes: Routes = [
  { path: 'login', component: Login },
  { path: 'reset-password', component: ResetPassword },
  { path: 'confirmation/:code/:device', component: Confirmation },
  { path: 'confirmation/:code', component: Confirmation },
  {
    path: '',
    component: DashboardLayout,
    canActivate: [AuthGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: Dashboard },
      { path: 'verifications', component: Verifications },
      { path: 'categories', component: Categories },
      { path: 'services', component: Services },
      { path: 'appointments', component: Appointments },
      { path: 'payments', component: Payments },
      { path: 'disputes', component: Disputes },
      { path: 'customers', component: Customers },
      { path: 'professionals', component: Professionals },
      { path: 'users', component: Users },
      { path: 'settings', component: Settings },
      { path: 'profile', component: Profile }
    ]
  },
  { path: '**', redirectTo: 'dashboard' }
];
