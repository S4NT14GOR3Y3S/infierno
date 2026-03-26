/// Audio manager placeholder for DOOM 2D.
/// Ready for integration with audioplayers or flame_audio packages.
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  void playShoot() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play shoot sound
  }

  void playShotgun() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play shotgun sound
  }

  void playPlasma() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play plasma sound
  }

  void playEnemyHit() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play enemy hit sound
  }

  void playEnemyDeath() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play enemy death sound
  }

  void playPlayerHurt() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play player hurt sound
  }

  void playPickup() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play pickup sound
  }

  void playDoorOpen() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play door open sound
  }

  void playLevelComplete() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play level complete fanfare
  }

  void playGameOver() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play game over sound
  }

  void playMenuMusic() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play menu background music
  }

  void playGameMusic() {
    if (!_soundEnabled) return;
    // TODO: Integrate audio package - play game background music
  }

  void stopMusic() {
    // TODO: Integrate audio package - stop all music
  }

  void dispose() {
    stopMusic();
  }
}
