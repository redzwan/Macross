import 'package:flutter/material.dart';

enum GamePhase { playing, paused, gameOver }

class GameController extends ChangeNotifier {
  int _lives = 3;
  int _score = 0;
  int _ammoMissiles = 10;
  int _ammoBullets = 10;
  bool _shieldActive = false;
  GamePhase _gamePhase = GamePhase.playing;

  // Getters
  int get lives => _lives;
  int get score => _score;
  int get ammoMissiles => _ammoMissiles;
  int get ammoBullets => _ammoBullets;
  bool get shieldActive => _shieldActive;
  GamePhase get gamePhase => _gamePhase;

  // Setters & Actions
  void setGamePhase(GamePhase phase) {
    _gamePhase = phase;
    notifyListeners();
  }

  void decrementLife() {
    if (!_shieldActive && _gamePhase == GamePhase.playing) {
      _lives--;
      if (_lives <= 0) {
        _gamePhase = GamePhase.gameOver;
      }
      notifyListeners();
    }
  }

  void setShieldActive(bool active) {
    _shieldActive = active;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void replenishAmmo(int missileAmount, int bulletAmount) {
    _ammoMissiles += missileAmount;
    _ammoBullets += bulletAmount;
    notifyListeners();
  }

  void useMissile() {
    if (_ammoMissiles > 0) {
      _ammoMissiles--;
      notifyListeners();
    }
  }

  void useBullet() {
    if (_ammoBullets > 0) {
      _ammoBullets--;
      notifyListeners();
    }
  }

  void reset() {
    _lives = 3;
    _score = 0;
    _ammoMissiles = 10;
    _ammoBullets = 10;
    _shieldActive = false;
    _gamePhase = GamePhase.playing;
    notifyListeners();
  }
}
