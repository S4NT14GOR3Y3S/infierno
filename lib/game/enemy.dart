import 'dart:math';
import '../utils/constants.dart';

/// Base class for all enemies
class Enemy {
  double x;
  double y;
  double angle;
  int health;
  int maxHealth;
  double speed;
  int contactDamage;
  int projectileDamage;
  double attackCooldown;
  double _attackTimer;
  double radius;
  EnemyState state;
  double stateTimer;
  double deathTimer;
  bool canShoot;
  int scoreValue;
  String typeName;

  Enemy({
    required this.x,
    required this.y,
    required this.health,
    required this.speed,
    required this.contactDamage,
    this.projectileDamage = 0,
    this.attackCooldown = 1.0,
    this.radius = 12.0,
    this.canShoot = false,
    this.scoreValue = 100,
    this.typeName = 'Enemy',
    this.angle = 0,
  })  : maxHealth = health,
        _attackTimer = 0,
        state = EnemyState.idle,
        stateTimer = 0,
        deathTimer = 0;

  bool get isDead => state == EnemyState.dead;
  bool get isDying => state == EnemyState.dying;
  bool get isActive => state != EnemyState.dead;
  bool get canAttack => _attackTimer <= 0;
  double get healthPercent => health / maxHealth;

  void update(double dt, double playerX, double playerY) {
    if (isDead) return;

    _attackTimer -= dt;
    if (_attackTimer < 0) _attackTimer = 0;

    if (isDying) {
      deathTimer -= dt;
      if (deathTimer <= 0) {
        state = EnemyState.dead;
      }
      return;
    }

    if (state == EnemyState.hurt) {
      stateTimer -= dt;
      if (stateTimer <= 0) {
        state = EnemyState.chasing;
      }
      return;
    }

    // Calculate distance to player
    double dx = playerX - x;
    double dy = playerY - y;
    double distance = sqrt(dx * dx + dy * dy);

    // Update angle to face player
    angle = atan2(dy, dx);

    if (distance <= GameConstants.enemyAttackRange + radius) {
      state = EnemyState.attacking;
    } else if (distance <= GameConstants.enemyDetectionRange) {
      state = EnemyState.chasing;
      // Move towards player
      if (distance > 0) {
        double moveX = (dx / distance) * speed * dt;
        double moveY = (dy / distance) * speed * dt;
        x += moveX;
        y += moveY;
      }
    } else {
      state = EnemyState.idle;
      // Random idle movement
      stateTimer -= dt;
      if (stateTimer <= 0) {
        stateTimer = 2.0 + Random().nextDouble() * 3.0;
        angle = Random().nextDouble() * 2 * pi;
      }
      x += cos(angle) * speed * 0.3 * dt;
      y += sin(angle) * speed * 0.3 * dt;
    }
  }

  void takeDamage(int amount) {
    if (isDead || isDying) return;
    health -= amount;
    if (health <= 0) {
      health = 0;
      state = EnemyState.dying;
      deathTimer = 0.5;
    } else {
      state = EnemyState.hurt;
      stateTimer = 0.2;
    }
  }

  void resetAttackTimer() {
    _attackTimer = attackCooldown;
  }

  bool shouldShoot(double playerX, double playerY) {
    if (!canShoot || !canAttack || isDead || isDying) return false;
    double dx = playerX - x;
    double dy = playerY - y;
    double distance = sqrt(dx * dx + dy * dy);
    return distance <= GameConstants.enemyDetectionRange * 0.8;
  }
}
