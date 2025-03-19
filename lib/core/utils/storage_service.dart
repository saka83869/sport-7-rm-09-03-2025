import 'package:get_storage/get_storage.dart';
import '../models/game_session.dart';

class StorageService {
  static const String _sessionsKey = 'game_sessions';
  final GetStorage _storage;

  StorageService() : _storage = GetStorage();

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save a game session
  Future<void> saveGameSession(GameSession session) async {
    final sessions = getGameSessions();
    sessions.add(session);
    await _storage.write(_sessionsKey, sessions.map((s) => s.toJson()).toList());
  }

  // Get all game sessions
  List<GameSession> getGameSessions() {
    final dynamic data = _storage.read(_sessionsKey);
    if (data == null) return [];
    
    return (data as List)
        .map((json) => GameSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Clear all sessions
  Future<void> clearSessions() async {
    await _storage.remove(_sessionsKey);
  }

  // Get the daily challenge status
  bool getDailyChallengeStatus() {
    final String today = DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD
    return _storage.read('daily_challenge_$today') ?? false;
  }

  // Set the daily challenge as completed
  Future<void> completeDailyChallenge() async {
    final String today = DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD
    await _storage.write('daily_challenge_$today', true);
  }
} 