import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/game_session.dart';
import '../../core/utils/storage_service.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoaded extends HistoryEvent {
  const HistoryLoaded();
}

class HistoryCleared extends HistoryEvent {
  const HistoryCleared();
}

// State
class HistoryState extends Equatable {
  final List<GameSession> sessions;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HistoryState copyWith({
    List<GameSession>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [sessions, isLoading, errorMessage];
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final StorageService _storageService;

  HistoryBloc({required StorageService storageService})
      : _storageService = storageService,
        super(const HistoryState()) {
    on<HistoryLoaded>(_onHistoryLoaded);
    on<HistoryCleared>(_onHistoryCleared);
  }

  void _onHistoryLoaded(HistoryLoaded event, Emitter<HistoryState> emit) {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Get sessions from storage
      final sessions = _storageService.getGameSessions();
      
      // Sort sessions by date (newest first)
      sessions.sort((a, b) => b.date.compareTo(a.date));
      
      emit(state.copyWith(
        sessions: sessions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load history: $e',
      ));
    }
  }

  void _onHistoryCleared(HistoryCleared event, Emitter<HistoryState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Clear all sessions from storage
      await _storageService.clearSessions();
      
      emit(state.copyWith(
        sessions: [],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear history: $e',
      ));
    }
  }
} 