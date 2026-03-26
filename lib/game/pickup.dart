import '../utils/constants.dart';

/// Represents an item pickup in the game world
class Pickup {
  double x;
  double y;
  PickupType type;
  bool isActive;
  double bobTimer; // For visual bobbing effect
  final double radius = 10.0;

  Pickup({
    required this.x,
    required this.y,
    required this.type,
    this.isActive = true,
    this.bobTimer = 0,
  });

  void update(double dt) {
    bobTimer += dt * 3.0;
  }

  /// Visual Y offset for bobbing animation
  double get bobOffset => 3.0 * (bobTimer % 6.283).abs();

  void collect() {
    isActive = false;
  }
}
