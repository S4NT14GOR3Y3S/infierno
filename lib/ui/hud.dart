import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/assets.dart';
import '../game/game_engine.dart';
import '../game/player.dart';

class HudOverlay extends StatelessWidget {
  final GameEngine engine;
  const HudOverlay({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final player = engine.player;
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Stack(children: [
            // Top-left: enemy counter
            Positioned(left: 12, top: 12, child: _buildEnemyCounter()),
            // Bottom bar
            Positioned(left: 0, right: 0, bottom: 0, child: _buildHudBar(player)),
          ]),
        ),
      ),
    );
  }

  Widget _buildEnemyCounter() {
    int count = engine.enemiesRemaining;
    Color c = count > 0 ? InfernoColors.healthLow : InfernoColors.healthFull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: InfernoColors.hudBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: InfernoColors.hudBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 6),
        Text(
          count > 0 ? '$count RESTANTES' : 'ZONA DESPEJADA',
          style: TextStyle(
            color: c, fontSize: 11, fontWeight: FontWeight.bold,
            fontFamily: 'monospace', letterSpacing: 1.5),
        ),
      ]),
    );
  }

  Widget _buildHudBar(Player player) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: InfernoColors.hudBg,
        border: const Border(top: BorderSide(color: InfernoColors.hudBorder, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Row(
          children: [
            _buildHealth(player),
            const SizedBox(width: 16),
            _buildSep(),
            const SizedBox(width: 16),
            _buildWeapon(player),
            const Spacer(),
            _buildSep(),
            const SizedBox(width: 16),
            _buildScore(player),
            const SizedBox(width: 16),
            _buildLevelBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealth(Player player) {
    double pct = player.health / player.maxHealth;
    Color hc = pct > 0.6 ? InfernoColors.healthFull
             : pct > 0.3 ? InfernoColors.healthMid
             : InfernoColors.healthLow;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Icon(Icons.shield, color: hc, size: 13),
            const SizedBox(width: 5),
            Text(
              '${player.health}',
              style: TextStyle(
                color: hc, fontSize: 22, fontWeight: FontWeight.w900,
                fontFamily: 'monospace'),
            ),
            const SizedBox(width: 4),
            Text('/ ${player.maxHealth}',
              style: TextStyle(color: InfernoColors.textSecondary.withOpacity(0.6),
                fontSize: 11, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 5),
          Stack(children: [
            Container(
              height: 5, width: 140,
              decoration: BoxDecoration(
                color: InfernoColors.hudBorder, borderRadius: BorderRadius.circular(3))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 5,
              width: 140 * pct.clamp(0, 1),
              decoration: BoxDecoration(
                color: hc,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [BoxShadow(color: hc.withOpacity(0.5), blurRadius: 4)],
              )),
          ]),
        ],
      ),
    );
  }

  Widget _buildWeapon(Player player) {
    String name; Color color; String ammoStr;
    switch (player.currentWeapon) {
      case WeaponType.pistol:
        name = 'PISTOLA'; color = InfernoColors.bulletPlayer; ammoStr = '∞'; break;
      case WeaponType.shotgun:
        name = 'ESCOPETA'; color = InfernoColors.bulletPlayer;
        ammoStr = '${player.ammo[WeaponType.shotgun] ?? 0}'; break;
      case WeaponType.plasmaRifle:
        name = 'PLASMA'; color = InfernoColors.plasma;
        ammoStr = '${player.ammo[WeaponType.plasmaRifle] ?? 0}'; break;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(
          color: color.withOpacity(0.75), fontSize: 10,
          fontFamily: 'monospace', letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(Icons.flash_on, color: InfernoColors.ammoColor, size: 13),
          const SizedBox(width: 3),
          Text(ammoStr, style: const TextStyle(
            color: InfernoColors.ammoColor, fontSize: 20,
            fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ]),
      ],
    );
  }

  Widget _buildScore(Player player) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('PUNTOS', style: TextStyle(
        color: InfernoColors.textSecondary, fontSize: 9,
        letterSpacing: 2, fontFamily: 'monospace')),
      Text('${player.score}', style: const TextStyle(
        color: InfernoColors.scoreColor, fontSize: 20,
        fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    ]);
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: InfernoColors.playerCore.withOpacity(0.35), width: 1),
        borderRadius: BorderRadius.circular(4),
        color: InfernoColors.playerCore.withOpacity(0.05)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('NIVEL', style: TextStyle(
          color: InfernoColors.textSecondary, fontSize: 9,
          letterSpacing: 2, fontFamily: 'monospace')),
        Text('${engine.currentLevel + 1}', style: const TextStyle(
          color: InfernoColors.playerCore, fontSize: 20,
          fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ]),
    );
  }

  Widget _buildSep() {
    return Container(width: 1, height: 40, color: InfernoColors.hudBorder);
  }
}
