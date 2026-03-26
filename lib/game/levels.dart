import '../utils/constants.dart';
import 'game_map.dart';

// Aliases for readability
const _ = TileType.empty;
const W = TileType.wall;
const D = TileType.door;
const L = TileType.lockedDoor;
const X = TileType.exitTile;
const P = TileType.playerSpawn;
const I = TileType.enemySpawnImp;
const M = TileType.enemySpawnDemon;
const C = TileType.enemySpawnCacodemon;
const H = TileType.healthPickup;
const A = TileType.ammoPickup;
const G = TileType.weaponPickup;

class Levels {
  static GameMap getLevel(int levelIndex) {
    switch (levelIndex) {
      case 0:
        return _level1();
      case 1:
        return _level2();
      case 2:
        return _level3();
      default:
        return _level1();
    }
  }

  /// Level 1: "Entry" - Simple layout, few enemies, learn the controls
  static GameMap _level1() {
    final tiles = <List<TileType>>[
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
      [W, P, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, D, _, _, _, I, _, _, _, _, _, W, W, W, W, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W, _, _, _, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W, _, H, _, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, W, W, W, D, W, W, _, _, _, _, W, _, _, _, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, W, W, D, W, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, W, W, W, W, W, _, _, _, _, _, _, _, W, _, _, I, _, _, _, _, _, _, _, _, _, A, _, _, W],
      [W, _, _, _, _, W, _, _, _, I, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, W, _, _, _, _, _, _, _, W, W, W, W, W, W, _, _, _, _, _, _, _, _, _, _, W],
      [W, _, A, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, W, W, W, W, W],
      [W, _, _, _, _, W, W, W, W, W, W, W, W, W, _, _, _, _, W, _, _, _, _, _, _, W, _, _, _, W],
      [W, _, G, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, W, _, _, _, _, _, _, D, _, X, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, I, _, W, _, _, _, _, _, _, W, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, W, _, _, _, I, _, _, W, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, H, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, W],
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
    ];

    final map = GameMap(width: 30, height: 20, tiles: tiles);
    map.spawnEntities();
    return map;
  }

  /// Level 2: "Corridors" - More enemies, narrow corridors, keys needed
  static GameMap _level2() {
    final tiles = <List<TileType>>[
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
      [W, P, _, _, _, W, _, _, _, _, _, W, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, W, _, I, _, _, _, W, _, _, _, _, _, _, _, W, _, _, _, _, _, I, _, _, _, W],
      [W, _, _, _, _, W, _, _, _, _, _, W, _, _, W, W, W, _, _, W, _, _, W, W, W, W, W, _, _, W],
      [W, _, _, _, _, D, _, _, _, _, _, D, _, _, W, _, W, _, _, D, _, _, W, _, _, _, W, _, _, W],
      [W, _, _, _, _, W, _, _, _, _, _, W, _, _, W, H, W, _, _, W, _, _, W, _, M, _, W, _, _, W],
      [W, W, W, D, W, W, _, _, _, _, _, W, _, _, W, _, W, _, _, W, _, _, W, _, _, _, W, _, _, W],
      [W, _, _, _, _, _, _, _, W, W, W, W, _, _, _, _, _, _, _, W, _, _, W, W, D, W, W, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, _, _, I, _, _, _, W, _, _, _, _, _, _, _, _, _, W],
      [W, _, I, _, _, _, _, _, W, _, A, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, W, W, W, W, W, W, W, _, _, _, _, _, _, A, _, _, W],
      [W, _, _, _, _, _, _, _, W, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, W, W, W, W, W, _, _, W, W, W, D, W, W, _, _, _, _, _, _, _, _, W, W, W, W, W, W, W, W],
      [W, _, _, _, _, W, _, _, _, _, _, _, _, _, _, C, _, _, _, _, _, _, W, _, _, _, _, _, _, W],
      [W, _, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, W],
      [W, _, G, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, X, _, W],
      [W, _, _, _, _, W, W, W, W, _, _, _, _, _, W, W, W, W, W, _, _, _, W, _, _, I, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, I, _, _, _, _, _, _, W, _, _, _, W, _, _, _, _, _, _, W],
      [W, _, H, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, H, _, _, W],
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
    ];

    final map = GameMap(width: 30, height: 20, tiles: tiles);
    map.spawnEntities();
    return map;
  }

  /// Level 3: "Hellscape" - Many enemies, complex layout, boss-like area
  static GameMap _level3() {
    final tiles = <List<TileType>>[
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
      [W, P, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, I, _, _, _, W, _, _, _, _, _, _, _, _, W, _, _, _, _, _, I, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, W, _, _, _, M, _, _, _, _, W, _, _, _, _, _, _, _, _, _, W],
      [W, _, _, _, W, W, W, W, D, W, W, _, _, _, _, _, _, _, _, W, W, D, W, W, W, _, _, _, _, W],
      [W, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, _, W],
      [W, _, _, _, W, _, I, _, _, _, _, _, _, W, W, W, W, _, _, _, _, _, I, _, W, _, _, _, _, W],
      [W, _, _, _, W, _, _, _, _, _, _, _, _, W, _, _, W, _, _, _, _, _, _, _, W, _, _, M, _, W],
      [W, _, _, _, W, _, _, _, _, _, _, _, _, W, _, _, W, _, _, _, _, _, _, _, W, W, W, W, W, W],
      [W, _, _, _, W, W, W, W, _, _, _, G, _, W, _, _, W, _, A, _, _, W, W, W, W, _, _, _, _, W],
      [W, _, _, _, _, _, _, W, _, _, _, _, _, D, _, _, D, _, _, _, _, W, _, _, _, _, _, _, _, W],
      [W, _, A, _, _, _, _, W, _, _, _, _, _, W, _, _, W, _, _, _, _, W, _, _, _, C, _, _, _, W],
      [W, _, _, _, _, _, _, W, W, W, W, D, W, W, _, _, W, W, D, W, W, W, _, _, _, _, _, _, _, W],
      [W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W],
      [W, W, W, W, W, _, _, _, _, I, _, _, _, _, _, _, _, _, _, _, I, _, _, _, _, W, W, W, W, W],
      [W, _, _, _, W, _, _, _, _, _, _, _, _, _, _, H, _, _, _, _, _, _, _, _, _, W, _, _, _, W],
      [W, _, H, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, W],
      [W, _, _, _, W, _, _, _, _, _, M, _, _, _, C, _, _, _, M, _, _, _, _, _, _, W, _, X, _, W],
      [W, _, _, _, W, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, W, _, _, _, W],
      [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
    ];

    final map = GameMap(width: 30, height: 20, tiles: tiles);
    map.spawnEntities();
    return map;
  }
}
