# 🔥 INFERNO 2D

Juego shooter top-down para Android desarrollado con **Flutter & Dart puro**.  
Sin motores de juego externos (Flame, Unity, Godot). Renderizado procedural con `CustomPainter` y `Canvas`.

---

## 📱 Descargar APK

El APK se genera automáticamente con GitHub Actions en cada push a `main`.

1. Ve a la pestaña **Actions** del repositorio
2. Abre el último workflow **Build APK** ✅
3. Descarga el artefacto **INFERNO_2D_release**

---

## 🛠️ Correr localmente

```bash
# Requisito: Flutter instalado — https://flutter.dev/docs/get-started/install
flutter pub get
flutter run                  # Debug en emulador/dispositivo
flutter build apk --release  # Genera el APK
```

El APK queda en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎮 Controles

| Control | Acción |
|---------|--------|
| Joystick izquierdo | Mover al jugador |
| Botón rojo (derecha) | Disparar |
| Botón dorado (derecha) | Cambiar arma |

## 🔫 Armas

| Arma | Munición | Descripción |
|------|----------|-------------|
| Pistola | ∞ | Disparo básico, cadencia media |
| Escopeta | Limitada | Spread de 5 balas |
| Rifle de Plasma | Limitada | Rápido, proyectil grande |

## 👾 Enemigos

| Nombre | Tipo | Descripción |
|--------|------|-------------|
| Wraith | Ranged | Rápido, poco vida, dispara a distancia |
| Crusher | Melee | Lento, mucha vida, daño de contacto alto |
| Specter | Ranged/Flying | Vuela, ataca a distancia, vida media |

---

## 🏗️ Arquitectura

```
lib/
├── main.dart              # Entry point + pantalla de carga
├── game/                  # Lógica del juego (sin UI)
│   ├── game_engine.dart   # Game Loop con Ticker (60 FPS)
│   ├── player.dart        # Jugador, movimiento, inventario
│   ├── enemy.dart         # IA base de enemigos
│   ├── enemy_types.dart   # Wraith, Crusher, Specter
│   ├── projectile.dart    # Balas y proyectiles
│   ├── weapon.dart        # Sistema de 3 armas
│   ├── pickup.dart        # Items recolectables
│   ├── game_map.dart      # Grid de tiles
│   ├── levels.dart        # 3 niveles diseñados a mano
│   └── collision.dart     # AABB + detección círculo-círculo
├── rendering/             # Canvas rendering
│   ├── game_renderer.dart # CustomPainter principal + cámara
│   ├── sprite_painter.dart# Sprites PNG via Canvas.drawImage
│   └── effects.dart       # Partículas, flash de daño
├── ui/                    # Interfaz
│   ├── hud.dart           # HUD oscuro estilo arcade
│   ├── touch_controls.dart# Joystick virtual + botones PNG
│   ├── main_menu.dart     # Menú animado con grid de perspectiva
│   └── game_over_screen.dart
└── utils/
    ├── constants.dart     # InfernoColors + GameConstants
    ├── assets.dart        # Rutas centralizadas de assets
    ├── image_cache_manager.dart # Precarga de PNG a ui.Image
    └── audio_manager.dart # Placeholder de audio
```

## ❓ Preguntas frecuentes (ExpoGo)

**¿Cómo funcionan las colisiones?**  
Sistema propio en `collision.dart`. Paredes: circle vs AABB resolviendo penetración. Entidades: distancia euclidiana vs suma de radios.

**¿Cómo se optimiza el CustomPainter?**  
Solo se renderizan tiles en el rango visible de la cámara. Los assets PNG se precargan a `ui.Image` en la pantalla de carga para evitar decodificación por frame.

**¿Cómo funciona el Game Loop?**  
`Ticker` de Flutter en `SingleTickerProviderStateMixin`. Delta time en segundos, cap a 50ms para evitar saltos físicos. `setState()` al final de cada tick dispara el repaint.

---

*Hecho con Flutter — sin motores externos*
