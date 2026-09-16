'use client';

import { useState } from 'react';

const navItems = [
  ['Visão geral', '⌂'],
  ['Agendamentos', '▣'],
  ['Profissionais', '♙'],
  ['Clientes', '◎'],
  ['Verificações', '✓'],
  ['Contestações', '◈'],
  ['Pagamentos', 'R$'],
];

const appointments = [
  ['Mariana Costa', 'Rafael Lima', 'Instalação elétrica', 'Hoje, 14:30', 'R$ 850', 'Confirmado'],
  ['Studio Aurora', 'Camila Souza', 'Identidade visual', 'Hoje, 16:00', 'R$ 1.200', 'Em análise'],
  ['João Mendes', 'Bruno Alves', 'Manutenção hidráulica', 'Amanhã, 09:00', 'R$ 320', 'Confirmado'],
  ['Ateliê 21', 'Ana Martins', 'Fotografia de produto', '18 set, 10:30', 'R$ 640', 'Pendente'],
];

const categoryBars = [
  ['Construção e manutenção', 68, '#fdbf0f'],
  ['Design e criação', 54, '#38bdf8'],
  ['Eventos e fotografia', 41, '#4ade80'],
  ['Serviços gerais', 29, '#a78bfa'],
];

function Brand() {
  return <div className="admin-brand"><img src="/logo-bora-trampar-crop.png" alt="Bora Trampa" /></div>;
}

