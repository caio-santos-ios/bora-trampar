import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './landing.html',
  styleUrl: './landing.css'
})
export class Landing {
  readonly features = [
    { number: '01', title: 'Encontre oportunidades', text: 'Conecte profissionais e clientes em um só lugar, com clareza desde o primeiro contato.' },
    { number: '02', title: 'Trabalhe com confiança', text: 'Perfis, serviços e verificações ajudam cada contratação a começar do jeito certo.' },
    { number: '03', title: 'Acompanhe tudo', text: 'Tenha uma visão organizada dos atendimentos, pagamentos e da evolução do seu trabalho.' }
  ];

  readonly faqs = [
    { question: 'O Bora Trampar é para quem?', answer: 'Para profissionais que querem encontrar novos trabalhos e para clientes que procuram contratar com mais segurança e praticidade.' },
    { question: 'Como funciona a verificação?', answer: 'O profissional envia os dados e documentos necessários. A plataforma analisa o cadastro e informa o status antes da liberação para atuar.' },
    { question: 'Preciso pagar para começar?', answer: 'Você pode conhecer a plataforma e criar seu cadastro. As condições de uso aparecem de forma clara durante a jornada.' }
  ];

  openFaq(index: number): void {
    const element = document.getElementById(`faq-${index}`);
    if (!element) return;
    const isOpen = element.classList.toggle('is-open');
    element.querySelector('button')?.setAttribute('aria-expanded', String(isOpen));
  }
}
