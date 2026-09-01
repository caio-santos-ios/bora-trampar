# Bora Trampar — Documentação do Projeto

> Documento exportado da página do projeto no Notion. A fonte de planejamento permanece disponível no [Notion](https://app.notion.com/p/3cd8d27657cf81e0b1a2fc3f60b041e2?pvs=204).

# Visão geral
Esta página centraliza a documentação inicial do projeto **Bora Trampar** e serve como ponto de partida para decisões de produto, design, arquitetura e implementação.
O repositório oficial está disponível em [GitHub — caio-santos-ios/bora-trampar](https://github.com/caio-santos-ios/bora-trampar).
> Status atual: estrutura inicial criada; ainda não há implementação funcional nem commits de código.
# Objetivo do projeto
O **Bora Trampar** é uma plataforma de contratação de serviços que conecta clientes a profissionais disponíveis para realizar atividades diversas, como pedreiro, pintor, babá e outras categorias. A proposta é simplificar a busca, a escolha e o agendamento de um serviço em um único fluxo digital, oferecendo mais conveniência para o cliente e novas oportunidades de trabalho para profissionais.
O produto deve permitir que o cliente encontre um serviço adequado, informe quando precisa dele, visualize profissionais disponíveis e confirme o agendamento com clareza e segurança. Para os profissionais, a plataforma deve organizar a oferta de serviços, a disponibilidade de agenda e o recebimento de solicitações. O administrador, proprietário do sistema, terá visão e controle sobre usuários, categorias, serviços, agendamentos e regras operacionais.
# Estrutura do repositório

| Diretório | Responsabilidade esperada | Status |
| --- | --- | --- |
| api-bora-trampar | Backend, APIs, regras de negócio e integrações | Aguardando definição |
| ui-bora-trampar | Interface visual, componentes e experiência web | Aguardando definição |
| app-bora-trampar | Aplicativo principal e fluxos mobile | Aguardando definição |
| docs | Documentação do produto e do desenvolvimento | Em estruturação |
| docs/telas-app | Referências, especificações e documentação das telas do aplicativo | Em estruturação |

# Escopo inicial
O MVP será um **marketplace de serviços sob agendamento**, com três tipos de usuário: **cliente**, **profissional** e **administrador**. O cliente seleciona uma categoria, escolhe um serviço, informa a data e o horário desejados, consulta os profissionais disponíveis e confirma o agendamento.
A primeira versão deve contemplar cadastro e autenticação, perfis por tipo de usuário, catálogo de categorias e serviços, cadastro de disponibilidade dos profissionais, busca por disponibilidade, criação e confirmação de agendamentos, geração de cobrança via Pix, acompanhamento do pagamento e acompanhamento do status do serviço. O painel administrativo deve permitir gerenciar usuários, categorias, serviços, agendamentos e pagamentos. O único meio de pagamento do MVP será o Pix.
Funcionalidades como pagamentos integrados, avaliações avançadas, chat em tempo real, geolocalização, recorrência de serviços e algoritmos sofisticados de recomendação podem ser tratadas como evolução posterior, caso não sejam essenciais para validar o MVP.
# Produto e experiência
## Perfis de usuário

| Perfil | Objetivo principal | Responsabilidades e necessidades |
| --- | --- | --- |
| Cliente | Contratar um serviço com praticidade | Escolher categoria e serviço, informar data e horário, consultar profissionais disponíveis, confirmar o agendamento e acompanhar seu status. |
| Profissional | Oferecer serviços e receber oportunidades | Manter perfil e serviços, informar disponibilidade, receber solicitações e acompanhar os agendamentos confirmados. |
| Administrador | Operar e controlar o sistema | Gerenciar usuários, categorias, serviços, agendamentos, permissões e regras da plataforma. |

## Fluxo principal do cliente
1. O cliente entra na plataforma e acessa sua conta.
2. Seleciona uma **categoria** de serviço, como construção, pintura ou cuidados infantis.
3. Escolhe o **serviço** específico que deseja contratar.
4. Informa a **data** e o **horário** desejados.
5. O sistema consulta os profissionais compatíveis e disponíveis para aquele serviço e período.
6. O cliente visualiza as opções disponíveis e escolhe um profissional.
7. Revisa os detalhes da solicitação e **confirma o agendamento**.
8. Após a confirmação, o sistema gera uma cobrança **exclusivamente via Pix**.
9. O cliente visualiza o QR Code e/ou código Pix copia e cola e realiza o pagamento.
10. Após a confirmação do pagamento, o sistema atualiza o agendamento e informa o status ao cliente e ao profissional.
## Pagamento via Pix
O pagamento será obrigatório ao final do fluxo de contratação e ocorrerá somente por **Pix**. O sistema deverá gerar uma cobrança vinculada ao agendamento, apresentar ao cliente o QR Code e o código Pix copia e cola, registrar o status da transação e confirmar o serviço somente após a identificação do pagamento aprovado.
Os estados mínimos a considerar são: **aguardando pagamento**, **pagamento aprovado**, **pagamento expirado**, **pagamento cancelado** e **pagamento com erro**. O sistema também deverá tratar expiração da cobrança, evitar a confirmação duplicada do mesmo agendamento e manter um registro da transação para consulta do cliente e do administrador.
## Proteção contra má-fé e contestação de serviços
Como o pagamento é realizado antecipadamente dentro do aplicativo, o cliente não poderá receber o serviço e simplesmente se recusar a pagar. Caso exista um problema real, ele deverá utilizar o processo formal de contestação, que garante análise do caso e proteção tanto para o cliente quanto para a profissional.
### Encerramento do serviço pelo cliente
Depois que a profissional marcar o serviço como finalizado, o cliente deverá escolher obrigatoriamente uma das opções abaixo:
- **Serviço concluído**: encerra a prestação sem contestação e encaminha o valor para o fluxo de repasse à profissional, respeitando as regras de segurança e o prazo de processamento definido pelo sistema.
- **Não concordo com o serviço**: abre uma contestação formal. O cliente deverá informar obrigatoriamente o motivo e poderá anexar fotos, vídeos, documentos ou outras evidências disponíveis.
A opção de contestação não deve funcionar como cancelamento simples nem como forma de evitar o pagamento. Como o valor já foi pago antecipadamente, ele permanecerá retido no fluxo financeiro até que o caso seja analisado e uma decisão seja registrada.
### Fluxo de contestação
1. A profissional finaliza o serviço e o cliente recebe a solicitação de avaliação do resultado.
2. O cliente seleciona **Serviço concluído** ou **Não concordo com o serviço**.
3. Se houver contestação, o motivo será obrigatório; o envio de evidências será recomendado sempre que possível.
4. O sistema cria um caso de contestação vinculado ao pedido e impede o repasse automático à profissional.
5. O administrador analisa o histórico do pedido, os dados do serviço, as evidências do cliente e as informações apresentadas pela profissional.
6. O administrador registra a decisão, o motivo, as evidências consideradas e as ações financeiras correspondentes.
7. O sistema comunica o resultado às partes e atualiza o status do pedido e do pagamento.
### Decisões possíveis do administrador

| Decisão | Resultado financeiro | Uso esperado |
| --- | --- | --- |
| Liberar pagamento para a profissional | Repasse total conforme as regras do pedido | Serviço considerado realizado ou contestação considerada improcedente. |
| Reembolso total ao cliente | Devolução integral do valor pago | Falha comprovada, serviço não realizado ou situação que justifique o reembolso completo. |
| Reembolso parcial | Divisão do valor conforme a decisão registrada | Serviço parcialmente entregue ou problema limitado a parte da contratação. |
| Solicitar mais informações | Pagamento permanece retido | Dados insuficientes para decidir; o sistema deve registrar o prazo para resposta. |

### Detecção de possíveis abusos
O sistema deverá manter indicadores de risco para apoiar a análise administrativa, sem bloquear ou punir automaticamente o cliente apenas com base em um indicador. Devem ser sinalizados, por exemplo, clientes que abram muitas contestações, contestem a maioria dos serviços contratados, apresentem reclamações repetidas sem evidências ou realizem tentativas recorrentes de obter reembolso indevido.
Os indicadores devem ser usados como apoio à decisão, sempre considerando o histórico completo, a justificativa apresentada, as evidências disponíveis e a resposta da profissional. O administrador poderá solicitar informações adicionais, acompanhar reincidências e aplicar medidas operacionais previstas nas regras da plataforma.
### Histórico e auditoria
Cada pedido deverá manter um histórico imutável das principais ocorrências: confirmação do agendamento, pagamento Pix, início e finalização do serviço, escolha do cliente, motivo da contestação, arquivos enviados, comunicações, decisões administrativas, valores liberados ou reembolsados, datas e responsáveis por cada ação.
## Fluxos complementares
O profissional deve conseguir configurar os serviços que oferece, manter sua disponibilidade, marcar o serviço como finalizado e responder às contestações recebidas. O administrador deve conseguir cadastrar categorias e serviços, moderar usuários, acompanhar agendamentos, analisar contestações, solicitar evidências, liberar repasses e autorizar reembolsos totais ou parciais.
## Telas do aplicativo
Use a página ou subpáginas em `docs/telas-app` para registrar cada tela com objetivo, componentes, estados, navegação, regras e referências visuais.
## Documentação complementar

A especificação detalhada de verificação de identidade dos profissionais está em [docs/verificacao-profissionais.md](./verificacao-profissionais.md). Ela define os documentos aceitos, selfie, estados da verificação, revisão manual, controles contra uso de identidade de terceiros, proteção de dados e critérios de aceite do MVP.

# Arquitetura técnica
Registre a stack escolhida, a separação entre API, UI e aplicativo, o modelo de dados, autenticação, integrações externas, ambientes e estratégia de deploy.
# Convenções de desenvolvimento
Defina padrão de branches, mensagens de commit, revisão de código, organização de arquivos, variáveis de ambiente, testes automatizados e critérios de aceite.
# Roadmap

| Fase | Resultado esperado | Status |
| --- | --- | --- |
| Descoberta | Problema, público, proposta de valor e requisitos priorizados | Não iniciado |
| Design | Fluxos, wireframes e especificações das telas | Não iniciado |
| Base técnica | Stack, ambientes, arquitetura e pipeline inicial | Não iniciado |
| MVP | Primeira versão funcional validável | Não iniciado |
| Validação | Testes com usuários, métricas e aprendizados | Não iniciado |

# Backlog inicial
1. Validar a proposta de valor do marketplace com clientes e profissionais.
2. Detalhar permissões e critérios de acesso para cliente, profissional e administrador.
3. Definir categorias, serviços e atributos necessários para cada oferta.
4. Mapear o fluxo de busca, disponibilidade, seleção e confirmação do agendamento.
5. Criar a documentação das telas em `docs/telas-app`.
6. Definir o modelo de dados para usuários, perfis, categorias, serviços, disponibilidades, agendamentos, contestações e evidências.
7. Especificar os contratos da API, as transições de status do agendamento, contestação, pagamento e repasse.
8. Definir o fluxo de geração, expiração, confirmação e conciliação do pagamento Pix.
9. Definir o fluxo de finalização do serviço, retenção do valor, análise administrativa e reembolso total ou parcial.
10. Criar indicadores de risco para identificar possíveis abusos e manter o histórico de auditoria.
11. Escolher a stack e documentar a arquitetura.
12. Definir critérios de aceite, testes e plano de implementação.
# Registro de decisões
Use esta seção para registrar decisões importantes com data, contexto, alternativas consideradas e impacto.

| Data | Decisão | Motivo | Responsável |
| --- | --- | --- | --- |
| A definir | A definir | A definir | A definir |

# Próximos passos
Comece validando a proposta de valor e detalhando as regras dos três perfis de usuário. Em seguida, defina o catálogo inicial de categorias e serviços, documente o fluxo de agendamento e pagamento via Pix e transforme cada etapa aprovada em uma especificação de tela dentro de `docs/telas-app`. Depois, modele os dados, os contratos da API e os estados da cobrança antes de iniciar a implementação.
# Cronograma do projeto
O cronograma abaixo foi replanejado para entregar um **MVP enxuto em 20 dias úteis, distribuídos em 4 semanas**. O foco é validar o fluxo essencial do cliente: escolher categoria e serviço, informar data e horário, encontrar um profissional, confirmar o agendamento e pagar exclusivamente via Pix. Para cumprir o prazo, as atividades devem ocorrer com decisões rápidas, escopo congelado e desenvolvimento paralelo quando possível.

| Etapa | Duração estimada | Principais atividades | Entregáveis |
| --- | --- | --- | --- |
| 1. Definição e escopo | Dias 1–2 | Fechar categorias, serviços, perfis, regras do agendamento e escopo que ficará fora do MVP. | Requisitos priorizados, critérios de aceite e fluxo aprovado. |
| 2. UX e telas essenciais | Dias 3–5 | Detalhar as telas do cliente, profissional e admin para o fluxo principal e documentar estados e mensagens. | Fluxos, wireframes e especificações em `docs/telas-app`. |
| 3. Arquitetura e preparação | Dias 6–7 | Definir stack, modelo de dados, contratos da API, ambientes e estratégia mínima de integração Pix. | Projeto configurado, modelo de dados e contratos técnicos. |
| 4. API e regras de negócio | Dias 8–12 | Implementar autenticação, perfis, categorias, serviços, disponibilidade, agendamentos e estados do pagamento. | API funcional com persistência, validações e cobrança Pix em ambiente de testes. |
| 5. UI e aplicativo | Dias 13–16 | Implementar o fluxo do cliente, telas mínimas do profissional e painel administrativo essencial. | Aplicação navegável integrada à API. |
| 6. Integração Pix e testes | Dias 17–18 | Validar QR Code, Pix copia e cola, confirmação, expiração, erros e prevenção de cobrança duplicada. | Fluxo de pagamento integrado e testes de ponta a ponta. |
| 7. Ajustes e entrega do MVP | Dias 19–20 | Corrigir problemas críticos, publicar a versão de demonstração e preparar o roteiro de validação. | MVP demonstrável, documentação atualizada e backlog pós-MVP. |

## Linha do tempo sugerida

A ordem de entrega prioriza o **painel administrativo**, depois o aplicativo do cliente e, por fim, o aplicativo do profissional e a estabilização do MVP. A base da API pode ser desenvolvida em paralelo para sustentar cada entrega semanal, mas o primeiro produto utilizável será o painel.

| Semana | Foco da entrega | O que será entregue |
| --- | --- | --- |
| Semana 1 | Painel administrativo | Painel inicial com login de administrador, gestão de usuários, categorias, serviços, profissionais e fila de verificação de identidade. |
| Semana 2 | API e operação do painel | API integrada ao painel, modelo de dados, disponibilidade, agendamentos, pagamentos Pix, contestações e decisões administrativas. |
| Semana 3 | Aplicativo do cliente | Fluxo do cliente: categoria, serviço, data, horário, profissionais disponíveis, confirmação, geração do Pix e acompanhamento do pedido. |
| Semana 4 | Aplicativo do profissional e entrega | Perfil e disponibilidade da profissional, recebimento e finalização de serviços, contestação, integração ponta a ponta, correções críticas e MVP demonstrável. |

## Critérios para avançar de etapa
Cada semana deve terminar com a entrega indicada na linha do tempo, revisada e demonstrável. Para preservar o prazo de 20 dias, o escopo deve permanecer congelado após o Dia 2 e a equipe deve priorizar o painel administrativo antes do aplicativo. Antes da entrega final, o sistema deve permitir concluir um agendamento de ponta a ponta em ambiente de testes, incluindo geração do Pix, confirmação do pagamento, atualização do status para cliente e profissional, finalização do serviço, contestação e tratamento dos erros críticos.
## Riscos e premissas
O plano pressupõe decisões rápidas sobre escopo e stack, disponibilidade diária da equipe e acesso imediato a um provedor Pix em ambiente de testes. Para caber em 20 dias, pagamentos integrados além do Pix, avaliações, chat, geolocalização, recorrência, recomendações avançadas e funcionalidades não essenciais ficam fora do MVP. A integração Pix, conflitos de agenda, contestação de má-fé e mudanças de escopo são os principais riscos para o prazo.
A política de contestação deve ser transparente para as duas partes. O sistema não deve presumir automaticamente que cliente ou profissional está correto; deve preservar o valor até a análise, registrar evidências e permitir decisão fundamentada do administrador. Os prazos de resposta, critérios de reembolso e regras de repasse devem ser definidos antes da publicação do MVP.
# Referências
- [Repositório oficial no GitHub](https://github.com/caio-santos-ios/bora-trampar)
- [Branch main](https://github.com/caio-santos-ios/bora-trampar/tree/main)
