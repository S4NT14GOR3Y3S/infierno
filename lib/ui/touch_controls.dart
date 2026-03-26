import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/assets.dart';
import '../utils/image_cache_manager.dart';

class TouchControls extends StatefulWidget {
  final Function(double dx, double dy) onMove;
  final Function(bool shooting) onShoot;
  final VoidCallback onSwitchWeapon;

  const TouchControls({
    super.key,
    required this.onMove,
    required this.onShoot,
    required this.onSwitchWeapon,
  });

  @override
  State<TouchControls> createState() => _TouchControlsState();
}

class _TouchControlsState extends State<TouchControls> with TickerProviderStateMixin {
  Offset _joystickPos = Offset.zero;
  int? _joystickPointer;
  bool _isShooting = false;
  late AnimationController _shootPulse;
  late Animation<double> _shootScale;
  final _imgCache = ImageCacheManager();

  static const double joystickRadius = 58.0;
  static const double knobRadius = 26.0;

  @override
  void initState() {
    super.initState();
    _shootPulse = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _shootScale = Tween<double>(begin: 1.0, end: 0.87)
        .animate(CurvedAnimation(parent: _shootPulse, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shootPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: [
        Positioned(left: 20, bottom: 80, child: _buildJoystick()),
        Positioned(right: 20, bottom: 80, child: _buildRightButtons()),
      ]),
    );
  }

  Widget _buildJoystick() {
    double mag = _joystickPos.distance / joystickRadius;
    final baseImg = _imgCache.get(GameAssets.joystickBase);
    final knobImg = _imgCache.get(GameAssets.joystickKnob);

    return Listener(
      onPointerDown: (e) { _joystickPointer = e.pointer; _updateJoystick(e.localPosition); },
      onPointerMove: (e) { if (e.pointer == _joystickPointer) _updateJoystick(e.localPosition); },
      onPointerUp:   (e) { if (e.pointer == _joystickPointer) _resetJoystick(); },
      onPointerCancel: (e) { if (e.pointer == _joystickPointer) _resetJoystick(); },
      child: SizedBox(
        width: (joystickRadius + 5) * 2,
        height: (joystickRadius + 5) * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base image
            if (baseImg != null)
              Opacity(
                opacity: 0.7,
                child: RawImage(image: baseImg,
                  width: (joystickRadius + 5) * 2,
                  height: (joystickRadius + 5) * 2,
                  fit: BoxFit.fill),
              )
            else
              Container(
                width: (joystickRadius + 5) * 2,
                height: (joystickRadius + 5) * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(color: InfernoColors.playerCore.withOpacity(0.4), width: 1.5)),
              ),
            // Knob
            Transform.translate(
              offset: _joystickPos,
              child: knobImg != null
                ? Opacity(
                    opacity: 0.85 + mag * 0.15,
                    child: RawImage(image: knobImg,
                      width: knobRadius * 2,
                      height: knobRadius * 2,
                      fit: BoxFit.fill))
                : Container(
                    width: knobRadius * 2,
                    height: knobRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: InfernoColors.playerShell,
                      border: Border.all(color: InfernoColors.playerCore.withOpacity(0.9), width: 2),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  void _updateJoystick(Offset local) {
    double cx = joystickRadius + 5, cy = joystickRadius + 5;
    double dx = local.dx - cx, dy = local.dy - cy;
    double dist = sqrt(dx*dx + dy*dy);
    if (dist > joystickRadius) { dx = dx/dist*joystickRadius; dy = dy/dist*joystickRadius; dist = joystickRadius; }
    setState(() => _joystickPos = Offset(dx, dy));
    double nx = dist < 8 ? 0 : dx / joystickRadius;
    double ny = dist < 8 ? 0 : dy / joystickRadius;
    widget.onMove(nx, ny);
  }

  void _resetJoystick() {
    _joystickPointer = null;
    setState(() => _joystickPos = Offset.zero);
    widget.onMove(0, 0);
  }

  Widget _buildRightButtons() {
    final fireImg        = _imgCache.get(GameAssets.fireButton);
    final firePressedImg = _imgCache.get(GameAssets.fireButtonPressed);
    final weaponImg      = _imgCache.get(GameAssets.weaponButton);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weapon switch
        GestureDetector(
          onTap: widget.onSwitchWeapon,
          child: weaponImg != null
            ? RawImage(image: weaponImg, width: 56, height: 56)
            : Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.35),
                  border: Border.all(color: InfernoColors.scoreColor.withOpacity(0.6), width: 1.5)),
                child: const Icon(Icons.swap_horiz, color: InfernoColors.scoreColor, size: 22),
              ),
        ),
        const SizedBox(height: 12),
        // Fire button
        Listener(
          onPointerDown: (_) {
            setState(() => _isShooting = true);
            _shootPulse.forward(from: 0);
            widget.onShoot(true);
          },
          onPointerUp: (_) {
            setState(() => _isShooting = false);
            _shootPulse.reverse();
            widget.onShoot(false);
          },
          onPointerCancel: (_) {
            setState(() => _isShooting = false);
            _shootPulse.reverse();
            widget.onShoot(false);
          },
          child: AnimatedBuilder(
            animation: _shootScale,
            builder: (ctx, _) {
              final img = _isShooting ? (firePressedImg ?? fireImg) : fireImg;
              return Transform.scale(
                scale: _isShooting ? _shootScale.value : 1.0,
                child: img != null
                  ? RawImage(image: img, width: 88, height: 88)
                  : Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isShooting
                          ? InfernoColors.healthLow.withOpacity(0.5)
                          : Colors.black.withOpacity(0.4),
                        border: Border.all(color: InfernoColors.healthLow, width: 2.5)),
                      child: const Icon(Icons.gps_fixed, color: InfernoColors.healthLow, size: 34),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}
