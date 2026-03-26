import '../utils/constants.dart';
import 'projectile.dart';
import '../utils/audio_manager.dart';

/// Weapon configuration and firing mechanics
class Weapon {
  final WeaponType type;
  final String name;
  final double fireRate; // Shots per second
  final int ammoPerShot;
  double _cooldown = 0;

  Weapon({
    required this.type,
    required this.name,
    required this.fireRate,
    this.ammoPerShot = 1,
  });

  bool get canFire => _cooldown <= 0;

  void update(double dt) {
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
  }

  List<Projectile> fire(double fromX, double fromY, double angle) {
    if (!canFire) return [];

    _cooldown = 1.0 / fireRate;
    final audio = AudioManager();

    switch (type) {
      case WeaponType.pistol:
        audio.playShoot();
        return [Projectile.playerPistol(fromX, fromY, angle)];
      case WeaponType.shotgun:
        audio.playShotgun();
        return Projectile.playerShotgun(fromX, fromY, angle);
      case WeaponType.plasmaRifle:
        audio.playPlasma();
        return [Projectile.playerPlasma(fromX, fromY, angle)];
    }
  }

  void resetCooldown() {
    _cooldown = 0;
  }

  /// Create the correct weapon instance for a given type
  static Weapon create(WeaponType type) {
    switch (type) {
      case WeaponType.pistol:
        return Weapon(
          type: WeaponType.pistol,
          name: 'PISTOL',
          fireRate: 4.0,
        );
      case WeaponType.shotgun:
        return Weapon(
          type: WeaponType.shotgun,
          name: 'SHOTGUN',
          fireRate: 1.2,
          ammoPerShot: 1,
        );
      case WeaponType.plasmaRifle:
        return Weapon(
          type: WeaponType.plasmaRifle,
          name: 'PLASMA',
          fireRate: 8.0,
          ammoPerShot: 1,
        );
    }
  }
}

/// Manages all weapons for the player
class WeaponManager {
  final Map<WeaponType, Weapon> _weapons = {};
  WeaponType _currentType = WeaponType.pistol;

  WeaponManager() {
    for (var type in WeaponType.values) {
      _weapons[type] = Weapon.create(type);
    }
  }

  Weapon get current => _weapons[_currentType]!;
  WeaponType get currentType => _currentType;

  void switchTo(WeaponType type) {
    _currentType = type;
  }

  void update(double dt) {
    for (var weapon in _weapons.values) {
      weapon.update(dt);
    }
  }

  List<Projectile> tryFire(double fromX, double fromY, double angle) {
    return current.fire(fromX, fromY, angle);
  }
}
