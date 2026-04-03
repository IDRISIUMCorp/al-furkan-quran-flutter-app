import "package:al_quran_v3/src/core/reader_session/reader_session_repository.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "reader_ui_state.dart";

class ReaderUICubit extends Cubit<ReaderUIState> {
  ReaderUICubit(this._readerSessionRepository)
    : super(
        ReaderUIState(
          lastReadPage: _readerSessionRepository.loadLastReadPage(),
          lastReadAyahKey: _readerSessionRepository.loadLastReadAyahKey(),
        ),
      );

  final ReaderSessionRepository _readerSessionRepository;

  /// Toggle UI visibility (AppBar + BottomBar)
  void toggleUIVisibility() {
    emit(state.copyWith(isUIVisible: !state.isUIVisible));
  }

  /// Show UI
  void showUI() {
    if (!state.isUIVisible) {
      emit(state.copyWith(isUIVisible: true));
    }
  }

  /// Hide UI
  void hideUI() {
    if (state.isUIVisible) {
      emit(state.copyWith(isUIVisible: false));
    }
  }

  /// Set audio playing state
  void setAudioPlaying(bool isPlaying) {
    emit(state.copyWith(isAudioPlaying: isPlaying));
  }

  /// Save last read position
  Future<void> saveLastReadPosition({
    required int pageNumber,
    required String ayahKey,
  }) async {
    emit(state.copyWith(lastReadPage: pageNumber, lastReadAyahKey: ayahKey));

    await _readerSessionRepository.saveLastReadPosition(
      pageNumber: pageNumber,
      ayahKey: ayahKey,
    );
  }

  /// Get last read ayah key for navigation
  String? get lastReadAyahKey => state.lastReadAyahKey;

  /// Get last read page number
  int get lastReadPage => state.lastReadPage;
}
