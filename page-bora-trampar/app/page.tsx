'use client';

import Link from 'next/link';
import { useState } from 'react';

const features = [
  ['01', 'Encontre oportunidades', 'Conecte profissionais e clientes em um só lugar, com clareza desde o primeiro contato.'],
  ['02', 'Trabalhe com confiança', 'Perfis, serviços e verificações ajudam cada contratação a começar do jeito certo.'],
  ['03', 'Acompanhe tudo', 'Tenha uma visão organizada dos atendimentos, pagamentos e da evolução do seu trabalho.'],
];
const faqs = [
  ['O Bora Trampa é para quem?', 'Para profissionais que querem encontrar novos trabalhos e para clientes que procuram contratar com mais segurança e praticidade.'],
  ['Como funciona a verificação?', 'O profissional envia os dados e documentos necessários. A plataforma analisa o cadastro e informa o status antes da liberação para atuar.'],
  ['Preciso pagar para começar?', 'Você pode conhecer a plataforma e criar seu cadastro. As condições de uso aparecem de forma clara durante a jornada.'],
];

function Brand() { return <Link className="brand" href="/"><img src="/logo-bora-trampar.jpeg" alt="Bora Trampa" /></Link>; }
function DashboardMockup() { return <div className="visual"><div className="orbit one" /><div className="orbit two" /><div className="dashboard"><div className="dash-top"><b>BT</b><span>Visão geral</span><i>CS</i></div><small>Bom dia, Caio</small><h3>Vamos trampar?</h3><div className="stats"><div><small>Trabalhos este mês</small><strong>24</strong><em>+18%</em></div><div><small>A receber</small><strong>R$ 3.840</strong><em>próximo: hoje</em></div></div><div className="dash-title">Próximos trabalhos <span>Ver todos ↗</span></div>{['Identidade visual|Hoje, 14:30 · Remoto|R$ 850','Manutenção elétrica|Amanhã, 09:00 · São Paulo|R$ 320','Fotografia de produto|18 set · Campinas|R$ 640'].map((row) => { const [title, sub, price] = row.split('|'); return <div className="job" key={title}><i>✦</i><div><b>{title}</b><small>{sub}</small></div><strong>{price}</strong></div>; })}</div><div className="floating rating">★ <b>4.9</b><small>avaliação média</small></div><div className="floating secure">✓ <b>Perfil verificado</b><small>Mais confiança para fechar</small></div></div>; }

export default function Home() {
  const [openFaq, setOpenFaq] = useState<number | null>(null);
  return <main className="site-shell">
    <nav className="nav"><Brand /><div className="nav-links"><a href="#como-funciona">Como funciona</a><a href="#para-quem">Para quem é</a><a href="#duvidas">Dúvidas</a></div><div className="nav-actions"><Link href="/login" className="login">Entrar</Link><a className="button small" href="#comece">Criar conta <span>↗</span></a></div></nav>
    <section className="hero section"><div className="hero-copy"><div className="eyebrow"><i /> Trabalho bom começa com conexão</div><h1>Seu próximo trabalho <em>começa aqui.</em></h1><p>Uma plataforma para quem faz acontecer. Encontre oportunidades, mostre seu trabalho e conecte-se com clientes que valorizam o que você faz.</p><div className="hero-actions"><a className="button" href="#comece">Quero trampar <span>↗</span></a><a className="under-link" href="#como-funciona">Entenda como funciona <span>↓</span></a></div><div className="hero-note"><span>J</span><span>M</span><span>R</span><p>Feito para profissionais reais<br /><b>que querem crescer</b></p></div></div><DashboardMockup /></section>
    <div className="ticker">ENCONTRE OPORTUNIDADES <b>✳</b> MOSTRE SEU TALENTO <b>✳</b> FAÇA ACONTECER <b>✳</b> ENCONTRE OPORTUNIDADES <b>✳</b></div>
    <section className="section intro" id="para-quem"><div className="eyebrow">Por que o Bora Trampa?</div><div className="intro-heading"><h2>Menos procura.<br /><em>Mais trabalho.</em></h2><p>O mercado está cheio de gente boa. O que faltava era um lugar que aproximasse talento e oportunidade de um jeito simples, seguro e direto.</p></div><div className="feature-grid">{features.map(([n, title, text]) => <article className="feature" key={n}><small>{n}</small><b>↗</b><h3>{title}</h3><p>{text}</p><a href="#comece">Saiba mais ↗</a></article>)}</div></section>
    <section className="split section" id="como-funciona"><div><div className="eyebrow gold">Feito para a vida real</div><h2>Você faz o trabalho.<br /><em>A gente abre o caminho.</em></h2><p>Do primeiro cadastro ao trabalho entregue, o Bora Trampa tira o ruído da frente e deixa você focar no que sabe fazer melhor.</p><a className="button" href="#comece">Começar agora <span>↗</span></a></div><div className="steps">{[['01','Crie seu perfil','Conte quem você é, o que faz e mostre seus melhores trabalhos.'],['02','Encontre seu match','Descubra oportunidades que combinam com suas habilidades e sua rotina.'],['03','Feche e faça acontecer','Combine os detalhes, realize um bom trabalho e construa sua reputação.']].map(([n,t,p]) => <div className="step" key={n}><small>{n}</small><div><h3>{t}</h3><p>{p}</p></div><b>+</b></div>)}</div></section>
    <section className="quote section"><strong>“</strong><blockquote>Trabalho bom não deveria depender de sorte. Deveria depender de conexão.</blockquote><p><span>A</span><b>Ana Martins<small>Profissional autônoma</small></b></p></section>
    <section className="faq section" id="duvidas"><div className="eyebrow gold">Ainda ficou com dúvida?</div><div className="intro-heading"><h2>Perguntas que a gente<br /><em>ouve bastante.</em></h2><p>Se não encontrou o que procurava, fala com a gente. Estamos aqui para ajudar.</p></div><div className="faq-list">{faqs.map(([q,a], i) => <div className={`faq-item ${openFaq === i ? 'open' : ''}`} key={q}><button onClick={() => setOpenFaq(openFaq === i ? null : i)} aria-expanded={openFaq === i}><span>{q}</span><b>+</b></button><p>{a}</p></div>)}</div></section>
    <section className="cta section" id="comece"><div className="eyebrow gold">Seu próximo passo</div><h2>Tem trabalho para fazer?<br /><em>Bora trampar.</em></h2><p>Crie seu perfil gratuitamente e comece a encontrar as oportunidades que combinam com você.</p><a className="button dark" href="mailto:contato@boratrampar.com.br?subject=Quero%20trampar">Quero fazer acontecer <span>↗</span></a></section>
    <footer className="footer"><Brand /><p>Conexões que colocam o trabalho em movimento.</p><div><a href="#como-funciona">Como funciona</a><a href="#duvidas">Dúvidas</a><Link href="/termos-uso">Termos de uso</Link><Link href="/politica-privacidade">Privacidade</Link></div><small>© 2026 Bora Trampa. Feito no Brasil.</small></footer>
  </main>;
}
