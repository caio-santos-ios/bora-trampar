# Verificação de identidade dos profissionais

## Objetivo

Para aumentar a segurança do marketplace e reduzir o risco de uso de documentos de terceiros, todo profissional deverá passar por uma verificação de identidade antes de poder aceitar serviços. A verificação combina documento oficial, prova de presença e revisão de consistência dos dados.

> Esta especificação é uma diretriz de produto e segurança. Antes da implementação, a política de privacidade, os parâmetros de retenção e descarte e a base legal para tratamento de documentos e biometria facial devem ser revisados por profissional jurídico especializado em proteção de dados.

## Dados e evidências solicitados

O profissional deverá informar os dados cadastrais básicos e enviar uma das seguintes opções de documento oficial válido:

- RG frente e verso; ou
- CNH.

Também deverá enviar uma selfie do rosto, capturada no momento do cadastro, para comparação com a foto do documento e redução do risco de identidade falsa. As imagens devem estar legíveis, completas e sem cortes.

Sempre que possível, a captura deve ocorrer dentro do aplicativo, com orientações de iluminação, enquadramento e nitidez. O sistema deve explicar por que os dados são solicitados, obter o consentimento necessário e limitar o uso das imagens à verificação e à segurança da plataforma.

## Fluxo de verificação

1. O profissional cria a conta e informa seus dados cadastrais.
2. O sistema solicita RG frente e verso ou CNH, além da selfie.
3. O sistema verifica qualidade, legibilidade, integridade e compatibilidade básica entre os dados informados e o documento.
4. Quando disponível, um serviço especializado pode realizar validação documental e comparação facial. O resultado deve ser tratado como apoio à decisão, não como uma decisão automática infalível.
5. O caso recebe um status: `pendente`, `em análise`, `aprovado`, `reprovado` ou `necessita de correção`.
6. Enquanto a verificação não for aprovada, o profissional não poderá aceitar serviços nem aparecer como opção elegível para contratação.
7. Em caso de correção, o sistema deve explicar o problema sem expor dados sensíveis desnecessários e permitir novo envio dentro das regras definidas.

## Controles contra uso de documento de terceiros

A plataforma deve comparar o nome e os dados do documento com o cadastro, verificar sinais de edição ou inconsistência, impedir o uso da mesma identidade em múltiplas contas e registrar tentativas de cadastro repetidas. A comparação entre selfie e foto documental deve ser feita com controles de segurança e revisão humana nos casos inconclusivos ou de maior risco.

O sistema não deve reprovar definitivamente uma pessoa apenas por uma falha técnica de captura ou por uma divergência que possa ser explicada. Casos suspeitos devem ser encaminhados para análise manual, com registro do motivo, evidências consideradas e responsável pela decisão.

## Status da verificação

| Status | Significado | Ação do sistema |
|---|---|---|
| Pendente | Dados ou arquivos ainda não enviados. | Manter o profissional impedido de aceitar serviços. |
| Em análise | Documentos recebidos e aguardando validação. | Manter o bloqueio preventivo e registrar o responsável. |
| Aprovado | Identidade validada dentro dos critérios definidos. | Liberar o profissional para oferecer e aceitar serviços. |
| Necessita de correção | Imagem ilegível, incompleta ou dado inconsistente sem indício conclusivo de fraude. | Solicitar novo envio com instruções objetivas. |
| Reprovado | Indícios relevantes de fraude, identidade incompatível ou documento inválido. | Impedir a atuação e registrar o motivo da decisão. |

## Proteção de dados e acesso

Documentos e selfies devem ser criptografados em trânsito e em repouso, ter acesso restrito por função, não aparecer em logs e não ser disponibilizados publicamente. O sistema deve coletar apenas o necessário, manter trilha de auditoria, definir prazo de retenção e excluir ou anonimizar os arquivos quando a finalidade e as obrigações aplicáveis permitirem.

A equipe administrativa deve acessar os documentos somente quando necessário para análise, com permissões específicas e registro de acesso. O profissional deve poder consultar o status da verificação e receber orientações para corrigir um envio recusado.

## Requisitos do administrador

O administrador deve conseguir consultar a fila de verificações, visualizar os dados necessários para análise, solicitar correção, aprovar ou reprovar o cadastro e registrar o motivo da decisão. Cada ação deve registrar usuário responsável, data, status anterior, status novo e justificativa.

## Critérios de aceite do MVP

- Um profissional não aprovado não aparece como disponível e não consegue aceitar serviços.
- O cadastro exige RG frente e verso ou CNH e uma selfie.
- O sistema impede o avanço quando os arquivos obrigatórios não são enviados.
- O sistema registra o status da verificação e informa o resultado ao profissional.
- Casos inconclusivos podem ser encaminhados para revisão manual.
- Tentativas repetidas e possíveis duplicidades de identidade ficam registradas para análise.
- Documentos e selfies não são exibidos em logs nem ficam publicamente acessíveis.
- O administrador consegue aprovar, reprovar ou solicitar correção com justificativa.
- Todas as alterações ficam registradas na trilha de auditoria.

## Backlog relacionado

1. Escolher um provedor de validação documental e comparação facial compatível com o MVP.
2. Definir os campos obrigatórios e as regras de qualidade das imagens.
3. Definir os prazos de retenção, descarte e anonimização com revisão jurídica.
4. Implementar armazenamento privado e criptografado para os arquivos.
5. Criar a fila e o painel de análise administrativa.
6. Implementar controles de duplicidade de identidade e registro de tentativas.
7. Criar testes para aprovação, reprovação, correção, revisão manual e falhas do provedor.

## Referências

- [Documentação principal do projeto](./bora-trampar.md)
- [Repositório Bora Trampar](https://github.com/caio-santos-ios/bora-trampar)
- [Documentação do projeto no Notion](https://app.notion.com/p/3cd8d27657cf81e0b1a2fc3f60b041e2?pvs=204)
