import 'dart:ui';

/// Global constants for INFERNO 2D
class GameConstants {
  static const double tileSize = 48.0;
  static const int mapWidth = 30;
  static const int mapHeight = 20;
  static const double playerSpeed = 170.0;
  static const double playerRadius = 11.0;
  static const int playerMaxHealth = 100;
  static const double playerInvulnerabilityTime = 0.8;
  static const double enemyDetectionRange = 280.0;
  static const double enemyAttackRange = 42.0;
  static const double bulletSpeed = 380.0;
  static const double bulletRadius = 4.5;
  static const double gameTickRate = 1.0 / 60.0;
  static const int totalLevels = 3;
}

/// INFERNO 2D — neon-noir palette
class InfernoColors {
  static const Color void_ = Color(0xFF060810);
  static const Color floorDark = Color(0xFF0C0F1A);
  static const Color floorMid = Color(0xFF101522);
  static const Color wallBase = Color(0xFF1A0A12);
  static const Color wallMid = Color(0xFF2A1018);
  static const Color wallTop = Color(0xFF3A1822);
  static const Color wallAccent = Color(0xFFAA1830);
  static const Color playerCore = Color(0xFF00E5FF);
  static const Color playerShell = Color(0xFF0090B8);
  static const Color playerGun = Color(0xFF90CAF9);
  static const Color playerGlow = Color(0xFF00B8D9);
  static const Color wraithCore = Color(0xFFFF3D00);
  static const Color wraithGlow = Color(0xFFBF360C);
  static const Color wraithEyes = Color(0xFFFFE000);
  static const Color crusherCore = Color(0xFF8B0000);
  static const Color crusherShell = Color(0xFF5D0000);
  static const Color crusherSpike = Color(0xFFFF5722);
  static const Color specterCore = Color(0xFF4A0080);
  static const Color specterGlow = Color(0xFF9C27B0);
  static const Color specterEye = Color(0xFF76FF03);
  static const Color bulletPlayer = Color(0xFFFFD740);
  static const Color bulletEnemy = Color(0xFFFF5722);
  static const Color plasma = Color(0xFF00E5FF);
  static const Color hudBg = Color(0xE6050811);
  static const Color hudBorder = Color(0xFF1E2D3D);
  static const Color hudAccent = Color(0xFF00E5FF);
  static const Color hudDanger = Color(0xFFFF1744);
  static const Color healthFull = Color(0xFF00E676);
  static const Color healthMid = Color(0xFFFFD740);
  static const Color healthLow = Color(0xFFFF1744);
  static const Color ammoColor = Color(0xFF00B0FF);
  static const Color scoreColor = Color(0xFFFFD740);
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFF78909C);
  static const Color muzzleFlash = Color(0xFFFFFFCC);
  static const Color explosionHot = Color(0xFFFF6D00);
  static const Color explosionCool = Color(0xFFFF1744);
  static const Color damageFlash = Color(0x80FF1744);
  static const Color doorFrame = Color(0xFF37474F);
  static const Color doorPanel = Color(0xFF1A2830);
  static const Color doorActive = Color(0xFF00E5FF);
  static const Color doorLocked = Color(0xFFFF1744);
  static const Color exitBeacon = Color(0xFF00E676);
  static const Color pickupHealth = Color(0xFF00E676);
  static const Color pickupAmmo = Color(0xFF00B0FF);
  static const Color pickupWeapon = Color(0xFFFFD740);
  static const Color menuBg1 = Color(0xFF050811);
  static const Color menuBg2 = Color(0xFF0A0518);
  static const Color menuTitle = Color(0xFFFF1744);
  static const Color menuButton = Color(0xFF0D1B2A);
  static const Color menuButtonBorder = Color(0xFF00E5FF);
  static const Color menuButtonText = Color(0xFF00E5FF);

  // Legacy aliases for compatibility
  static const Color floor = floorDark;
  static const Color floorAlt = floorMid;
  static const Color wallBrown = wallMid;
  static const Color wallDark = wallBase;
  static const Color wallLight = wallTop;
  static const Color playerBody = playerCore;
  static const Color playerGunColor = playerGun;
  static const Color impBody = wraithCore;
  static const Color impEyes = wraithEyes;
  static const Color demonBody = crusherCore;
  static const Color demonHorns = crusherSpike;
  static const Color cacodemonBody = specterCore;
  static const Color cacodemonEye = specterEye;
  static const Color healthGreen = healthFull;
  static const Color healthYellow = healthMid;
  static const Color healthRed = healthLow;
  static const Color explosion = explosionHot;
  static const Color hudBackground = hudBg;
  static const Color weaponPickup = pickupWeapon;
  static const Color ammoPickup = pickupAmmo;
  static const Color healthPickup = pickupHealth;
  static const Color doorColor = doorPanel;
  static const Color exitColor = exitBeacon;
  static const Color menuBg = menuBg1;
  static const Color menuButtonHover = Color(0xFF1A3550);
  static const Color keyPickup = Color(0xFFFFD740);
  static const Color hudBorderColor = hudBorder;
  static const Color menuTitleColor = menuTitle;
  static const Color menuButtonColor = menuButton;
  static const Color textWhite = textPrimary;
  static const Color textGray = textSecondary;
}

/// Tile types for the game map
enum TileType {
  empty, wall, door, lockedDoor, exitTile, playerSpawn,
  enemySpawnImp, enemySpawnDemon, enemySpawnCacodemon,
  healthPickup, ammoPickup, weaponPickup,
}

enum GameState { menu, playing, paused, levelComplete, gameOver, victory }
enum EnemyState { idle, chasing, attacking, hurt, dying, dead }
enum WeaponType { pistol, shotgun, plasmaRifle }
enum PickupType { health, ammo, shotgunPickup, plasmaRiflePickup }
