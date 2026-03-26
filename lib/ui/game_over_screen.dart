import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int level;
  final int kills;
  final bool isVictory;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.level,
    required this.kills,
    required this.isVictory,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Color titleColor = widget.isVictory ? InfernoColors.exitBeacon : InfernoColors.menuTitle;
    String titleText = widget.isVictory ? 'VICTORIA' : 'MISIÓN FALLIDA';
    String subtitle = widget.isVictory ? 'HAS ESCAPADO DEL INFIERNO' : 'EL INFIERNO TE RECLAMÓ';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Opacity(
        opacity: _fadeIn.value,
        child: Container(
          color: Colors.black.withOpacity(0.88),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: titleColor.withOpacity(0.6), blurRadius: 30)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: InfernoColors.textSecondary,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),
                // Stats panel
                Container(
                  padding: const EdgeInsets.all(24),
                  width: 300,
                  decoration: BoxDecoration(
                    color: InfernoColors.hudBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: InfernoColors.hudBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      _statRow('PUNTUACIÓN', '${widget.score}', InfernoColors.scoreColor),
                      const SizedBox(height: 10),
                      _statRow('NIVEL', '${widget.level + 1}', InfernoColors.textPrimary),
                      const SizedBox(height: 10),
                      _statRow('BAJAS', '${widget.kills}', InfernoColors.healthLow),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                _buildButton('INTENTAR DE NUEVO', widget.onRestart, InfernoColors.menuTitle, InfernoColors.hudBg),
                const SizedBox(height: 14),
                _buildButton('MENÚ PRINCIPAL', widget.onMenu, InfernoColors.textSecondary, Colors.transparent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: InfernoColors.textSecondary, fontSize: 13, fontFamily: 'monospace', letterSpacing: 1)),
        Text(value, style: TextStyle(color: valColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color borderColor, Color bgColor) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 260,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor.withOpacity(0.7), width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: borderColor,
              letterSpacing: 3,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

class LevelCompleteScreen extends StatefulWidget {
  final int level;
  final int kills;
  final int score;
  final VoidCallback onNextLevel;

  const LevelCompleteScreen({
    super.key,
    required this.level,
    required this.kills,
    required this.score,
    required this.onNextLevel,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        double pulse = 0.5 + 0.5 * _ctrl.value;
        return Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ZONA DESPEJADA',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: InfernoColors.exitBeacon,
                    letterSpacing: 5,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: InfernoColors.exitBeacon.withOpacity(pulse * 0.8), blurRadius: 25)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'NIVEL ${widget.level + 1} COMPLETADO',
                  style: TextStyle(
                    fontSize: 12,
                    color: InfernoColors.textSecondary,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  decoration: BoxDecoration(
                    color: InfernoColors.hudBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: InfernoColors.hudBorder),
                  ),
                  child: Text(
                    'Bajas: ${widget.kills}   •   Puntos: ${widget.score}',
                    style: const TextStyle(
                      color: InfernoColors.scoreColor,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: widget.onNextLevel,
                  child: Container(
                    width: 240,
                    height: 52,
                    decoration: BoxDecoration(
                      color: InfernoColors.exitBeacon.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: InfernoColors.exitBeacon.withOpacity(0.6 + pulse * 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [BoxShadow(color: InfernoColors.exitBeacon.withOpacity(pulse * 0.3), blurRadius: 16)],
                    ),
                    child: const Center(
                      child: Text(
                        'SIGUIENTE NIVEL  ▶',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: InfernoColors.exitBeacon,
                          letterSpacing: 3,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
