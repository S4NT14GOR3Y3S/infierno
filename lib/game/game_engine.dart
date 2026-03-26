import 'dart:math';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';
import '../rendering/effects.dart';
import 'player.dart';
import 'enemy.dart';
import 'projectile.dart';
import 'pickup.dart';
import 'weapon.dart';
import 'game_map.dart';
import 'levels.dart';
import 'collision.dart';

/// Main game engine that manages the game loop and state
class GameEngine {
  GameState state = GameState.menu;
  late Player player;
  late GameMap currentMap;
  late CollisionSystem collision;
  late WeaponManager weaponManager;
  List<Projectile> projectiles = [];
  int currentLevel = 0;
  int killCount = 0;
  int totalKills = 0;

  // Effects
  List<ParticleEffect> particles = [];
  // ── MEJORA: Ondas expansivas al matar enemigos ──────────────────────
  List<ShockwaveEffect> shockwaves = [];

  final AudioManager audio = AudioManager();

  GameEngine() {
    player = Player(x: 0, y: 0);
    weaponManager = WeaponManager();
    _loadLevel(0);
  }

  void _loadLevel(int level) {
    currentLevel = level;
    currentMap = Levels.getLevel(level);
    collision = CollisionSystem(currentMap);
    projectiles.clear();
    particles.clear();
    killCount = 0;

    player.reset(currentMap.playerSpawnX, currentMap.playerSpawnY);
    weaponManager = WeaponManager();
  }

  void startNewGame() {
    currentLevel = 0;
    totalKills = 0;
    player.fullReset(0, 0);
    _loadLevel(0);
    state = GameState.playing;
    audio.playGameMusic();
  }

  void nextLevel() {
    if (currentLevel + 1 >= GameConstants.totalLevels) {
      state = GameState.victory;
      audio.playLevelComplete();
      return;
    }

    totalKills += killCount;
    int savedScore = player.score;
    int savedHealth = player.health;

    _loadLevel(currentLevel + 1);

    player.score = savedScore;
    player.health = savedHealth;
    state = GameState.playing;
  }

  void update(double dt) {
    if (state != GameState.playing) return;

    // Update player
    player.update(dt);
    collision.resolvePlayerWallCollision(player);

    // Update weapon manager
    weaponManager.switchTo(player.currentWeapon);
    weaponManager.update(dt);

    // Handle shooting
    if (player.isShooting && player.hasAmmo()) {
      List<Projectile> newBullets = weaponManager.tryFire(player.x, player.y, player.angle);
      if (newBullets.isNotEmpty) {
        projectiles.addAll(newBullets);
        player.consumeAmmo(weaponManager.current.ammoPerShot);
      }
    }

    // Update enemies
    for (var enemy in currentMap.enemies) {
      if (!enemy.isActive) continue;
      enemy.update(dt, player.x, player.y);
      collision.resolveEnemyWallCollision(enemy);

      // Enemy shooting
      if (enemy.shouldShoot(player.x, player.y)) {
        enemy.resetAttackTimer();
        projectiles.add(Projectile.enemyBullet(enemy.x, enemy.y, player.x, player.y));
      }
    }

    // Update projectiles
    for (var proj in projectiles) {
      proj.update(dt);

      if (!proj.isActive) continue;

      // Wall collision
      if (collision.projectileHitsWall(proj)) {
        proj.isActive = false;
        _spawnImpactParticles(proj.x, proj.y);
        continue;
      }

      if (proj.isPlayerBullet) {
        // Player bullet vs enemy
        Enemy? hitEnemy = collision.projectileHitsEnemy(proj, currentMap.enemies);
        if (hitEnemy != null) {
          proj.isActive = false;
          hitEnemy.takeDamage(proj.damage);
          audio.playEnemyHit();
          _spawnImpactParticles(proj.x, proj.y);

          if (hitEnemy.isDying) {
            player.score += hitEnemy.scoreValue;
            killCount++;
            audio.playEnemyDeath();
            _spawnDeathParticles(hitEnemy.x, hitEnemy.y);
          }
        }
      } else {
        // Enemy bullet vs player
        if (collision.projectileHitsPlayer(proj, player)) {
          proj.isActive = false;
          player.takeDamage(proj.damage);
          audio.playPlayerHurt();
        }
      }
    }

    // Contact damage
    Enemy? touchedEnemy = collision.playerTouchesEnemy(player, currentMap.enemies);
    if (touchedEnemy != null && touchedEnemy.canAttack) {
      player.takeDamage(touchedEnemy.contactDamage);
      touchedEnemy.resetAttackTimer();
      audio.playPlayerHurt();
    }

    // Pickups
    Pickup? touchedPickup = collision.playerTouchesPickup(player, currentMap.pickups);
    if (touchedPickup != null) {
      _handlePickup(touchedPickup);
    }

    // Door auto-open: check adjacent doors
    _checkDoors();

    // Check exit
    if (collision.playerOnExit(player)) {
      bool allEnemiesDead = currentMap.enemies.every((e) => e.isDead);
      if (allEnemiesDead) {
        audio.playLevelComplete();
        state = GameState.levelComplete;
      }
    }

    // Check player death
    if (player.isDead) {
      state = GameState.gameOver;
      audio.playGameOver();
    }

    // Update particles
    for (var p in particles) {
      p.update(dt);
    }

    // ── MEJORA: Update shockwaves ────────────────────────────────────────
    for (var s in shockwaves) {
      s.update(dt);
    }

    // Cleanup
    projectiles.removeWhere((p) => !p.isActive);
    currentMap.enemies.removeWhere((e) => e.isDead);
    currentMap.pickups.removeWhere((p) => !p.isActive);
    particles.removeWhere((p) => !p.isActive);
    shockwaves.removeWhere((s) => !s.isActive);
  }

