import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/assets.dart';
import '../utils/image_cache_manager.dart';
import '../game/enemy.dart';

/// Renders all game entities.
/// Si los PNG cargan → los usa.
/// Si NO cargan → dibuja sprites procedurales detallados (pixel art con Canvas).
class SpritePainter {
  static final _imgCache = ImageCacheManager();

  // ─── PLAYER ───────────────────────────────────────────────────────────────
  static void drawPlayer(Canvas canvas, double x, double y, double angle,
      bool invulnerable, double time) {
    if (invulnerable && (time * 12).floor() % 2 == 0) return;

    final img = _imgCache.get(GameAssets.player);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    if (img != null) {
      // Glow del motor
      canvas.drawCircle(
        const Offset(-8, 0),
        10,
        Paint()
          ..color =
              InfernoColors.playerGlow.withOpacity(0.18 + 0.08 * sin(time * 8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      _drawImageCentered(canvas, img);
    } else {
      _drawPlayerSprite(canvas, time);
    }

    canvas.restore();
  }

  /// Sprite procedural del jugador: nave angular estilo DOOM top-down
  static void _drawPlayerSprite(Canvas canvas, double time) {
    // Glow de motor (pulsante)
    canvas.drawCircle(
      const Offset(-9, 0),
      8,
      Paint()
        ..color =
            InfernoColors.playerGlow.withOpacity(0.3 + 0.15 * sin(time * 8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Cuerpo principal (nave triangular)
    final bodyPath = Path()
      ..moveTo(12, 0) // Punta delantera
      ..lineTo(-8, -8) // Ala izquierda
      ..lineTo(-4, 0) // Centro trasero
      ..lineTo(-8, 8) // Ala derecha
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = InfernoColors.playerShell);

    // Detalle interior (core brillante)
    final corePath = Path()
      ..moveTo(8, 0)
      ..lineTo(-2, -4)
      ..lineTo(-2, 4)
      ..close();
    canvas.drawPath(corePath, Paint()..color = InfernoColors.playerCore);

    // Cañón
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, -1.5, 10, 3),
        const Radius.circular(1),
      ),
      Paint()..color = InfernoColors.playerGun,
    );

    // Glow del cañón
    canvas.drawCircle(
      const Offset(16, 0),
      3,
      Paint()
        ..color = InfernoColors.playerCore.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ─── WRAITH (Imp) ─────────────────────────────────────────────────────────
  static void drawImp(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state) {
    final img = _imgCache.get(GameAssets.wraith);

    if (state == EnemyState.dying) {
      _drawDeathEffect(canvas, x, y, InfernoColors.wraithCore);
      return;
    }
    if (state == EnemyState.hurt) {
      _drawHurtFlash(canvas, x, y, 14);
      _renderEntity(canvas, x, y, angle, img, () => _drawWraithSprite(canvas));
      return;
    }

    _renderEntity(canvas, x, y, angle, img, () => _drawWraithSprite(canvas));
    if (healthPercent < 1.0) _drawHealthBar(canvas, x, y, healthPercent, 14);
  }

  static void _drawWraithSprite(Canvas canvas) {
    // Cuerpo fantasmal: elipse irregular
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 0), width: 22, height: 26),
      Paint()..color = InfernoColors.wraithCore,
    );
    // Contorno oscuro
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 0), width: 22, height: 26),
      Paint()
        ..color = const Color(0xFF8B1A00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Ojos amarillos (2 puntos brillantes)
    canvas.drawCircle(
      const Offset(-4, -4),
      3,
      Paint()
        ..color = InfernoColors.wraithEyes
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
        const Offset(-4, -4), 2, Paint()..color = InfernoColors.wraithEyes);
    canvas.drawCircle(
      const Offset(4, -4),
      3,
      Paint()
        ..color = InfernoColors.wraithEyes
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
        const Offset(4, -4), 2, Paint()..color = InfernoColors.wraithEyes);
    // Boca (línea dentada)
    final mouthPaint = Paint()
      ..color = const Color(0xFF1A0000)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-5, 5), const Offset(-2, 8), mouthPaint);
    canvas.drawLine(const Offset(-2, 8), const Offset(1, 5), mouthPaint);
    canvas.drawLine(const Offset(1, 5), const Offset(4, 8), mouthPaint);
    canvas.drawLine(const Offset(4, 8), const Offset(7, 5), mouthPaint);
    // Glow interno
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 0), width: 14, height: 16),
      Paint()
        ..color = InfernoColors.wraithCore.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  // ─── CRUSHER (Demon) ──────────────────────────────────────────────────────
  static void drawDemon(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state) {
    final img = _imgCache.get(GameAssets.crusher);

    if (state == EnemyState.dying) {
      _drawDeathEffect(canvas, x, y, InfernoColors.crusherCore);
      return;
    }
    if (state == EnemyState.hurt) {
      _drawHurtFlash(canvas, x, y, 19);
      _renderEntity(canvas, x, y, angle, img, () => _drawCrusherSprite(canvas));
      return;
    }

    _renderEntity(canvas, x, y, angle, img, () => _drawCrusherSprite(canvas));
    if (healthPercent < 1.0) _drawHealthBar(canvas, x, y, healthPercent, 20);
  }

  static void _drawCrusherSprite(Canvas canvas) {
    // Cuerpo cuadrado robusto
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 2), width: 32, height: 28),
        const Radius.circular(3),
      ),
      Paint()..color = InfernoColors.crusherCore,
    );
    // Armadura lateral (placas)
    canvas.drawRect(
      const Rect.fromLTWH(-18, -6, 6, 16),
      Paint()..color = InfernoColors.crusherShell,
    );
    canvas.drawRect(
      const Rect.fromLTWH(12, -6, 6, 16),
      Paint()..color = InfernoColors.crusherShell,
    );
    // Cabeza
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -8), width: 20, height: 14),
        const Radius.circular(2),
      ),
      Paint()..color = InfernoColors.crusherShell,
    );
    // Cuernos / pinchos
    final spikePaint = Paint()..color = InfernoColors.crusherSpike;
    final spike1 = Path()
      ..moveTo(-8, -14)
      ..lineTo(-5, -22)
      ..lineTo(-2, -14)
      ..close();
    canvas.drawPath(spike1, spikePaint);
    final spike2 = Path()
      ..moveTo(2, -14)
      ..lineTo(5, -24)
      ..lineTo(8, -14)
      ..close();
    canvas.drawPath(spike2, spikePaint);
    // Ojos rojos brillantes
    canvas.drawCircle(
      const Offset(-4, -9),
      3.5,
      Paint()
        ..color = InfernoColors.crusherSpike
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(const Offset(-4, -9), 2, Paint()..color = Colors.red);
    canvas.drawCircle(
      const Offset(4, -9),
      3.5,
      Paint()
        ..color = InfernoColors.crusherSpike
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(const Offset(4, -9), 2, Paint()..color = Colors.red);
    // Contorno oscuro
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 2), width: 32, height: 28),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ─── SPECTER (Cacodemon) ──────────────────────────────────────────────────
  static void drawCacodemon(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state, double time) {
    final img = _imgCache.get(GameAssets.specter);
    double bob = sin(time * 2.8) * 5;

    if (state == EnemyState.dying) {
      _drawDeathEffect(canvas, x, y + bob, InfernoColors.specterCore);
      return;
    }
    if (state == EnemyState.hurt) {
      _drawHurtFlash(canvas, x, y + bob, 21);
      return;
    }

    canvas.save();
    canvas.translate(x, y + bob);
    canvas.rotate(angle);

    // Glow ambiente pulsante (siempre, independientemente de si hay imagen)
    canvas.drawCircle(
      Offset.zero,
      26,
      Paint()
        ..color =
            InfernoColors.specterGlow.withOpacity(0.14 + 0.08 * sin(time * 4))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    if (img != null) {
      _drawImageCentered(canvas, img);
    } else {
      _drawSpecterSprite(canvas, time);
    }

    canvas.restore();
    if (healthPercent < 1.0) {
      _drawHealthBar(canvas, x, y + bob, healthPercent, 22);
    }
  }

  static void _drawSpecterSprite(Canvas canvas, double time) {
    // Cuerpo esférico morado
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()..color = InfernoColors.specterCore,
    );
    // Textura interna (círculo más claro)
    canvas.drawCircle(
      const Offset(-3, -3),
      12,
      Paint()..color = const Color(0xFF6A0090).withOpacity(0.6),
    );
    // Ojo central verde neón (el rasgo icónico del Cacodemon)
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()
        ..color = InfernoColors.specterEye.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
        Offset.zero, 5, Paint()..color = InfernoColors.specterEye);
    canvas.drawCircle(Offset.zero, 2.5, Paint()..color = Colors.white);
    // Púas alrededor del cuerpo (5 spikes)
    final spikePaint = Paint()
      ..color = const Color(0xFF7B1FA2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      double spikeAngle = (i / 5) * 2 * pi + time * 0.5;
      double inner = 20.0;
      double outer = 28.0;
      canvas.drawLine(
        Offset(cos(spikeAngle) * inner, sin(spikeAngle) * inner),
        Offset(cos(spikeAngle) * outer, sin(spikeAngle) * outer),
        spikePaint,
      );
    }
    // Contorno
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..color = const Color(0xFF4A0060)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  // ─── PROYECTILES ──────────────────────────────────────────────────────────
  static void drawProjectile(Canvas canvas, double x, double y,
      bool isPlayerBullet, WeaponType weaponType) {
    if (!isPlayerBullet) {
      _drawEnemyProjectile(canvas, x, y);
      return;
    }
    if (weaponType == WeaponType.plasmaRifle) {
      _drawPlasmaProjectile(canvas, x, y);
      return;
    }
    _drawPlayerBullet(canvas, x, y);
  }

  static void _drawPlayerBullet(Canvas canvas, double x, double y) {
    final img = _imgCache.get(GameAssets.bulletPlayer);
    // Trail glow dorado elongado (siempre procedural)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 20, height: 7),
      Paint()
        ..color = InfernoColors.bulletPlayer.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    if (img != null) {
      canvas.save();
      canvas.translate(x, y);
      _drawImageCentered(canvas, img);
      canvas.restore();
    } else {
      // Fallback: bala dorada brillante
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 12, height: 6),
        Paint()..color = InfernoColors.bulletPlayer,
      );
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = Colors.white.withOpacity(0.8),
      );
    }
  }

  static void _drawPlasmaProjectile(Canvas canvas, double x, double y) {
    final img = _imgCache.get(GameAssets.plasma);
    // Glow cian exterior
    canvas.drawCircle(
      Offset(x, y),
      16,
      Paint()
        ..color = InfernoColors.plasma.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      Offset(x, y),
      8,
      Paint()
        ..color = InfernoColors.plasma.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    if (img != null) {
      canvas.save();
      canvas.translate(x, y);
      _drawImageCentered(canvas, img);
      canvas.restore();
    } else {
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = InfernoColors.plasma);
      canvas.drawCircle(
          Offset(x, y), 3, Paint()..color = Colors.white.withOpacity(0.9));
    }
  }

  static void _drawEnemyProjectile(Canvas canvas, double x, double y) {
    final img = _imgCache.get(GameAssets.bulletEnemy);
    // Glow rojo amenazante
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 18, height: 10),
      Paint()
        ..color = InfernoColors.bulletEnemy.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    if (img != null) {
      canvas.save();
      canvas.translate(x, y);
      _drawImageCentered(canvas, img);
      canvas.restore();
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 11, height: 7),
        Paint()..color = InfernoColors.bulletEnemy,
      );
      canvas.drawCircle(
          Offset(x, y), 2.5, Paint()..color = Colors.orange.withOpacity(0.9));
    }
  }

  // ─── PICKUPS ──────────────────────────────────────────────────────────────
  static void drawPickup(
      Canvas canvas, double x, double y, PickupType type, double bobOffset) {
    double drawY = y + sin(bobOffset) * 4;
    Color glowColor = type == PickupType.health
        ? InfernoColors.pickupHealth
        : type == PickupType.ammo
            ? InfernoColors.pickupAmmo
            : InfernoColors.pickupWeapon;

    double pulse = 0.5 + 0.5 * sin(bobOffset * 2);
    // Glow pulsante de color
    canvas.drawCircle(
      Offset(x, drawY),
      20,
      Paint()
        ..color = glowColor.withOpacity(0.18 + pulse * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    String assetPath = type == PickupType.health
        ? GameAssets.pickupHealth
        : type == PickupType.ammo
            ? GameAssets.pickupAmmo
            : GameAssets.pickupWeapon;

    final img = _imgCache.get(assetPath);

    canvas.save();
    canvas.translate(x, drawY);
    canvas.rotate(bobOffset * 0.3);

    if (img != null) {
      _drawImageCentered(canvas, img);
    } else {
      _drawPickupFallback(canvas, type, glowColor);
    }
    canvas.restore();
  }

  static void _drawPickupFallback(Canvas canvas, PickupType type, Color color) {
    if (type == PickupType.health) {
      // Cruz médica
      canvas.drawRect(
          const Rect.fromLTWH(-10, -3, 20, 6), Paint()..color = color);
      canvas.drawRect(
          const Rect.fromLTWH(-3, -10, 6, 20), Paint()..color = color);
      // Brillo
      canvas.drawRect(const Rect.fromLTWH(-9, -2, 18, 4),
          Paint()..color = Colors.white.withOpacity(0.3));
    } else if (type == PickupType.ammo) {
      // Bala estilizada
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(0, 0), width: 8, height: 16),
            const Radius.circular(3)),
        Paint()..color = color,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(0, -9), width: 6, height: 6),
            const Radius.circular(3)),
        Paint()..color = const Color(0xFFFFD740),
      );
    } else {
      // Ícono de arma: forma de pistola simplificada
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-10, -4, 18, 7), const Radius.circular(2)),
        Paint()..color = color,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-2, 3, 6, 8), const Radius.circular(1)),
        Paint()..color = color,
      );
      canvas.drawRect(const Rect.fromLTWH(5, -4, 8, 4), Paint()..color = color);
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  /// Dibuja una entidad: si hay imagen la usa, si no llama al fallback procedural.
  static void _renderEntity(Canvas canvas, double x, double y, double angle,
      ui.Image? img, VoidCallback fallback) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    if (img != null) {
      _drawImageCentered(canvas, img);
    } else {
      fallback();
    }
    canvas.restore();
  }

  static void _drawImage(Canvas canvas, ui.Image img, double x, double y,
      {Paint? paint}) {
    canvas.drawImage(img, Offset(x, y), paint ?? Paint());
  }

  static void _drawImageCentered(Canvas canvas, ui.Image img, {Paint? paint}) {
    canvas.drawImage(
      img,
      Offset(-img.width / 2.0, -img.height / 2.0),
      paint ?? Paint(),
    );
  }

  static void _drawDeathEffect(Canvas canvas, double x, double y, Color color) {
    canvas.drawCircle(
      Offset(x, y),
      14,
      Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(Offset(x, y), 7, Paint()..color = color.withOpacity(0.3));
  }

  static void _drawHurtFlash(Canvas canvas, double x, double y, double r) {
    canvas.drawCircle(
        Offset(x, y), r, Paint()..color = Colors.white.withOpacity(0.85));
  }

  static void _drawFallbackCircle(
      Canvas canvas, double x, double y, double r, Color c) {
    canvas.drawCircle(Offset(x, y), r, Paint()..color = c);
  }

  static void _drawHealthBar(
      Canvas canvas, double x, double y, double percent, double entityRadius) {
    double barW = entityRadius * 2 + 8;
    double barH = 4;
    double barY = y - entityRadius - 12;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - barW / 2, barY, barW, barH),
          const Radius.circular(2)),
      Paint()..color = const Color(0xFF111111),
    );

    Color hc = percent > 0.6
        ? InfernoColors.healthFull
        : percent > 0.3
            ? InfernoColors.healthMid
            : InfernoColors.healthLow;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barW / 2, barY, barW * percent, barH),
          const Radius.circular(2)),
      Paint()
        ..color = hc
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
  }
}
