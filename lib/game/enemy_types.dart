import 'enemy.dart';

/// Fast, low-health ranged enemy
class Imp extends Enemy {
  Imp({required double x, required double y})
      : super(
          x: x,
          y: y,
          health: 40,
          speed: 90.0,
          contactDamage: 8,
          projectileDamage: 10,
          attackCooldown: 1.5,
          radius: 11.0,
          canShoot: true,
          scoreValue: 100,
          typeName: 'Imp',
        );
}

/// Slow, high-health melee enemy
class Demon extends Enemy {
  Demon({required double x, required double y})
      : super(
          x: x,
          y: y,
          health: 120,
          speed: 55.0,
          contactDamage: 25,
          projectileDamage: 0,
          attackCooldown: 0.8,
          radius: 16.0,
          canShoot: false,
          scoreValue: 200,
          typeName: 'Demon',
        );
}

/// Flying, medium enemy with ranged attack
class Cacodemon extends Enemy {
  Cacodemon({required double x, required double y})
      : super(
          x: x,
          y: y,
          health: 80,
          speed: 65.0,
          contactDamage: 12,
          projectileDamage: 15,
          attackCooldown: 2.0,
          radius: 18.0,
          canShoot: true,
          scoreValue: 300,
          typeName: 'Cacodemon',
        );
}
