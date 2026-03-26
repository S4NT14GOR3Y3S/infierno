import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/assets.dart';
import '../utils/image_cache_manager.dart';
import '../game/game_engine.dart';
import '../game/game_map.dart';
import '../game/player.dart';
import '../game/enemy.dart';
import '../game/enemy_types.dart';
import 'sprite_painter.dart';
import 'effects.dart';

class GameRenderer extends CustomPainter {
  final GameEngine engine;
  final double time;
  final _cache = ImageCacheManager();

  GameRenderer({required this.engine, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final player = engine.player;
    final map = engine.currentMap;

    double camX = (player.x - size.width / 2)
        .clamp(0, (map.pixelWidth - size.width).clamp(0, double.infinity));
    double camY = (player.y - size.height / 2)
        .clamp(0, (map.pixelHeight - size.height).clamp(0, double.infinity));

    // Base background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = InfernoColors.void_,
    );

    canvas.save();

    // ── MEJORA 1: Screen Shake al recibir daño ──────────────────────────
    // Traslada el canvas aleatoriamente cuando el jugador recibe daño.
    // Solo requiere el damageFlashTimer que ya existe en Player.
    if (player.damageFlashTimer > 0) {
      final rand = Random();
      double intensity = (player.damageFlashTimer / 0.3).clamp(0.0, 1.0);
      double shakeAmount = intensity * 7.0;
      canvas.translate(
        (rand.nextDouble() - 0.5) * shakeAmount,
        (rand.nextDouble() - 0.5) * shakeAmount,
      );
    }

    canvas.translate(-camX, -camY);

    int startCol = ((camX / GameConstants.tileSize).floor() - 1).clamp(0, map.width - 1);
    int endCol = (((camX + size.width) / GameConstants.tileSize).floor() + 1).clamp(0, map.width - 1);
    int startRow = ((camY / GameConstants.tileSize).floor() - 1).clamp(0, map.height - 1);
    int endRow = (((camY + size.height) / GameConstants.tileSize).floor() + 1).clamp(0, map.height - 1);

    _drawFloor(canvas, map, startCol, endCol, startRow, endRow);

    // ── MEJORA 2: Cuadrícula de suelo ───────────────────────────────────
    // Añade líneas finas sobre el suelo para dar profundidad tipo dungeon.
    _drawFloorGrid(canvas, startCol, endCol, startRow, endRow);

    _drawWalls(canvas, map, startCol, endCol, startRow, endRow);

    // ── MEJORA 3: Sombras proyectadas por las paredes ───────────────────
    // Dibuja una sombra suave en el suelo debajo de cada pared.
    _drawWallShadows(canvas, map, startCol, endCol, startRow, endRow);

    bool allDead = engine.enemiesRemaining == 0;
    _drawExitTile(canvas, map.exitX, map.exitY, allDead);

    for (var pickup in map.pickups) {
      if (pickup.isActive) {
        SpritePainter.drawPickup(canvas, pickup.x, pickup.y, pickup.type, pickup.bobTimer);
      }
    }

    for (var enemy in map.enemies) {
      if (!enemy.isActive) continue;
      // ── MEJORA 4: Shadow blob bajo cada enemigo ─────────────────────
      _drawEntityShadow(canvas, enemy.x, enemy.y, enemy.radius);

      if (enemy is Imp) {
        SpritePainter.drawImp(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state);
      } else if (enemy is Demon) {
        SpritePainter.drawDemon(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state);
      } else if (enemy is Cacodemon) {
        SpritePainter.drawCacodemon(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state, time);
      }
    }

    for (var proj in engine.projectiles) {
      if (proj.isActive) {
        SpritePainter.drawProjectile(
            canvas, proj.x, proj.y, proj.isPlayerBullet, proj.weaponType);
      }
    }

    EffectsRenderer.drawParticles(canvas, engine.particles);

    // ── MEJORA 9: Ondas expansivas de muerte ─────────────────────────────
    EffectsRenderer.drawShockwaves(canvas, engine.shockwaves);

    // Shadow del jugador
    _drawEntityShadow(canvas, player.x, player.y, GameConstants.playerRadius);
    SpritePainter.drawPlayer(
        canvas, player.x, player.y, player.angle, player.isInvulnerable, time);

    canvas.restore();

    // ── Efectos en screen-space (no afectados por cámara ni shake) ──────
    EffectsRenderer.drawDamageFlash(canvas, size, player.damageFlashTimer);

    // ── MEJORA 5: Muzzle flash en screen-space ──────────────────────────
    if (player.isShooting) {
      _drawMuzzleFlash(canvas, size, player, camX, camY);
    }

    _drawVignette(canvas, size);
    _drawMinimap(canvas, size, map, player);
    _drawAimIndicator(canvas, size, player, camX, camY);
  }