  void _handlePickup(Pickup pickup) {
    switch (pickup.type) {
      case PickupType.health:
        if (player.health < player.maxHealth) {
          player.heal(25);
          pickup.collect();
          audio.playPickup();
        }
        break;
      case PickupType.ammo:
        player.addAmmoForWeapon(player.currentWeapon, 15);
        pickup.collect();
        audio.playPickup();
        break;
      case PickupType.shotgunPickup:
        player.pickupWeapon(WeaponType.shotgun);
        pickup.collect();
        audio.playPickup();
        break;
      case PickupType.plasmaRiflePickup:
        player.pickupWeapon(WeaponType.plasmaRifle);
        pickup.collect();
        audio.playPickup();
        break;
    }
  }

  void _checkDoors() {
    double r = player.radius + 5;
    int minCol = ((player.x - r) / GameConstants.tileSize).floor() - 1;
    int maxCol = ((player.x + r) / GameConstants.tileSize).floor() + 1;
    int minRow = ((player.y - r) / GameConstants.tileSize).floor() - 1;
    int maxRow = ((player.y + r) / GameConstants.tileSize).floor() + 1;

    for (int row = minRow; row <= maxRow; row++) {
      for (int col = minCol; col <= maxCol; col++) {
        if (currentMap.isDoor(col, row)) {
          if (collision.playerNearDoor(player, col, row)) {
            TileType doorType = currentMap.getTile(col, row);
            if (doorType == TileType.door) {
              currentMap.openDoor(col, row);
              audio.playDoorOpen();
            } else if (doorType == TileType.lockedDoor && player.keys > 0) {
              player.useKey();
              currentMap.openDoor(col, row);
              audio.playDoorOpen();
            }
          }
        }
      }
    }
  }

  void _spawnImpactParticles(double x, double y) {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      particles.add(ParticleEffect(
        x: x,
        y: y,
        dx: (random.nextDouble() - 0.5) * 100,
        dy: (random.nextDouble() - 0.5) * 100,
        lifetime: 0.3 + random.nextDouble() * 0.2,
        size: 2 + random.nextDouble() * 3,
        type: ParticleType.impact,
      ));
    }
  }

  void _spawnDeathParticles(double x, double y) {
    final random = Random();
    for (int i = 0; i < 12; i++) {
      particles.add(ParticleEffect(
        x: x,
        y: y,
        dx: (random.nextDouble() - 0.5) * 150,
        dy: (random.nextDouble() - 0.5) * 150,
        lifetime: 0.5 + random.nextDouble() * 0.5,
        size: 3 + random.nextDouble() * 5,
        type: ParticleType.death,
      ));
    }
    // ── MEJORA: Onda expansiva al matar un enemigo ──────────────────────
    shockwaves.add(ShockwaveEffect(
      x: x,
      y: y,
      maxRadius: 55.0,
      lifetime: 0.45,
      color: InfernoColors.explosionHot,
    ));
  }

  int get enemiesRemaining => currentMap.enemies.where((e) => e.isActive).length;
}

enum ParticleType { impact, death, muzzle }

class ParticleEffect {
  double x, y, dx, dy;
  double lifetime;
  double maxLifetime;
  double size;
  bool isActive;
  ParticleType type;

  ParticleEffect({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.lifetime,
    this.size = 3,
    this.type = ParticleType.impact,
  })  : maxLifetime = lifetime,
        isActive = true;

  double get progress => 1.0 - (lifetime / maxLifetime);

  void update(double dt) {
    if (!isActive) return;
    x += dx * dt;
    y += dy * dt;
    dx *= 0.95;
    dy *= 0.95;
    lifetime -= dt;
    if (lifetime <= 0) isActive = false;
  }
}
