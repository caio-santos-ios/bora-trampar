import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Bora Trampa — Profissionais por diária',
  description: 'Conecte profissionais e clientes para fazer o trabalho acontecer.',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