  // ──────────────────────────────────────────────────────────────────────
  // FLOOR con tiles alternados
  // ──────────────────────────────────────────────────────────────────────
  void _drawFloor(Canvas canvas, GameMap map, int sc, int ec, int sr, int er) {
    final ts = GameConstants.tileSize;
    final imgDark = _cache.get(GameAssets.tileFloorDark);
    final imgMid  = _cache.get(GameAssets.tileFloorMid);

    for (int row = sr; row <= er; row++) {
      for (int col = sc; col <= ec; col++) {
        double x = col * ts, y = row * ts;
        if (imgDark != null && imgMid != null) {
          final img = (row + col) % 2 == 0 ? imgDark : imgMid;
          canvas.drawImage(img, Offset(x, y), Paint());
        } else {
          canvas.drawRect(
            Rect.fromLTWH(x, y, ts, ts),
            Paint()
              ..color = (row + col) % 2 == 0
                  ? InfernoColors.floorDark
                  : InfernoColors.floorMid,
          );
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MEJORA 2: Cuadrícula de suelo
  // Dibuja líneas muy tenues sobre los tiles del suelo.
  // ──────────────────────────────────────────────────────────────────────
  void _drawFloorGrid(Canvas canvas, int sc, int ec, int sr, int er) {
    final ts = GameConstants.tileSize;
    final gridPaint = Paint()
      ..color = const Color(0xFF1A2230).withOpacity(0.35)
      ..strokeWidth = 0.5;

    // Líneas horizontales
    for (int row = sr; row <= er + 1; row++) {
      canvas.drawLine(
        Offset(sc * ts, row * ts),
        Offset((ec + 1) * ts, row * ts),
        gridPaint,
      );
    }
    // Líneas verticales
    for (int col = sc; col <= ec + 1; col++) {
      canvas.drawLine(
        Offset(col * ts, sr * ts),
        Offset(col * ts, (er + 1) * ts),
        gridPaint,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // WALLS con tiles
  // ──────────────────────────────────────────────────────────────────────
  void _drawWalls(Canvas canvas, GameMap map, int sc, int ec, int sr, int er) {
    final ts = GameConstants.tileSize;
    final imgWall       = _cache.get(GameAssets.tileWall);
    final imgDoor       = _cache.get(GameAssets.tileDoor);
    final imgDoorLocked = _cache.get(GameAssets.tileDoorLocked);

    for (int row = sr; row <= er; row++) {
      for (int col = sc; col <= ec; col++) {
        TileType tile = map.getTile(col, row);
        double x = col * ts, y = row * ts;

        if (tile == TileType.wall && imgWall != null) {
          canvas.drawImage(imgWall, Offset(x, y), Paint());
        } else if (tile == TileType.door) {
          if (imgDoor != null) {
            canvas.drawImage(imgDoor, Offset(x, y), Paint());
          } else {
            _drawFallbackDoor(canvas, x, y, ts, false);
          }
        } else if (tile == TileType.lockedDoor) {
          if (imgDoorLocked != null) {
            canvas.drawImage(imgDoorLocked, Offset(x, y), Paint());
          } else {
            _drawFallbackDoor(canvas, x, y, ts, true);
          }
        } else if (tile == TileType.wall) {
          _drawFallbackWall(canvas, x, y, ts);
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MEJORA 3: Sombras de paredes proyectadas al suelo
  // Se dibuja después de las paredes para que quede encima del suelo
  // pero detrás de las entidades.
  // ──────────────────────────────────────────────────────────────────────
  void _drawWallShadows(
      Canvas canvas, GameMap map, int sc, int ec, int sr, int er) {
    final ts = GameConstants.tileSize;
    const shadowDepth = 10.0; // Qué tan larga es la sombra hacia abajo

    for (int row = sr; row <= er; row++) {
      for (int col = sc; col <= ec; col++) {
        if (!map.isWall(col, row)) continue;

        // Solo proyectar sombra si el tile de abajo es suelo
        if (map.isWall(col, row + 1)) continue;

        double x = col * ts;
        double y = (row + 1) * ts; // Base inferior de la pared

        final shadowPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(x, y, ts, shadowDepth));

        canvas.drawRect(Rect.fromLTWH(x, y, ts, shadowDepth), shadowPaint);
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MEJORA 4: Shadow blob (elipse difusa) bajo entidades
  // ──────────────────────────────────────────────────────────────────────
  void _drawEntityShadow(Canvas canvas, double x, double y, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y + radius * 0.6),
        width: radius * 1.8,
        height: radius * 0.6,
      ),
      shadowPaint,
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // MEJORA 5: Muzzle flash en screen-space
  // ──────────────────────────────────────────────────────────────────────
  void _drawMuzzleFlash(
      Canvas canvas, Size size, Player player, double camX, double camY) {
    double sx = player.x - camX;
    double sy = player.y - camY;
    const aimDist = 28.0;
    double ax = sx + cos(player.angle) * aimDist;
    double ay = sy + sin(player.angle) * aimDist;

    // Glow exterior
    canvas.drawCircle(
      Offset(ax, ay),
      22,
      Paint()
        ..color = InfernoColors.muzzleFlash.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    // Core brillante
    canvas.drawCircle(
      Offset(ax, ay),
      8,
      Paint()..color = InfernoColors.muzzleFlash.withOpacity(0.85),
    );
    // Punto central blanco
    canvas.drawCircle(
      Offset(ax, ay),
      3,
      Paint()..color = Colors.white.withOpacity(0.95),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // EXIT TILE (sin cambios respecto al original)
  // ──────────────────────────────────────────────────────────────────────
  void _drawExitTile(Canvas canvas, double x, double y, bool allDead) {
    final imgExit = _cache.get(GameAssets.tileExit);
    final ts = GameConstants.tileSize;
    double pulse = 0.5 + 0.5 * sin(time * 5);

    if (imgExit != null) {
      canvas.drawImage(imgExit, Offset(x - ts / 2, y - ts / 2), Paint());
    }

    if (!allDead) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: ts, height: ts),
        Paint()..color = InfernoColors.healthLow.withOpacity(0.35 + pulse * 0.1),
      );
      final p = Paint()
        ..color = InfernoColors.healthLow.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - 8, y - 8), Offset(x + 8, y + 8), p);
      canvas.drawLine(Offset(x + 8, y - 8), Offset(x - 8, y + 8), p);
    } else {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: ts + 10, height: ts + 10),
        Paint()
          ..color = InfernoColors.exitBeacon.withOpacity(0.08 + pulse * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // VIGNETTE
  // ──────────────────────────────────────────────────────────────────────
  void _drawVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.82,
          colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // AIM INDICATOR (crosshair)
  // ──────────────────────────────────────────────────────────────────────
  void _drawAimIndicator(
      Canvas canvas, Size size, Player player, double camX, double camY) {
    final img = _cache.get(GameAssets.crosshair);
    double sx = player.x - camX;
    double sy = player.y - camY;
    const aimDist = 44.0;
    double ax = sx + cos(player.angle) * aimDist;
    double ay = sy + sin(player.angle) * aimDist;

    if (img != null) {
      canvas.drawImage(img, Offset(ax - img.width / 2, ay - img.height / 2), Paint());
    } else {
      canvas.drawCircle(
        Offset(ax, ay),
        4,
        Paint()..color = InfernoColors.playerCore.withOpacity(0.7),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MINIMAPA con dirección del jugador y pulso en enemigos
  // ──────────────────────────────────────────────────────────────────────
  void _drawMinimap(Canvas canvas, Size size, GameMap map, Player player) {
    const sc = 3.2;
    double mmW = map.width * sc, mmH = map.height * sc;
    double mmX = size.width - mmW - 12, mmY = 12;

    // Panel de fondo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mmX - 4, mmY - 4, mmW + 8, mmH + 8),
        const Radius.circular(4)),
      Paint()..color = const Color(0xE6050811),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mmX - 4, mmY - 4, mmW + 8, mmH + 8),
        const Radius.circular(4)),
      Paint()
        ..color = InfernoColors.playerCore.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final wallP  = Paint()..color = InfernoColors.wallMid.withOpacity(0.85);
    final doorP  = Paint()..color = InfernoColors.doorActive.withOpacity(0.7);
    final floorP = Paint()..color = InfernoColors.floorDark.withOpacity(0.6);

    for (int row = 0; row < map.height; row++) {
      for (int col = 0; col < map.width; col++) {
        TileType t = map.getTile(col, row);
        Rect r = Rect.fromLTWH(
            mmX + col * sc, mmY + row * sc, sc - 0.2, sc - 0.2);
        if (t == TileType.wall) {
          canvas.drawRect(r, wallP);
        } else if (t == TileType.door || t == TileType.lockedDoor) {
          canvas.drawRect(r, doorP);
        } else {
          canvas.drawRect(r, floorP);
        }
      }
    }

    // Exit beacon
    canvas.drawCircle(
      Offset(
        mmX + (map.exitX / GameConstants.tileSize) * sc,
        mmY + (map.exitY / GameConstants.tileSize) * sc,
      ),
      2.5,
      Paint()..color = InfernoColors.exitBeacon,
    );

    // ── MEJORA 6: Enemigos con pulso animado en el minimapa ─────────────
    for (var e in map.enemies) {
      if (!e.isActive) continue;
      double ex = mmX + (e.x / GameConstants.tileSize) * sc;
      double ey = mmY + (e.y / GameConstants.tileSize) * sc;

      // Anillo pulsante
      double pulse = 0.5 + 0.5 * sin(time * 5.0 + ex);
      canvas.drawCircle(
        Offset(ex, ey),
        3.5 * pulse,
        Paint()..color = InfernoColors.healthLow.withOpacity(0.35 * pulse),
      );
      // Punto sólido
      canvas.drawCircle(
        Offset(ex, ey),
        1.8,
        Paint()..color = InfernoColors.healthLow,
      );
    }

    // Jugador
    double px = mmX + (player.x / GameConstants.tileSize) * sc;
    double py = mmY + (player.y / GameConstants.tileSize) * sc;

    // Glow del jugador
    canvas.drawCircle(
      Offset(px, py),
      3.5,
      Paint()
        ..color = InfernoColors.playerCore.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(px, py),
      2.5,
      Paint()..color = InfernoColors.playerCore,
    );

    // ── MEJORA 7: Línea de dirección del jugador en minimapa ────────────
    const dirLen = 6.0;
    canvas.drawLine(
      Offset(px, py),
      Offset(px + cos(player.angle) * dirLen, py + sin(player.angle) * dirLen),
      Paint()
        ..color = InfernoColors.playerCore
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Fallbacks
  // ──────────────────────────────────────────────────────────────────────
  void _drawFallbackWall(Canvas canvas, double x, double y, double s) {
    canvas.drawRect(
        Rect.fromLTWH(x, y, s, s), Paint()..color = InfernoColors.wallMid);
  }

  void _drawFallbackDoor(
      Canvas canvas, double x, double y, double s, bool locked) {
    canvas.drawRect(
      Rect.fromLTWH(x, y, s, s),
      Paint()
        ..color =
            locked ? const Color(0xFF1A0808) : const Color(0xFF08141A),
    );
    canvas.drawRect(
      Rect.fromLTWH(x, y, s, s),
      Paint()
        ..color = locked ? InfernoColors.doorLocked : InfernoColors.doorActive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}
