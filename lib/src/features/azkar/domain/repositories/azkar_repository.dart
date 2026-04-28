import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/azkar.dart';

/// Azkar Repository Interface — Abstract contract for azkar data
abstract class AzkarRepository {
  /// Get all azkar categories
  Future<Either<Failure, List<AzkarCategory>>> getCategories();

  /// Get azkar items for a specific category
  Future<Either<Failure, List<AzkarItem>>> getAzkarByCategory(int categoryId);

  /// Get a single azkar item
  Future<Either<Failure, AzkarItem>> getAzkarItem(int id);

  /// Get azkar items by type (morning, evening, etc.)
  Future<Either<Failure, List<AzkarItem>>> getAzkarByType(AzkarType type);

  /// Get the remaining count for a specific azkar (progress tracking)
  Future<Either<Failure, int>> getRemainingCount(int azkarId);

  /// Save the remaining count for a specific azkar
  Future<Either<Failure, void>> saveRemainingCount({
    required int azkarId,
    required int remaining,
  });

  /// Reset all azkar counts (e.g., at midnight for daily azkar)
  Future<Either<Failure, void>> resetDailyCounts();
}
