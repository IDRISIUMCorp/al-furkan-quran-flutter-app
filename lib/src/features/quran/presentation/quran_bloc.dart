import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/entities.dart';
import '../domain/usecases/get_all_surahs.dart';
import '../domain/usecases/get_quran_page.dart';
import '../domain/usecases/search_ayahs.dart';

// ── States ──

enum QuranStatus { initial, loading, loaded, error }

class QuranState {
  final QuranStatus status;
  final List<Surah> surahs;
  final QuranPage? currentPage;
  final int currentPageIndex;
  final String? lastAyahKey;
  final String? errorMessage;

  const QuranState({
    this.status = QuranStatus.initial,
    this.surahs = const [],
    this.currentPage,
    this.currentPageIndex = 0,
    this.lastAyahKey,
    this.errorMessage,
  });

  QuranState copyWith({
    QuranStatus? status,
    List<Surah>? surahs,
    QuranPage? currentPage,
    int? currentPageIndex,
    String? lastAyahKey,
    String? errorMessage,
  }) =>
      QuranState(
        status: status ?? this.status,
        surahs: surahs ?? this.surahs,
        currentPage: currentPage ?? this.currentPage,
        currentPageIndex: currentPageIndex ?? this.currentPageIndex,
        lastAyahKey: lastAyahKey ?? this.lastAyahKey,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class QuranEvent {
  const QuranEvent();
}

final class LoadSurahs extends QuranEvent {
  const LoadSurahs();
}

final class LoadQuranPage extends QuranEvent {
  final int pageNumber;
  const LoadQuranPage(this.pageNumber);
}

final class GoToPage extends QuranEvent {
  final int pageIndex;
  const GoToPage(this.pageIndex);
}

final class SaveLastReadPosition extends QuranEvent {
  final int page;
  final String ayahKey;
  const SaveLastReadPosition({required this.page, required this.ayahKey});
}

final class SearchAyahs extends QuranEvent {
  final String query;
  const SearchAyahs(this.query);
}

// ── BLoC ──

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetAllSurahsUseCase _getAllSurahs;
  final GetQuranPageUseCase _getQuranPage;
  final SearchAyahsUseCase _searchAyahs;

  QuranBloc({
    required GetAllSurahsUseCase getAllSurahs,
    required GetQuranPageUseCase getQuranPage,
    required SearchAyahsUseCase searchAyahs,
  })  : _getAllSurahs = getAllSurahs,
        _getQuranPage = getQuranPage,
        _searchAyahs = searchAyahs,
        super(const QuranState()) {
    on<LoadSurahs>(_onLoadSurahs);
    on<LoadQuranPage>(_onLoadQuranPage);
    on<GoToPage>(_onGoToPage);
    on<SaveLastReadPosition>(_onSaveLastReadPosition);
    on<SearchAyahs>(_onSearchAyahs);
  }

  Future<void> _onLoadSurahs(LoadSurahs event, Emitter<QuranState> emit) async {
    emit(state.copyWith(status: QuranStatus.loading));
    final result = await _getAllSurahs();
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (surahs) => emit(state.copyWith(
        status: QuranStatus.loaded,
        surahs: surahs,
      )),
    );
  }

  Future<void> _onLoadQuranPage(LoadQuranPage event, Emitter<QuranState> emit) async {
    final result = await _getQuranPage(event.pageNumber);
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: QuranStatus.loaded,
        currentPage: page,
      )),
    );
  }

  void _onGoToPage(GoToPage event, Emitter<QuranState> emit) {
    emit(state.copyWith(currentPageIndex: event.pageIndex));
  }

  Future<void> _onSaveLastReadPosition(SaveLastReadPosition event, Emitter<QuranState> emit) async {
    emit(state.copyWith(lastAyahKey: event.ayahKey));
  }

  Future<void> _onSearchAyahs(SearchAyahs event, Emitter<QuranState> emit) async {
    if (event.query.isEmpty) return;
    final result = await _searchAyahs(event.query);
    result.fold(
      (failure) => emit(state.copyWith(
        status: QuranStatus.error,
        errorMessage: failure.message,
      )),
      (_) {}, // Search results handled separately
    );
  }
}
