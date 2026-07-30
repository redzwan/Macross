import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'controller.dart';
import 'jet_game.dart';

class PlayerJet extends PositionComponent with HasGameRef<JetGame>, KeyboardHandler {
  static const double _speed = 300.0;
  static const double _missileSpeed = 600.0;
  static const double _bulletSpeed = 800.0;
  static const double _jetWidth = 40.0;
  static const double _jetHeight = 50.0;

  // Jet position (center)
  Vector2 _velocity = Vector2.zero();

  // Shooting cooldowns
  double _missileCooldown = 0.0;
  double _bulletCooldown = 0.0;
  static const double _missileCooldownMax = 0.5;
  static const double _bulletCooldownMax = 0.15;

  PlayerJet() : super(
    size: Vector2(_jetWidth, _jetHeight),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Start at bottom center of screen
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 80);
    priority = 10; // Render on top of other things
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (controller.gamePhase != GamePhase.playing) return;

    _updateMovement(dt);
    _updateCooldowns(dt);
    _keepInBounds();
  }

  void _updateMovement(double dt) {
    position += _velocity * dt;
  }

  void _updateCooldowns(double dt) {
    if (_missileCooldown > 0) _missileCooldown -= dt;
    if (_bulletCooldown > 0) _bulletCooldown -= dt;
  }

  void _keepInBounds() {
    final halfWidth = width / 2;
    final halfHeight = height / 2;

    position.x = position.x.clamp(halfWidth, gameRef.size.x - halfWidth);
    position.y = position.y.clamp(halfHeight, gameRef.size.y - halfHeight);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (controller.gamePhase != GamePhase.playing) return false;

    _velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _velocity.x -= _speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _velocity.x += _speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _velocity.y -= _speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _velocity.y += _speed;
    }

    // Fire missile with Space
    if (keysPressed.contains(LogicalKeyboardKey.space) && _missileCooldown <= 0 && controller.ammoMissiles > 0) {
      _fireMissile();
    }

    // Fire bullet with Shift
    if (keysPressed.contains(LogicalKeyboardKey.shiftLeft) && _bulletCooldown <= 0 && controller.ammoBullets > 0) {
      _fireBullet();
    }

    // Toggle shield with 'S' key
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      controller.setShieldActive(true);
    } else {
      controller.setShieldActive(false);
    }

    return true;
  }

  void _fireMissile() {
    controller.useMissile();
    _missileCooldown = _missileCooldownMax;

    final missile = Missile(
      position - Vector2(0, height / 2), // Start from top of jet
      position - Vector2(0, height / 2 + 20), // Old position slightly behind
    );
    controller.missiles.add(missile);
  }

  void _fireBullet() {
    controller.useBullet();
    _bulletCooldown = _bulletCooldownMax;

    final bullet = Bullet(position - Vector2(0, height / 2));
    controller.bullets.add(bullet);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.cyan;
    final accentPaint = Paint()..color = Colors.blueAccent;
    final enginePaint = Paint()..color = Colors.orangeAccent;

    // Jet body (triangle pointing up)
    final path = Path();
    path.moveTo(0, -height / 2); // Nose
    path.lineTo(-width / 2, height / 2); // Bottom left
    path.lineTo(-width / 4, height / 3); // Engine left
    path.lineTo(width / 4, height / 3); // Engine right
    path.lineTo(width / 2, height / 2); // Bottom right
    path.close();

    canvas.drawPath(path, paint);

    // Cockpit
    canvas.drawCircle(
      const Offset(0, -5),
      6,
      accentPaint,
    );

    // Engine glow
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(-width / 6, height / 3),
        width: width / 4,
        height: height / 6,
      ),
      enginePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 6, height / 3),
        width: width / 4,
        height: height / 6,
      ),
      enginePaint,
    );

    // Shield indicator
    if (controller.shieldActive) {
      final shieldPaint = Paint()
        ..color = const Color(0x6600FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(
        Offset.zero,
        max(width, height) * 0.7,
        shieldPaint,
      );
    }
  }

  JetGameController get controller => gameRef.controller;

  // Called when jet takes damage
  void takeDamage() {
    controller.decrementLife();
  }

  // Check collision with a circle (enemies, etc)
  bool checkCollision(Vector2 otherCenter, double otherRadius) {
    final jetRadius = max(width, height) / 2;
    final distance = (position - otherCenter).length;
    return distance < jetRadius + otherRadius;
  }
}