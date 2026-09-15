export interface IconOption {
  label: string;
  value: string;
  category: string;
  keywords?: string;
}

export const ICON_CATEGORIES = [
  'Todas',
  'Construção & Obras',
  'Pintura & Acabamento',
  'Elétrica & Iluminação',
  'Hidráulica & Encanamento',
  'Ferramentas & Reparos',
  'Marcenaria & Móveis',
  'Limpeza & Higienização',
  'Jardinagem & Piscina',
  'Climatização',
  'Segurança',
  'Automotivo',
  'Fretes & Mudanças',
  'Tecnologia & TI',
  'Cuidados & Saúde',
  'Eventos & Gerais'
];

export const AVAILABLE_FONT_AWESOME_ICONS: IconOption[] = [
  // Construção & Obras
  { label: 'Martelo / Obra', value: 'fa-hammer', category: 'Construção & Obras', keywords: 'martelo obra reforma construcao' },
  { label: 'Alvenaria / Pedreiro', value: 'fa-trowel-bricks', category: 'Construção & Obras', keywords: 'tijolo parede alvenaria pedreiro massa cimento' },
  { label: 'Colher de Pedreiro', value: 'fa-trowel', category: 'Construção & Obras', keywords: 'colher pedreiro reboco acabamento' },
  { label: 'Capacete Segurança', value: 'fa-helmet-safety', category: 'Construção & Obras', keywords: 'capacete seguranca epi obra protecao' },
  { label: 'Trena & Esquadro', value: 'fa-ruler-combined', category: 'Construção & Obras', keywords: 'regua trena medicao esquadro nivel projeto' },
  { label: 'Fita Métrica', value: 'fa-tape', category: 'Construção & Obras', keywords: 'fita metrica trena rolo isolante' },
  { label: 'Capacete Obra', value: 'fa-hard-hat', category: 'Construção & Obras', keywords: 'capacete operario construcao' },
  { label: 'Pavimentação', value: 'fa-road', category: 'Construção & Obras', keywords: 'estrada rua asfalto calcada calcamento piso' },
  { label: 'Carrinho de Carga', value: 'fa-dolly', category: 'Construção & Obras', keywords: 'carrinho carga transporte entulho saco' },

  // Pintura & Acabamento
  { label: 'Rolo de Pintura', value: 'fa-paint-roller', category: 'Pintura & Acabamento', keywords: 'rolo tinta pintura pintor parede latex' },
  { label: 'Pincel / Verniz', value: 'fa-brush', category: 'Pintura & Acabamento', keywords: 'pincel trincha pintura detalhe verniz' },
  { label: 'Paleta de Cores', value: 'fa-palette', category: 'Pintura & Acabamento', keywords: 'paleta cores decoracao acabamento arte' },
  { label: 'Lata de Tinta', value: 'fa-fill-drip', category: 'Pintura & Acabamento', keywords: 'lata tinta derramar pintor cor' },
  { label: 'Spray / Pistola', value: 'fa-spray-can', category: 'Pintura & Acabamento', keywords: 'spray pistola compressor pintura automotiva' },

  // Elétrica & Iluminação
  { label: 'Eletricista / Raio', value: 'fa-bolt', category: 'Elétrica & Iluminação', keywords: 'eletricista raio energia luz forca fio' },
  { label: 'Tomada / Plug', value: 'fa-plug', category: 'Elétrica & Iluminação', keywords: 'tomada plugue tomada cabo extensao instalacao' },
  { label: 'Lâmpada / Iluminação', value: 'fa-lightbulb', category: 'Elétrica & Iluminação', keywords: 'lampada led luminaria lustre iluminacao luz' },
  { label: 'Estação Elétrica', value: 'fa-charging-station', category: 'Elétrica & Iluminação', keywords: 'carregador carro eletrico veiculo estacao' },
  { label: 'Energia Solar', value: 'fa-solar-panel', category: 'Elétrica & Iluminação', keywords: 'solar placa painel fotovoltaico sustentavel' },
  { label: 'Baterias & Nobreak', value: 'fa-battery-full', category: 'Elétrica & Iluminação', keywords: 'bateria pilha carga nobreak estabilizador' },
  { label: 'Quadro & Disjuntor', value: 'fa-power-off', category: 'Elétrica & Iluminação', keywords: 'disjuntor chave geral quadro desligar forca' },

  // Hidráulica & Encanamento
  { label: 'Torneira / Cano', value: 'fa-faucet', category: 'Hidráulica & Encanamento', keywords: 'torneira cano encanador pia agua valvula' },
  { label: 'Torneira com Gota', value: 'fa-faucet-drip', category: 'Hidráulica & Encanamento', keywords: 'vazamento pingando gota torneira encanador' },
  { label: 'Gota / Vazamento', value: 'fa-droplet', category: 'Hidráulica & Encanamento', keywords: 'gota agua encanamento infiltracao conserto' },
  { label: 'Chuveiro & Ducha', value: 'fa-shower', category: 'Hidráulica & Encanamento', keywords: 'chuveiro ducha banheiro banho quente agua' },
  { label: 'Vaso Sanitário', value: 'fa-toilet', category: 'Hidráulica & Encanamento', keywords: 'sanitario banheiro vaso privada desentupir' },
  { label: 'Água & Cisterna', value: 'fa-water', category: 'Hidráulica & Encanamento', keywords: 'agua bomba caixa dagua cisterna tubulacao' },

  // Ferramentas & Reparos
  { label: 'Chave & Parafusadeira', value: 'fa-screwdriver-wrench', category: 'Ferramentas & Reparos', keywords: 'chave fenda philips inglesa ferramentas montagem' },
  { label: 'Chave de Fenda', value: 'fa-screwdriver', category: 'Ferramentas & Reparos', keywords: 'parafuso fenda philips regulagem aperto' },
  { label: 'Chave Inglesa', value: 'fa-wrench', category: 'Ferramentas & Reparos', keywords: 'chave inglesa ajuste aperto mecanica encanamento' },
  { label: 'Engrenagem / Ajuste', value: 'fa-gear', category: 'Ferramentas & Reparos', keywords: 'engrenagem ajuste configuracao motor calibragem' },
  { label: 'Mecânica Geral', value: 'fa-gears', category: 'Ferramentas & Reparos', keywords: 'engrenagens maquinas manutencao industrial pecas' },
  { label: 'Caixa de Ferramentas', value: 'fa-toolbox', category: 'Ferramentas & Reparos', keywords: 'caixa ferramentas kit manutencao reparos' },
  { label: 'Fechadura / Tranca', value: 'fa-lock', category: 'Ferramentas & Reparos', keywords: 'fechadura cadeado tranca chaveiro porta trava' },
  { label: 'Chaves / Chaveiro', value: 'fa-key', category: 'Ferramentas & Reparos', keywords: 'chaveiro abertura copia chave residencial tetra' },

  // Marcenaria & Móveis
  { label: 'Marcenaria / Cadeira', value: 'fa-chair', category: 'Marcenaria & Móveis', keywords: 'cadeira marceneiro mesa movel assento madeira' },
  { label: 'Estofados & Sofá', value: 'fa-couch', category: 'Marcenaria & Móveis', keywords: 'sofa estofado tapeceiro poltrona sala' },
  { label: 'Montagem de Camas', value: 'fa-bed', category: 'Marcenaria & Móveis', keywords: 'cama quarto montador cabeceira colchao guarda-roupa' },
  { label: 'Portas & Janelas', value: 'fa-door-open', category: 'Marcenaria & Móveis', keywords: 'porta abertura janela esquadria batente alisar' },
  { label: 'Instalação de Portas', value: 'fa-door-closed', category: 'Marcenaria & Móveis', keywords: 'porta fechada tranca guarnicao madeira' },
  { label: 'Carpintaria / Madeira', value: 'fa-tree', category: 'Marcenaria & Móveis', keywords: 'madeira arvore carpintaria tronco tabua vigas telhado' },

  // Limpeza & Higienização
  { label: 'Vassoura / Diarista', value: 'fa-broom', category: 'Limpeza & Higienização', keywords: 'vassoura limpeza faxina diarista varrer casa' },
  { label: 'Sabão / Higiene', value: 'fa-soap', category: 'Limpeza & Higienização', keywords: 'sabao sabonete lavagem espuma higienizacao' },
  { label: 'Balde / Faxina Pesada', value: 'fa-bucket', category: 'Limpeza & Higienização', keywords: 'balde pano agua lavagem piso limpeza pesada' },
  { label: 'Dispenser / Produtos', value: 'fa-pump-soap', category: 'Limpeza & Higienização', keywords: 'dispenser alcool gel saboneteira sanitizante' },
  { label: 'Sanitização / Brilho', value: 'fa-hand-sparkles', category: 'Limpeza & Higienização', keywords: 'brilho sanitizacao polimento cristalizacao asseio' },
  { label: 'Coleta de Entulho', value: 'fa-trash-can', category: 'Limpeza & Higienização', keywords: 'lixo lixeira entulho cacamba descarte remocao' },
  { label: 'Dedetização / Pragas', value: 'fa-bug', category: 'Limpeza & Higienização', keywords: 'inseto praga dedetizacao barata cupim formiga' },

  // Jardinagem & Piscina
  { label: 'Jardinagem / Plantas', value: 'fa-seedling', category: 'Jardinagem & Piscina', keywords: 'planta jardim muda horta grama jardineiro' },
  { label: 'Paisagismo / Folhas', value: 'fa-leaf', category: 'Jardinagem & Piscina', keywords: 'folha folhagem paisagismo verde decoracao' },
  { label: 'Poda de Árvores', value: 'fa-scissors', category: 'Jardinagem & Piscina', keywords: 'tesoura poda grama cerca viva corte arbusto' },
  { label: 'Limpeza de Piscina', value: 'fa-person-swimming', category: 'Jardinagem & Piscina', keywords: 'piscina nadar aspiracao tratamento cloro agua' },
  { label: 'Manutenção Piscina', value: 'fa-water-ladder', category: 'Jardinagem & Piscina', keywords: 'escada piscina hidro bomba filtro borda' },

  // Climatização
  { label: 'Ar-Condicionado / Frio', value: 'fa-snowflake', category: 'Climatização', keywords: 'ar condicionado split geladeira refrigeracao frio gelo' },
  { label: 'Ventilador / Exaustor', value: 'fa-fan', category: 'Climatização', keywords: 'ventilador exaustor helice ventilacao teto climatizador' },
  { label: 'Circulação de Ar', value: 'fa-wind', category: 'Climatização', keywords: 'vento ar duto circulacao ventilacao renovacao' },
  { label: 'Aquecedor a Gás', value: 'fa-fire', category: 'Climatização', keywords: 'fogo chama gas aquecedor boiler lareira caldeira' },
  { label: 'Refrigeração Comercial', value: 'fa-temperature-arrow-down', category: 'Climatização', keywords: 'camara fria freezer balcao termometro temperatura' },

  // Segurança
  { label: 'Segurança / Escudo', value: 'fa-shield-halved', category: 'Segurança', keywords: 'seguranca escudo protecao cerca eletrica alarme ronda' },
  { label: 'Câmeras / CFTV', value: 'fa-video', category: 'Segurança', keywords: 'camera cftv vigilancia filmagem monitoramento dvr' },
  { label: 'Monitoramento', value: 'fa-camera', category: 'Segurança', keywords: 'camera gravacao foto seguranca' },
  { label: 'Alarme & Interfone', value: 'fa-bell', category: 'Segurança', keywords: 'campainha interfone alarme aviso sirene' },
  { label: 'Portaria & Recepção', value: 'fa-bell-concierge', category: 'Segurança', keywords: 'portaria recepcao predio controle acesso guarita' },

  // Automotivo
  { label: 'Mecânica Automotiva', value: 'fa-car', category: 'Automotivo', keywords: 'carro automovel mecanica auto eletrica freio suspensao' },
  { label: 'Motos & Revisão', value: 'fa-motorcycle', category: 'Automotivo', keywords: 'moto motocicleta mecanica corrente pneu revisao' },
  { label: 'Caminhão & Guincho', value: 'fa-truck', category: 'Automotivo', keywords: 'caminhao guincho reboque frete socorro auto' },
  { label: 'Pick-up / Carreto', value: 'fa-truck-pickup', category: 'Automotivo', keywords: 'pickup camionete carreto carga frete pequeno' },
  { label: 'Troca de Óleo', value: 'fa-oil-can', category: 'Automotivo', keywords: 'oleo motor lubrificante filtro troca revisao' },
  { label: 'Combustível & Bomba', value: 'fa-gas-pump', category: 'Automotivo', keywords: 'posto combustivel gasolina alcool diesel abastecimento' },
  { label: 'Bateria Automotiva', value: 'fa-car-battery', category: 'Automotivo', keywords: 'bateria carro partida alternador arranque' },

  // Fretes & Mudanças
  { label: 'Mudança Residencial', value: 'fa-truck-ramp-box', category: 'Fretes & Mudanças', keywords: 'mudanca caminhao rampa caixa transporte carga' },
  { label: 'Embalagem de Mudança', value: 'fa-boxes-packing', category: 'Fretes & Mudanças', keywords: 'caixas papelao embalar plastico bolha empacotar' },
  { label: 'Encomendas & Caixas', value: 'fa-box', category: 'Fretes & Mudanças', keywords: 'caixa pacote entrega encomenda frete envio' },
  { label: 'Desembalagem & Montar', value: 'fa-box-open', category: 'Fretes & Mudanças', keywords: 'caixa aberta retirada abrir mercadoria' },

  // Tecnologia & TI
  { label: 'Conserto de Notebook', value: 'fa-laptop', category: 'Tecnologia & TI', keywords: 'notebook computador formatacao reparo placa tela teclado' },
  { label: 'Computador de Mesa', value: 'fa-desktop', category: 'Tecnologia & TI', keywords: 'computador pc desktop monitor gabinete hardware' },
  { label: 'Assistência de Celular', value: 'fa-mobile-screen', category: 'Tecnologia & TI', keywords: 'celular smartphone troca tela bateria iphone android' },
  { label: 'Redes & Wi-Fi', value: 'fa-wifi', category: 'Tecnologia & TI', keywords: 'wifi roteador internet repetidor sinal conexao rede' },
  { label: 'Cabeamento Estruturado', value: 'fa-network-wired', category: 'Tecnologia & TI', keywords: 'cabo rede ethernet switch rack servidor ti' },
  { label: 'Impressoras & Recargas', value: 'fa-print', category: 'Tecnologia & TI', keywords: 'impressora toner tinta recarga scanner configuracao' },
  { label: 'Instalação de TV', value: 'fa-tv', category: 'Tecnologia & TI', keywords: 'tv televisao smart suporte parede painel antena' },

  // Cuidados & Saúde
  { label: 'Cuidador / Acompanhante', value: 'fa-heart', category: 'Cuidados & Saúde', keywords: 'coracao saude cuidador idoso acompanhante carinho' },
  { label: 'Babá / Cuidados Infantis', value: 'fa-baby', category: 'Cuidados & Saúde', keywords: 'baba crianca bebe berçario recreacao infantil' },
  { label: 'Enfermagem Domiciliar', value: 'fa-user-nurse', category: 'Cuidados & Saúde', keywords: 'enfermeira saude curativo medicacao home care' },
  { label: 'Banho & Tosa / Pets', value: 'fa-paw', category: 'Cuidados & Saúde', keywords: 'pet pata cachorro gato animal tosa banho passeador' },
  { label: 'Adestrador / Cães', value: 'fa-dog', category: 'Cuidados & Saúde', keywords: 'cachorro cao dog pet adestramento passear hotelzinho' },
  { label: 'Cuidados com Gatos', value: 'fa-cat', category: 'Cuidados & Saúde', keywords: 'gato felino pet sitter hotel cuidados' },

  // Eventos & Gerais
  { label: 'Barman & Garçom', value: 'fa-champagne-glasses', category: 'Eventos & Gerais', keywords: 'tacas brinde festa evento garcom barman coquetel' },
  { label: 'Bolos & Festas', value: 'fa-cake-candles', category: 'Eventos & Gerais', keywords: 'bolo vela confeitaria doce aniversario festa buffet' },
  { label: 'DJ & Sonorização', value: 'fa-music', category: 'Eventos & Gerais', keywords: 'musica dj som iluminacao banda festa evento' },
  { label: 'Locução & Cerimonial', value: 'fa-microphone', category: 'Eventos & Gerais', keywords: 'microfone locutor cerimonialista apresentador palestra' },
  { label: 'Costura & Lavanderia', value: 'fa-shirt', category: 'Eventos & Gerais', keywords: 'camisa roupa costureira ajuste bainha lavanderia passar' },
  { label: 'Serviços Administrativos', value: 'fa-briefcase', category: 'Eventos & Gerais', keywords: 'maleta servico geral escritorio administrativo' },
  { label: 'Categoria Geral', value: 'fa-layer-group', category: 'Eventos & Gerais', keywords: 'camadas geral categorias diversos varios' },
  { label: 'Serviço Premium / Destaque', value: 'fa-star', category: 'Eventos & Gerais', keywords: 'estrela destaque premium especial avaliacao' },
  { label: 'Consultoria & Negócios', value: 'fa-handshake', category: 'Eventos & Gerais', keywords: 'aperto mao consultoria parceria acordo contrato' }
];
