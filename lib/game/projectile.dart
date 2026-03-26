import 'dart:math';
import '../utils/constants.dart';

/// Represents a projectile (bullet/plasma) in the game
class Projectile {
  double x;
  double y;
  double dx; // direction X
  double dy; // direction Y
  double speed;
  double radius;
  int damage;
  bool isPlayerBullet;
  bool isActive;
  WeaponType weaponType;
  double lifetime;

  Projectile({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.speed,
    required this.damage,
    required this.isPlayerBullet,
    this.weaponType = WeaponType.pistol,
    this.radius = GameConstants.bulletRadius,
    this.isActive = true,
    this.lifetime = 3.0,
  });

  void update(double dt) {
    if (!isActive) return;

    x += dx * speed * dt;
    y += dy * speed * dt;

    lifetime -= dt;
    if (lifetime <= 0) {
      isActive = false;
    }
  }

  /// Create a player pistol bullet
  static Projectile playerPistol(double fromX, double fromY, double angle) {
    return Projectile(
      x: fromX,
      y: fromY,
      dx: cos(angle),
      dy: sin(angle),
      speed: GameConstants.bulletSpeed,
      damage: 20,
      isPlayerBullet: true,
      weaponType: WeaponType.pistol,
    );
  }

  /// Create player shotgun pellets (returns multiple projectiles)
  static List<Projectile> playerShotgun(double fromX, double fromY, double angle) {
    List<Projectile> pellets = [];
    final random = Random();
    for (int i = 0; i < 5; i++) {
      double spread = (random.nextDouble() - 0.5) * 0.5; // +/- 0.25 radians
      pellets.add(Projectile(
        x: fromX,
        y: fromY,
        dx: cos(angle + spread),
        dy: sin(angle + spread),
        speed: GameConstants.bulletSpeed * 1.1,
        damage: 12,
        isPlayerBullet: true,
        weaponType: WeaponType.shotgun,
        lifetime: 1.5,
      ));
    }
    return pellets;
  }

  /// Create player plasma bolt
  static Projectile playerPlasma(double fromX, double fromY, double angle) {
    return Projectile(
      x: fromX,
      y: fromY,
      dx: cos(angle),
      dy: sin(angle),
      speed: GameConstants.bulletSpeed * 1.3,
      damage: 15,
      isPlayerBullet: true,
      weaponType: WeaponType.plasmaRifle,
      radius: 6.0,
    );
  }

  /// Create an enemy projectile
  static Projectile enemyBullet(double fromX, double fromY, double toX, double toY) {
    double angle = atan2(toY - fromY, toX - fromX);
    return Projectile(
      x: fromX,
      y: fromY,
      dx: cos(angle),
      dy: sin(angle),
      speed: GameConstants.bulletSpeed * 0.6,
      damage: 10,
      isPlayerBullet: false,
      radius: 5.0,
    );
  }
}
