import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qibla.dart';

/// Qibla Repository Interface — Abstract contract for qibla direction data
abstract class QiblaRepository {
  /// Get Qibla bearing for current location
  Future<Either<Failure, QiblaInfo>> getQiblaInfo();

  /// Get saved location for Qibla calculation
  Future<Either<Failure, ({double latitude, double longitude})>> getSavedLocation();

  /// Save location for Qibla calculation
  Future<Either<Failure, void>> saveLocation({
    required double latitude,
    required double longitude,
  });

  /// Check if device compass is available
  Future<Either<Failure, bool>> isCompassAvailable();
}
