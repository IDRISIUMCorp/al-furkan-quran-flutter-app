import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/azkar.dart';
import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_data_source.dart';

/// Azkar Repository Implementation — bridges domain and data layers
class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource _localDataSource;

  AzkarRepositoryImpl({required AzkarLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<AzkarCategory>>> getCategories() {
    return ErrorHandler.guard(() async {
      final models = await _localDataSource.loadCategories();
      return models.map((m) => m.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, List<AzkarItem>>> getAzkarByCategory(int categoryId) {
    return ErrorHandler.guard(() async {
      final models = await _localDataSource.loadAzkarByCategory(categoryId);
      return models.map((m) => m.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, AzkarItem>> getAzkarItem(int id) async {
    final result = await getCategories();
    return result.fold(
      (failure) => Left(failure),
      (categories) async {
        for (final cat in categories) {
          final itemsResult = await getAzkarByCategory(cat.id);
          final found = itemsResult.fold(
            (_) => <AzkarItem>[],
            (items) => items,
          );
          final match = found.where((i) => i.id == id).firstOrNull;
          if (match != null) return Right(match);
        }
        return Left(Failure.cache(message: 'Azkar item $id not found'));
      },
    );
  }

  @override
  Future<Either<Failure, List<AzkarItem>>> getAzkarByType(AzkarType type) async {
    // Filter all categories' items by type
    final result = await getCategories();
    return result.fold(
      (failure) => Left(failure),
      (categories) async {
        final allItems = <AzkarItem>[];
        for (final cat in categories) {
          final itemsResult = await getAzkarByCategory(cat.id);
          itemsResult.fold((_) => null, (items) => allItems.addAll(items));
        }
        return Right(allItems.where((i) => i.type == type).toList());
      },
    );
  }

  @override
  Future<Either<Failure, int>> getRemainingCount(int azkarId) async {
    return Right(_localDataSource.getAzkarProgress(azkarId));
  }

  @override
  Future<Either<Failure, void>> saveRemainingCount({
    required int azkarId,
    required int remaining,
  }) {
    return ErrorHandler.guard(
        () => _localDataSource.saveAzkarProgress(azkarId, remaining));
  }

  @override
  Future<Either<Failure, void>> resetDailyCounts() async {
    // Reset all azkar progress keys in SharedPreferences
    return ErrorHandler.guard(() async {
      final prefs = _localDataSource.prefs;
      final keys = prefs.getKeys().where((k) => k.startsWith('azkar_progress_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    });
  }
}