export default function Home() {
  const [active, setActive] = useState('Visão geral');
  const [period, setPeriod] = useState('Últimos 6 meses');
  const [menuOpen, setMenuOpen] = useState(false);

  return <main className="admin-shell">
    <aside className={`admin-sidebar ${menuOpen ? 'is-open' : ''}`}>
      <div className="sidebar-top"><Brand /><button className="close-menu" onClick={() => setMenuOpen(false)}>×</button></div>
      <div className="workspace"><span className="workspace-avatar">BT</span><div><b>Bora Trampa</b><small>Administração</small></div><span className="workspace-chevron">⌄</span></div>
      <p className="nav-label">PLATAFORMA</p>
      <nav className="admin-nav">{navItems.map(([label, icon]) => <button className={active === label ? 'active' : ''} key={label} onClick={() => { setActive(label); setMenuOpen(false); }}><span className="nav-icon">{icon}</span><span>{label}</span>{label === 'Verificações' && <em>12</em>}{label === 'Contestações' && <em className="red">3</em>}</button>)}</nav>
      <div className="sidebar-spacer" />
      <p className="nav-label">SISTEMA</p>
      <nav className="admin-nav"><button className={active === 'Configurações' ? 'active' : ''} onClick={() => setActive('Configurações')}><span className="nav-icon">⚙</span><span>Configurações</span></button><button onClick={() => setActive('Ajuda')}><span className="nav-icon">?</span><span>Central de ajuda</span></button></nav>
      <div className="admin-user"><span className="user-avatar">CS</span><div><b>Caio Santos</b><small>Administrador</small></div><span>•••</span></div>
    </aside>

    <section className="admin-content">
      <header className="admin-header"><button className="mobile-menu" onClick={() => setMenuOpen(true)}>☰</button><div className="breadcrumb">Administração <span>/</span> <b>{active}</b></div><div className="header-tools"><button className="icon-button" aria-label="Notificações">♧<i>4</i></button><span className="header-divider" /><span className="header-date">Sexta-feira, 15 de setembro de 2026</span></div></header>
      <div className="admin-main">
        <div className="admin-title-row"><div><p className="admin-eyebrow">PAINEL ADMINISTRATIVO</p><h1>Visão geral da plataforma</h1><p className="admin-subtitle">Acompanhe operações, transações e a saúde do Bora Trampa em tempo real.</p></div><div className="title-actions"><button className="outline-button">↓ Exportar relatório</button><button className="primary-button" onClick={() => setActive('Verificações')}>Analisar pendências <span>12</span></button></div></div>
        <div className="alert-strip"><span className="alert-symbol">!</span><div><b>12 profissionais aguardam verificação</b><small>Revise os documentos para liberar novos perfis na plataforma.</small></div><button onClick={() => setActive('Verificações')}>Ver pendências →</button></div>
        <div className="admin-kpis"><article className="admin-kpi highlight"><div className="kpi-top"><span>Faturamento total Pix</span><i>↗ 18,4%</i></div><strong>R$ 48.320,00</strong><small>Volume acumulado · este mês</small><div className="sparkline gold"><span style={{height:'30%'}}/><span style={{height:'42%'}}/><span style={{height:'35%'}}/><span style={{height:'58%'}}/><span style={{height:'52%'}}/><span style={{height:'77%'}}/><span style={{height:'66%'}}/><span style={{height:'91%'}}/></div></article><article className="admin-kpi"><div className="kpi-top"><span>Agendamentos no mês</span><i className="positive">↗ 12,7%</i></div><strong>186</strong><small>vs. 165 no mês anterior</small><div className="kpi-mini-icon blue">▣</div></article><article className="admin-kpi"><div className="kpi-top"><span>Profissionais ativos</span><i className="positive">↗ 8,2%</i></div><strong>1.248</strong><small>932 verificados disponíveis</small><div className="kpi-mini-icon green">♙</div></article><article className="admin-kpi"><div className="kpi-top"><span>Índice de satisfação</span><i className="positive">↗ 2,1%</i></div><strong>4,86 <small className="out-of">/ 5</small></strong><small>Baseado em 426 avaliações</small><div className="rating-stars">★★★★★</div></article></div>
        <div className="analytics-grid"><article className="admin-card revenue-card"><div className="card-heading"><div><h2>Evolução do faturamento</h2><p>Volume bruto transacionado via Pix</p></div><select value={period} onChange={e => setPeriod(e.target.value)}><option>Últimos 6 meses</option><option>Este ano</option><option>Últimos 30 dias</option></select></div><div className="chart-area"><div className="chart-y"><span>R$ 50k</span><span>R$ 40k</span><span>R$ 30k</span><span>R$ 20k</span><span>R$ 10k</span><span>R$ 0</span></div><div className="line-chart"><div className="grid-lines"><i/><i/><i/><i/><i/><i/></div><svg viewBox="0 0 700 250" preserveAspectRatio="none" aria-label="Gráfico de faturamento"><defs><linearGradient id="areaFill" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stopColor="#fdbf0f" stopOpacity=".25"/><stop offset="100%" stopColor="#fdbf0f" stopOpacity="0"/></linearGradient></defs><path d="M0 206 C45 190, 70 192, 112 168 S180 180, 226 135 S293 145, 340 113 S410 126, 454 89 S520 104, 560 62 S635 79, 700 28 L700 250 L0 250 Z" fill="url(#areaFill)"/><path d="M0 206 C45 190, 70 192, 112 168 S180 180, 226 135 S293 145, 340 113 S410 126, 454 89 S520 104, 560 62 S635 79, 700 28" fill="none" stroke="#fdbf0f" strokeWidth="3" strokeLinecap="round"/><circle cx="700" cy="28" r="5" fill="#fdbf0f" stroke="#111" strokeWidth="3"/></svg><div className="chart-x"><span>Abr</span><span>Mai</span><span>Jun</span><span>Jul</span><span>Ago</span><span>Set</span></div></div></div></article><article className="admin-card category-card"><div className="card-heading"><div><h2>Demanda por categoria</h2><p>Serviços contratados no período</p></div><button className="more-button">•••</button></div><div className="donut-wrap"><div className="donut"><div><strong>192</strong><small>solicitações</small></div></div></div><div className="category-list">{categoryBars.map(([name, value, color]) => <div className="category-row" key={name}><span><i style={{backgroundColor: String(color)}} />{name}</span><b>{value}%</b></div>)}</div></article></div>
        <article className="admin-card table-card"><div className="card-heading"><div><h2>Agendamentos recentes</h2><p>Últimas solicitações recebidas na plataforma</p></div><button className="outline-button small-button" onClick={() => setActive('Agendamentos')}>Ver todos →</button></div><div className="data-table"><div className="table-row table-head"><span>CLIENTE</span><span>PROFISSIONAL</span><span>SERVIÇO</span><span>DATA E HORÁRIO</span><span>VALOR</span><span>STATUS</span></div>{appointments.map(row => <div className="table-row" key={row[0]}><span className="person-cell"><i>{row[0].split(' ').map(n => n[0]).join('').slice(0,2)}</i>{row[0]}</span><span>{row[1]}</span><span>{row[2]}</span><span>{row[3]}</span><span><b>{row[4]}</b></span><span><em className={`status ${row[5].toLowerCase().replace(' ','-')}`}><i/> {row[5]}</em></span></div>)}</div></article>
        <div className="bottom-grid"><article className="admin-card activity-card"><div className="card-heading"><div><h2>Atividade recente</h2><p>Movimentações importantes</p></div><button className="more-button">•••</button></div><div className="activity-list"><div><i className="activity-icon yellow">✓</i><p><b>Nova verificação enviada</b><small>Lucas Ferreira · há 8 min</small></p><span>→</span></div><div><i className="activity-icon blue">R$</i><p><b>Pagamento confirmado</b><small>Agendamento #BT-2048 · há 24 min</small></p><span>→</span></div><div><i className="activity-icon purple">★</i><p><b>Nova avaliação recebida</b><small>5 estrelas · há 1 hora</small></p><span>→</span></div></div></article><article className="admin-card quick-card"><p className="admin-eyebrow">ATENÇÃO DA SEMANA</p><h2>O que precisa da sua atenção?</h2><div className="quick-line"><span className="quick-number">12</span><p><b>verificações pendentes</b><small>Documentos aguardando análise</small></p><button onClick={() => setActive('Verificações')}>→</button></div><div className="quick-line"><span className="quick-number red-number">03</span><p><b>contestações abertas</b><small>Precisam de uma resposta</small></p><button onClick={() => setActive('Contestações')}>→</button></div></article></div>
        <footer className="admin-footer"><span>© 2026 Bora Trampa · Painel administrativo</span><span>Dados atualizados há menos de 5 min · <b className="online-dot"/> Operacional</span></footer>
      </div>
    </section>
  </main>;
}
