import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'game/game_engine.dart';
import 'rendering/game_renderer.dart';
import 'ui/hud.dart';
import 'ui/touch_controls.dart';
import 'ui/main_menu.dart';
import 'ui/game_over_screen.dart';
import 'utils/constants.dart';
import 'utils/assets.dart';
import 'utils/image_cache_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const Inferno2DApp());
}

class Inferno2DApp extends StatelessWidget {
  const Inferno2DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INFERNO 2D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: InfernoColors.menuBg,
      ),
      home: const _AssetLoader(),
    );
  }
}

// ── CORRECCIÓN CRÍTICA: Pantalla de carga que precarga TODOS los assets ──────
// El problema era que ImageCacheManager.loadAll() nunca se llamaba,
// por lo que todos los sprites usaban los fallbacks (círculos/cuadrados).
class _AssetLoader extends StatefulWidget {
  const _AssetLoader();

  @override
  State<_AssetLoader> createState() => _AssetLoaderState();
}

class _AssetLoaderState extends State<_AssetLoader> {
  bool _loaded = false;
  String _status = 'Cargando assets...';

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final cache = ImageCacheManager();
      await cache.loadAll([
        // Sprites
        GameAssets.player,
        GameAssets.wraith,
        GameAssets.crusher,
        GameAssets.specter,
        GameAssets.bulletPlayer,
        GameAssets.bulletEnemy,
        GameAssets.plasma,
        GameAssets.pickupHealth,
        GameAssets.pickupAmmo,
        GameAssets.pickupWeapon,
        GameAssets.particles,
        // Tiles
        GameAssets.tileWall,
        GameAssets.tileFloorDark,
        GameAssets.tileFloorMid,
        GameAssets.tileDoor,
        GameAssets.tileDoorLocked,
        GameAssets.tileExit,
        // UI
        GameAssets.hudPanel,
        GameAssets.crosshair,
        GameAssets.joystickBase,
        GameAssets.joystickKnob,
        GameAssets.fireButton,
        GameAssets.fireButtonPressed,
        GameAssets.weaponButton,
      ]);
      if (mounted) setState(() { _loaded = true; });
    } catch (e) {
      // Si falla la carga de algún asset, continúa de todas formas
      // (los fallbacks procedurales se activarán)
      if (mounted) setState(() { _loaded = true; _status = 'Listo (modo fallback)'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) return const GameScreen();

    // Pantalla de carga estilo DOOM
    return Scaffold(
      backgroundColor: InfernoColors.void_,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'INFERNO 2D',
              style: TextStyle(
                color: Color(0xFFFF1744),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFF1A0808),
                color: const Color(0xFFFF1744),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(
                color: Color(0xFF78909C),
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine engine;
  late Ticker _ticker;
  double _totalTime = 0;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    engine = GameEngine();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    double dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    if (dt > 0.05) dt = 0.05;
    _totalTime += dt;

    for (var pickup in engine.currentMap.pickups) {
      pickup.update(dt);
    }
    engine.update(dt);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    engine.audio.dispose();
    super.dispose();
  }

  void _onMove(double dx, double dy) {
    engine.player.moveX = dx;
    engine.player.moveY = dy;
  }

  void _onShoot(bool shooting) {
    engine.player.isShooting = shooting;
  }

  void _onSwitchWeapon() {
    engine.player.switchWeapon();
  }

  void _startNewGame() {
    engine.startNewGame();
    setState(() {});
  }

  void _goToMenu() {
    engine.state = GameState.menu;
    setState(() {});
  }

  void _nextLevel() {
    engine.nextLevel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (engine.state == GameState.menu)
            MainMenuScreen(onStartGame: _startNewGame),

          if (engine.state == GameState.playing ||
              engine.state == GameState.levelComplete ||
              engine.state == GameState.gameOver ||
              engine.state == GameState.victory) ...[
            Positioned.fill(
              child: CustomPaint(
                painter: GameRenderer(engine: engine, time: _totalTime),
                child: Container(),
              ),
            ),
            if (engine.state == GameState.playing) HudOverlay(engine: engine),
            if (engine.state == GameState.playing)
              TouchControls(
                onMove: _onMove,
                onShoot: _onShoot,
                onSwitchWeapon: _onSwitchWeapon,
              ),
          ],

          if (engine.state == GameState.levelComplete)
            LevelCompleteScreen(
              level: engine.currentLevel,
              kills: engine.killCount,
              score: engine.player.score,
              onNextLevel: _nextLevel,
            ),

          if (engine.state == GameState.gameOver ||
              engine.state == GameState.victory)
            GameOverScreen(
              score: engine.player.score,
              level: engine.currentLevel,
              kills: engine.totalKills + engine.killCount,
              isVictory: engine.state == GameState.victory,
              onRestart: _startNewGame,
              onMenu: _goToMenu,
            ),
        ],
      ),
    );
  }
}
