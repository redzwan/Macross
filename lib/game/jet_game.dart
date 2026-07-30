import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'controller.dart';
import 'player_jet.dart';

class Missile {
  final Vector2 position;
  final Vector2 oldPosition;

  Missile(this.position, this.oldPosition);
}

class Bullet {
  final Vector2 position;

  Bullet(this.position);
}

class JetGameController extends GameController {
  JetGameController();

  final List<Missile> missiles = [];
  final List<Bullet> bullets = [];
  Vector2? shieldCenter;

  @override
  void setGamePhase(GamePhase phase) {
    super.setGamePhase(phase);
    if (phase == GamePhase.gameOver) {
      loseGame();
    }
  }

  void loseGame() {
    if (gamePhase != GamePhase.gameOver) {
      super.setGamePhase(GamePhase.gameOver);
    }
  }

  void pauseGame() {
    setGamePhase(GamePhase.paused);
  }
}

class JetPanel extends Component {
  final JetGameController controller;

  JetPanel(this.controller);

  @override
  void render(Canvas canvas) {
    final missilePaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final bulletPaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    final shieldPaint = Paint()
      ..color = const Color(0x99FF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (controller.gamePhase == GamePhase.gameOver) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Game Over',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 200, 60),
        Paint()..color = Colors.black,
      );
      textPainter.paint(canvas, const Offset(12, 12));
    }

    for (final missile in controller.missiles) {
      canvas.drawLine(
        Offset(missile.oldPosition.x, missile.oldPosition.y),
        Offset(missile.position.x, missile.position.y),
        missilePaint,
      );
    }

    for (final bullet in controller.bullets) {
      canvas.drawCircle(
        Offset(bullet.position.x, bullet.position.y),
        6,
        bulletPaint,
      );
    }

    if (controller.shieldActive && controller.shieldCenter != null) {
      canvas.drawCircle(
        Offset(controller.shieldCenter!.x, controller.shieldCenter!.y),
        30,
        shieldPaint,
      );
    }
  }
}

class JetGame extends FlameGame {
  late final JetGameController controller;

  @override
  Future<void> onLoad() async {
    controller = JetGameController();
    add(JetPanel(controller));
    add(PlayerJet()); // Add the player jet to the game
  }
}
