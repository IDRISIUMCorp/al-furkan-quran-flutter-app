import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/azkar.dart';
import '../domain/repositories/azkar_repository.dart';

// ── States ──

enum AzkarStatus { initial, loading, loaded, error }

class AzkarState {
  final AzkarStatus status;
  final List<AzkarCategory> categories;
  final List<AzkarItem> currentAzkar;
  final AzkarType selectedType;
  final Map<int, int> remainingCounts; // azkarId → remaining count
  final String? errorMessage;

  const AzkarState({
    this.status = AzkarStatus.initial,
    this.categories = const [],
    this.currentAzkar = const [],
    this.selectedType = AzkarType.morning,
    this.remainingCounts = const {},
    this.errorMessage,
  });

  AzkarState copyWith({
    AzkarStatus? status,
    List<AzkarCategory>? categories,
    List<AzkarItem>? currentAzkar,
    AzkarType? selectedType,
    Map<int, int>? remainingCounts,
    String? errorMessage,
  }) =>
      AzkarState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        currentAzkar: currentAzkar ?? this.currentAzkar,
        selectedType: selectedType ?? this.selectedType,
        remainingCounts: remainingCounts ?? this.remainingCounts,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class AzkarEvent {
  const AzkarEvent();
}

final class LoadCategories extends AzkarEvent {
  const LoadCategories();
}

final class LoadAzkarByCategory extends AzkarEvent {
  final int categoryId;
  const LoadAzkarByCategory(this.categoryId);
}

final class LoadAzkarByType extends AzkarEvent {
  final AzkarType type;
  const LoadAzkarByType(this.type);
}

final class DecrementAzkarCount extends AzkarEvent {
  final int azkarId;
  const DecrementAzkarCount(this.azkarId);
}

final class ResetDailyCounts extends AzkarEvent {
  const ResetDailyCounts();
}

// ── BLoC ──

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final AzkarRepository _azkarRepository;

  AzkarBloc({required AzkarRepository azkarRepository})
      : _azkarRepository = azkarRepository,
        super(const AzkarState()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadAzkarByCategory>(_onLoadAzkarByCategory);
    on<LoadAzkarByType>(_onLoadAzkarByType);
    on<DecrementAzkarCount>(_onDecrementAzkarCount);
    on<ResetDailyCounts>(_onResetDailyCounts);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<AzkarState> emit,
  ) async {
    emit(state.copyWith(status: AzkarStatus.loading));
    final result = await _azkarRepository.getCategories();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AzkarStatus.error,
        errorMessage: failure.message,
      )),
      (categories) => emit(state.copyWith(
        status: AzkarStatus.loaded,
        categories: categories,
      )),
    );
  }

  Future<void> _onLoadAzkarByCategory(
    LoadAzkarByCategory event,
    Emitter<AzkarState> emit,
  ) async {
    emit(state.copyWith(status: AzkarStatus.loading));
    final result = await _azkarRepository.getAzkarByCategory(event.categoryId);
    await _loadRemainingCounts(result, emit);
  }

  Future<void> _onLoadAzkarByType(
    LoadAzkarByType event,
    Emitter<AzkarState> emit,
  ) async {
    emit(state.copyWith(status: AzkarStatus.loading, selectedType: event.type));
    final result = await _azkarRepository.getAzkarByType(event.type);
    await _loadRemainingCounts(result, emit);
  }

  Future<void> _loadRemainingCounts(
    Either<Failure, List<AzkarItem>> result,
    Emitter<AzkarState> emit,
  ) async {
    await result.fold(
      (failure) async => emit(state.copyWith(
        status: AzkarStatus.error,
        errorMessage: failure.message,
      )),
      (items) async {
        final counts = <int, int>{};
        for (final item in items) {
          final countResult = await _azkarRepository.getRemainingCount(item.id);
          countResult.fold((_) => null, (count) => counts[item.id] = count);
        }
        emit(state.copyWith(
          status: AzkarStatus.loaded,
          currentAzkar: items,
          remainingCounts: counts,
        ));
      },
    );
  }

  Future<void> _onDecrementAzkarCount(
    DecrementAzkarCount event,
    Emitter<AzkarState> emit,
  ) async {
    final current = state.remainingCounts[event.azkarId] ?? 0;
    if (current <= 0) return;

    final newCount = current - 1;
    final updatedCounts = Map<int, int>.from(state.remainingCounts);
    updatedCounts[event.azkarId] = newCount;

    await _azkarRepository.saveRemainingCount(
      azkarId: event.azkarId,
      remaining: newCount,
    );

    emit(state.copyWith(remainingCounts: updatedCounts));
  }

  Future<void> _onResetDailyCounts(
    ResetDailyCounts event,
    Emitter<AzkarState> emit,
  ) async {
    await _azkarRepository.resetDailyCounts();
    // Reload current azkar to reset counts
    if (state.currentAzkar.isNotEmpty) {
      final counts = <int, int>{};
      for (final item in state.currentAzkar) {
        counts[item.id] = item.count;
      }
      emit(state.copyWith(remainingCounts: counts));
    }
  }
}
