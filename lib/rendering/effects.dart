import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/game_engine.dart';

class EffectsRenderer {
  // ──────────────────────────────────────────────────────────────────────
  // PARTÍCULAS
  // ── MEJORA 8: Partículas con forma ovalada rotada (chispas)
  // ──────────────────────────────────────────────────────────────────────
  static void drawParticles(Canvas canvas, List<ParticleEffect> particles) {
    for (var p in particles) {
      if (!p.isActive) continue;

      double opacity = (1.0 - p.progress).clamp(0.0, 1.0);
      double currentSize = p.size * (1.0 - p.progress * 0.6);

      Color color;
      switch (p.type) {
        case ParticleType.impact:
          color = Color.lerp(
            InfernoColors.bulletPlayer,
            const Color(0xFFFF6D00),
            p.progress,
          )!.withOpacity(opacity);
          break;
        case ParticleType.death:
          color = Color.lerp(
            InfernoColors.explosionHot,
            InfernoColors.explosionCool,
            p.progress,
          )!.withOpacity(opacity);
          break;
        case ParticleType.muzzle:
          color = InfernoColors.muzzleFlash.withOpacity(opacity * 0.8);
          break;
      }

      // Calcular ángulo de vuelo para rotar el óvalo
      double velocityAngle = atan2(p.dy, p.dx);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(velocityAngle);

      // ── Óvalo orientado en dirección de movimiento (chispa) ──────────
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: currentSize * 2.5, // Alargado en dirección de vuelo
          height: currentSize * 0.9,
        ),
        Paint()..color = color,
      );

      // Glow para partículas grandes
      if (currentSize > 2.5) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: currentSize * 5.0,
            height: currentSize * 2.0,
          ),
          Paint()
            ..color = color.withOpacity(opacity * 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }

      canvas.restore();
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // DAMAGE FLASH (sin cambios, ya estaba bien)
  // ──────────────────────────────────────────────────────────────────────
  static void drawDamageFlash(Canvas canvas, Size size, double timer) {
    if (timer <= 0) return;
    double opacity = (timer / 0.3).clamp(0.0, 0.55);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          InfernoColors.damageFlash.withOpacity(opacity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // ──────────────────────────────────────────────────────────────────────
  // MEJORA 9: Muerte dramática con onda expansiva
  // Llámalo desde game_engine al matar un enemigo: pasa las coordenadas
  // y añade un ShockwaveEffect a la lista de efectos del engine.
  // ──────────────────────────────────────────────────────────────────────
  static void drawShockwaves(Canvas canvas, List<ShockwaveEffect> shockwaves) {
    for (var s in shockwaves) {
      if (!s.isActive) continue;

      double progress = s.progress;
      double radius = s.maxRadius * progress;
      double opacity = (1.0 - progress).clamp(0.0, 0.7);

      // Onda exterior
      canvas.drawCircle(
        Offset(s.x, s.y),
        radius,
        Paint()
          ..color = s.color.withOpacity(opacity * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - progress) * 6 + 1,
      );

      // Onda interior (más pequeña, ligeramente desfasada)
      double innerRadius = s.maxRadius * (progress * 0.75);
      canvas.drawCircle(
        Offset(s.x, s.y),
        innerRadius,
        Paint()
          ..color = Colors.white.withOpacity(opacity * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - progress) * 3,
      );

      // Flash central (solo al inicio)
      if (progress < 0.25) {
        double flashOpacity = (0.25 - progress) / 0.25;
        canvas.drawCircle(
          Offset(s.x, s.y),
          radius * 0.4,
          Paint()
            ..color = Colors.white.withOpacity(flashOpacity * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // EXIT TILE (sin cambios)
  // ──────────────────────────────────────────────────────────────────────
  static void drawExitTile(
      Canvas canvas, double x, double y, double time, bool allEnemiesDead) {
    double ts = GameConstants.tileSize;
    Rect tileRect = Rect.fromCenter(center: Offset(x, y), width: ts, height: ts);

    if (!allEnemiesDead) {
      double pulse = 0.5 + 0.5 * sin(time * 2.5);
      canvas.drawRect(tileRect,
          Paint()..color = InfernoColors.healthLow.withOpacity(0.08 + pulse * 0.08));
      canvas.drawRect(
        tileRect,
        Paint()
          ..color = InfernoColors.healthLow.withOpacity(0.3 + pulse * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final xPaint = Paint()
        ..color = InfernoColors.healthLow.withOpacity(0.5 + pulse * 0.2)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - 8, y - 8), Offset(x + 8, y + 8), xPaint);
      canvas.drawLine(Offset(x + 8, y - 8), Offset(x - 8, y + 8), xPaint);
    } else {
      double pulse = 0.5 + 0.5 * sin(time * 5);
      final outerGlow = Paint()
        ..color = InfernoColors.exitBeacon.withOpacity(0.1 + pulse * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: ts + 20, height: ts + 20),
        outerGlow,
      );
      canvas.drawRect(
          tileRect, Paint()..color = InfernoColors.exitBeacon.withOpacity(0.12 + pulse * 0.08));
      canvas.drawRect(
        tileRect,
        Paint()
          ..color = InfernoColors.exitBeacon.withOpacity(0.6 + pulse * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(x, y),
        12 + pulse * 3,
        Paint()
          ..color = InfernoColors.exitBeacon.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final arrowPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y - 10), Offset(x, y + 7), arrowPaint);
      canvas.drawLine(Offset(x - 6, y + 1), Offset(x, y + 7), arrowPaint);
      canvas.drawLine(Offset(x + 6, y + 1), Offset(x, y + 7), arrowPaint);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
// MEJORA 9: Clase ShockwaveEffect — onda expansiva al matar enemigos
// Añade una lista `List<ShockwaveEffect> shockwaves = []` en GameEngine
// y llama `shockwaves.add(ShockwaveEffect(...))` en _spawnDeathParticles.
// En GameRenderer, llama EffectsRenderer.drawShockwaves() dentro del canvas
// de mundo, después de drawParticles.
// ──────────────────────────────────────────────────────────────────────────
class ShockwaveEffect {
  double x, y;
  double lifetime;
  double maxLifetime;
  double maxRadius;
  Color color;
  bool isActive;

  ShockwaveEffect({
    required this.x,
    required this.y,
    this.lifetime = 0.5,
    this.maxRadius = 60.0,
    this.color = InfernoColors.explosionHot,
  })  : maxLifetime = lifetime,
        isActive = true;

  double get progress => 1.0 - (lifetime / maxLifetime);

  void update(double dt) {
    if (!isActive) return;
    lifetime -= dt;
    if (lifetime <= 0) isActive = false;
  }
}
