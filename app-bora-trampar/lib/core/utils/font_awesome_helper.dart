import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FontAwesomeHelper {
  static final Map<String, FaIconData> _icons = {
    // Construção & Obras
    'fa-hammer': FontAwesomeIcons.hammer,
    'hammer': FontAwesomeIcons.hammer,
    'fa-trowel-bricks': FontAwesomeIcons.trowelBricks,
    'trowel-bricks': FontAwesomeIcons.trowelBricks,
    'fa-trowel': FontAwesomeIcons.trowel,
    'trowel': FontAwesomeIcons.trowel,
    'fa-helmet-safety': FontAwesomeIcons.helmetSafety,
    'helmet-safety': FontAwesomeIcons.helmetSafety,
    'fa-ruler-combined': FontAwesomeIcons.rulerCombined,
    'ruler-combined': FontAwesomeIcons.rulerCombined,
    'fa-tape': FontAwesomeIcons.tape,
    'tape': FontAwesomeIcons.tape,
    'fa-hard-hat': FontAwesomeIcons.helmetSafety,
    'hard-hat': FontAwesomeIcons.helmetSafety,
    'fa-road': FontAwesomeIcons.road,
    'road': FontAwesomeIcons.road,
    'fa-dolly': FontAwesomeIcons.dolly,
    'dolly': FontAwesomeIcons.dolly,

    // Pintura & Acabamento
    'fa-paint-roller': FontAwesomeIcons.paintRoller,
    'paint-roller': FontAwesomeIcons.paintRoller,
    'fa-brush': FontAwesomeIcons.brush,
    'brush': FontAwesomeIcons.brush,
    'fa-palette': FontAwesomeIcons.palette,
    'palette': FontAwesomeIcons.palette,
    'fa-fill-drip': FontAwesomeIcons.fillDrip,
    'fill-drip': FontAwesomeIcons.fillDrip,
    'fa-spray-can': FontAwesomeIcons.sprayCan,
    'spray-can': FontAwesomeIcons.sprayCan,

    // Elétrica & Iluminação
    'fa-bolt': FontAwesomeIcons.bolt,
    'bolt': FontAwesomeIcons.bolt,
    'fa-plug': FontAwesomeIcons.plug,
    'plug': FontAwesomeIcons.plug,
    'fa-lightbulb': FontAwesomeIcons.lightbulb,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'fa-charging-station': FontAwesomeIcons.chargingStation,
    'charging-station': FontAwesomeIcons.chargingStation,
    'fa-solar-panel': FontAwesomeIcons.solarPanel,
    'solar-panel': FontAwesomeIcons.solarPanel,
    'fa-battery-full': FontAwesomeIcons.batteryFull,
    'battery-full': FontAwesomeIcons.batteryFull,
    'fa-power-off': FontAwesomeIcons.powerOff,
    'power-off': FontAwesomeIcons.powerOff,

    // Hidráulica & Encanamento
    'fa-faucet': FontAwesomeIcons.faucet,
    'faucet': FontAwesomeIcons.faucet,
    'fa-faucet-drip': FontAwesomeIcons.faucetDrip,
    'faucet-drip': FontAwesomeIcons.faucetDrip,
    'fa-droplet': FontAwesomeIcons.droplet,
    'droplet': FontAwesomeIcons.droplet,
    'fa-shower': FontAwesomeIcons.shower,
    'shower': FontAwesomeIcons.shower,
    'fa-toilet': FontAwesomeIcons.toilet,
    'toilet': FontAwesomeIcons.toilet,
    'fa-water': FontAwesomeIcons.water,
    'water': FontAwesomeIcons.water,

    // Ferramentas & Reparos
    'fa-screwdriver-wrench': FontAwesomeIcons.screwdriverWrench,
    'screwdriver-wrench': FontAwesomeIcons.screwdriverWrench,
    'fa-screwdriver': FontAwesomeIcons.screwdriver,
    'screwdriver': FontAwesomeIcons.screwdriver,
    'fa-wrench': FontAwesomeIcons.wrench,
    'wrench': FontAwesomeIcons.wrench,
    'fa-gear': FontAwesomeIcons.gear,
    'gear': FontAwesomeIcons.gear,
    'fa-gears': FontAwesomeIcons.gears,
    'gears': FontAwesomeIcons.gears,
    'fa-toolbox': FontAwesomeIcons.toolbox,
    'toolbox': FontAwesomeIcons.toolbox,
    'fa-lock': FontAwesomeIcons.lock,
    'lock': FontAwesomeIcons.lock,
    'fa-key': FontAwesomeIcons.key,
    'key': FontAwesomeIcons.key,

    // Marcenaria & Móveis
    'fa-chair': FontAwesomeIcons.chair,
    'chair': FontAwesomeIcons.chair,
    'fa-couch': FontAwesomeIcons.couch,
    'couch': FontAwesomeIcons.couch,
    'fa-bed': FontAwesomeIcons.bed,
    'bed': FontAwesomeIcons.bed,
    'fa-door-open': FontAwesomeIcons.doorOpen,
    'door-open': FontAwesomeIcons.doorOpen,
    'fa-door-closed': FontAwesomeIcons.doorClosed,
    'door-closed': FontAwesomeIcons.doorClosed,
    'fa-tree': FontAwesomeIcons.tree,
    'tree': FontAwesomeIcons.tree,

    // Limpeza & Higienização
    'fa-broom': FontAwesomeIcons.broom,
    'broom': FontAwesomeIcons.broom,
    'fa-soap': FontAwesomeIcons.soap,
    'soap': FontAwesomeIcons.soap,
    'fa-bucket': FontAwesomeIcons.bucket,
    'bucket': FontAwesomeIcons.bucket,
    'fa-pump-soap': FontAwesomeIcons.pumpSoap,
    'pump-soap': FontAwesomeIcons.pumpSoap,
    'fa-hand-sparkles': FontAwesomeIcons.handSparkles,
    'hand-sparkles': FontAwesomeIcons.handSparkles,
    'fa-trash-can': FontAwesomeIcons.trashCan,
    'trash-can': FontAwesomeIcons.trashCan,
    'fa-bug': FontAwesomeIcons.bug,
    'bug': FontAwesomeIcons.bug,

    // Jardinagem & Piscina
    'fa-seedling': FontAwesomeIcons.seedling,
    'seedling': FontAwesomeIcons.seedling,
    'fa-leaf': FontAwesomeIcons.leaf,
    'leaf': FontAwesomeIcons.leaf,
    'fa-scissors': FontAwesomeIcons.scissors,
    'scissors': FontAwesomeIcons.scissors,
    'fa-person-swimming': FontAwesomeIcons.personSwimming,
    'person-swimming': FontAwesomeIcons.personSwimming,
    'fa-water-ladder': FontAwesomeIcons.waterLadder,
    'water-ladder': FontAwesomeIcons.waterLadder,

    // Climatização
    'fa-snowflake': FontAwesomeIcons.snowflake,
    'snowflake': FontAwesomeIcons.snowflake,
    'fa-fan': FontAwesomeIcons.fan,
    'fan': FontAwesomeIcons.fan,
    'fa-wind': FontAwesomeIcons.wind,
    'wind': FontAwesomeIcons.wind,
    'fa-fire': FontAwesomeIcons.fire,
    'fire': FontAwesomeIcons.fire,
    'fa-temperature-arrow-down': FontAwesomeIcons.temperatureArrowDown,
    'temperature-arrow-down': FontAwesomeIcons.temperatureArrowDown,

    // Segurança
    'fa-shield-halved': FontAwesomeIcons.shieldHalved,
    'shield-halved': FontAwesomeIcons.shieldHalved,
    'fa-video': FontAwesomeIcons.video,
    'video': FontAwesomeIcons.video,
    'fa-camera': FontAwesomeIcons.camera,
    'camera': FontAwesomeIcons.camera,
    'fa-bell': FontAwesomeIcons.bell,
    'bell': FontAwesomeIcons.bell,
    'fa-bell-concierge': FontAwesomeIcons.bellConcierge,
    'bell-concierge': FontAwesomeIcons.bellConcierge,

    // Automotivo
    'fa-car': FontAwesomeIcons.car,
    'car': FontAwesomeIcons.car,
    'fa-motorcycle': FontAwesomeIcons.motorcycle,
    'motorcycle': FontAwesomeIcons.motorcycle,
    'fa-truck': FontAwesomeIcons.truck,
    'truck': FontAwesomeIcons.truck,
    'fa-truck-pickup': FontAwesomeIcons.truckPickup,
    'truck-pickup': FontAwesomeIcons.truckPickup,
    'fa-oil-can': FontAwesomeIcons.oilCan,
    'oil-can': FontAwesomeIcons.oilCan,
    'fa-gas-pump': FontAwesomeIcons.gasPump,
    'gas-pump': FontAwesomeIcons.gasPump,
    'fa-car-battery': FontAwesomeIcons.carBattery,
    'car-battery': FontAwesomeIcons.carBattery,

    // Fretes & Mudanças
    'fa-truck-ramp-box': FontAwesomeIcons.truckRampBox,
    'truck-ramp-box': FontAwesomeIcons.truckRampBox,
    'fa-boxes-packing': FontAwesomeIcons.boxesPacking,
    'boxes-packing': FontAwesomeIcons.boxesPacking,
    'fa-box': FontAwesomeIcons.box,
    'box': FontAwesomeIcons.box,
    'fa-box-open': FontAwesomeIcons.boxOpen,
    'box-open': FontAwesomeIcons.boxOpen,

    // Tecnologia & TI
    'fa-laptop': FontAwesomeIcons.laptop,
    'laptop': FontAwesomeIcons.laptop,
    'fa-desktop': FontAwesomeIcons.desktop,
    'desktop': FontAwesomeIcons.desktop,
    'fa-mobile-screen': FontAwesomeIcons.mobileScreen,
    'mobile-screen': FontAwesomeIcons.mobileScreen,
    'fa-wifi': FontAwesomeIcons.wifi,
    'wifi': FontAwesomeIcons.wifi,
    'fa-network-wired': FontAwesomeIcons.networkWired,
    'network-wired': FontAwesomeIcons.networkWired,
    'fa-print': FontAwesomeIcons.print,
    'print': FontAwesomeIcons.print,
    'fa-tv': FontAwesomeIcons.tv,
    'tv': FontAwesomeIcons.tv,

    // Cuidados & Saúde
    'fa-heart': FontAwesomeIcons.heart,
    'heart': FontAwesomeIcons.heart,
    'fa-baby': FontAwesomeIcons.baby,
    'baby': FontAwesomeIcons.baby,
    'fa-user-nurse': FontAwesomeIcons.userNurse,
    'user-nurse': FontAwesomeIcons.userNurse,
    'fa-paw': FontAwesomeIcons.paw,
    'paw': FontAwesomeIcons.paw,
    'fa-dog': FontAwesomeIcons.dog,
    'dog': FontAwesomeIcons.dog,
    'fa-cat': FontAwesomeIcons.cat,
    'cat': FontAwesomeIcons.cat,

    // Eventos & Gerais
    'fa-champagne-glasses': FontAwesomeIcons.champagneGlasses,
    'champagne-glasses': FontAwesomeIcons.champagneGlasses,
    'fa-cake-candles': FontAwesomeIcons.cakeCandles,
    'cake-candles': FontAwesomeIcons.cakeCandles,
    'fa-music': FontAwesomeIcons.music,
    'music': FontAwesomeIcons.music,
    'fa-microphone': FontAwesomeIcons.microphone,
    'microphone': FontAwesomeIcons.microphone,
    'fa-shirt': FontAwesomeIcons.shirt,
    'shirt': FontAwesomeIcons.shirt,
    'fa-briefcase': FontAwesomeIcons.briefcase,
    'briefcase': FontAwesomeIcons.briefcase,
    'fa-layer-group': FontAwesomeIcons.layerGroup,
    'layer-group': FontAwesomeIcons.layerGroup,
    'fa-star': FontAwesomeIcons.star,
    'star': FontAwesomeIcons.star,
    'fa-handshake': FontAwesomeIcons.handshake,
    'handshake': FontAwesomeIcons.handshake,
  };

  /// Converte qualquer nome ou classe de ícone FontAwesome no FaIconData correspondente (para uso com FaIcon).
  static FaIconData getFaIcon(
    String? iconName, {
    String? fallbackText,
    FaIconData defaultIcon = FontAwesomeIcons.layerGroup,
  }) {
    if (iconName != null && iconName.trim().isNotEmpty) {
      String clean = iconName.trim().toLowerCase();
      // Remover prefixos comuns de FontAwesome
      clean = clean
          .replaceAll('fa-solid', '')
          .replaceAll('fa-regular', '')
          .replaceAll('fa-brands', '')
          .replaceAll('fas ', '')
          .replaceAll('far ', '')
          .replaceAll('fab ', '')
          .replaceAll('fa-', '')
          .trim();

      // Busca direta
      if (_icons.containsKey(clean)) {
        return _icons[clean]!;
      }
      if (_icons.containsKey('fa-$clean')) {
        return _icons['fa-$clean']!;
      }
    }

    // Fallback inteligente por palavras-chave
    final text = (fallbackText ?? iconName ?? '').toLowerCase();
    if (text.contains('constru') || text.contains('obra') || text.contains('alvenaria') || text.contains('pedreiro')) {
      return FontAwesomeIcons.hammer;
    }
    if (text.contains('pint') || text.contains('acabamento') || text.contains('verniz')) {
      return FontAwesomeIcons.paintRoller;
    }
    if (text.contains('eletr') || text.contains('energia') || text.contains('luz')) {
      return FontAwesomeIcons.bolt;
    }
    if (text.contains('hidraul') || text.contains('encan') || text.contains('agua') || text.contains('vazam')) {
      return FontAwesomeIcons.faucetDrip;
    }
    if (text.contains('limp') || text.contains('faxina') || text.contains('diaria')) {
      return FontAwesomeIcons.broom;
    }
    if (text.contains('jardim') || text.contains('paisag') || text.contains('poda')) {
      return FontAwesomeIcons.seedling;
    }
    if (text.contains('piscina')) {
      return FontAwesomeIcons.personSwimming;
    }
    if (text.contains('marcen') || text.contains('movel') || text.contains('montag')) {
      return FontAwesomeIcons.screwdriverWrench;
    }
    if (text.contains('ar-condicionado') || text.contains('ar condicionado') || text.contains('refrig')) {
      return FontAwesomeIcons.snowflake;
    }
    if (text.contains('carro') || text.contains('auto') || text.contains('mecanic') || text.contains('veiculo')) {
      return FontAwesomeIcons.car;
    }
    if (text.contains('moto')) {
      return FontAwesomeIcons.motorcycle;
    }
    if (text.contains('frete') || text.contains('mudanc') || text.contains('carreto')) {
      return FontAwesomeIcons.truckRampBox;
    }
    if (text.contains('seguranca') || text.contains('alarme') || text.contains('cftv') || text.contains('camera')) {
      return FontAwesomeIcons.shieldHalved;
    }
    if (text.contains('chave') || text.contains('fechadura')) {
      return FontAwesomeIcons.key;
    }
    if (text.contains('comput') || text.contains('notebook') || text.contains('ti') || text.contains('tecnologia')) {
      return FontAwesomeIcons.laptop;
    }
    if (text.contains('celular') || text.contains('smartphone')) {
      return FontAwesomeIcons.mobileScreen;
    }
    if (text.contains('pet') || text.contains('cao') || text.contains('cachorro') || text.contains('gato') || text.contains('animal')) {
      return FontAwesomeIcons.paw;
    }
    if (text.contains('baba') || text.contains('infantil') || text.contains('crianca')) {
      return FontAwesomeIcons.baby;
    }
    if (text.contains('saude') || text.contains('enferm') || text.contains('cuidador')) {
      return FontAwesomeIcons.heart;
    }

    return defaultIcon;
  }

  /// Converte qualquer nome ou classe de ícone FontAwesome no IconData correspondente (para uso com o widget Icon padrão).
  static IconData getIcon(
    String? iconName, {
    String? fallbackText,
    IconData? defaultIcon,
  }) {
    final faIcon = getFaIcon(
      iconName,
      fallbackText: fallbackText,
      defaultIcon: defaultIcon != null ? FaIconData(defaultIcon) : FontAwesomeIcons.layerGroup,
    );
    return faIcon.data;
  }
}
