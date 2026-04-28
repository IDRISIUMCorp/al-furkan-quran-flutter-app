import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/qibla.dart';
import '../../domain/repositories/qibla_repository.dart';
import '../datasources/qibla_data_source.dart';

/// Qibla Repository Implementation — bridges domain and data layers
class QiblaRepositoryImpl implements QiblaRepository {
  final QiblaLocalDataSource _localDataSource;

  QiblaRepositoryImpl({required QiblaLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, QiblaInfo>> getQiblaInfo() async {
    final locationResult = await getSavedLocation();
    return locationResult.fold(
      (failure) => Left(failure),
      (location) {
        final bearing = QiblaInfo.calculateBearing(
          location.latitude,
          location.longitude,
        );
        return Right(QiblaInfo(
          latitude: location.latitude,
          longitude: location.longitude,
          qiblaBearing: bearing,
          locationName: '',
        ));
      },
    );
  }

  @override
  Future<Either<Failure, ({double latitude, double longitude})>> getSavedLocation() async {
    final location = _localDataSource.getSavedLocation();
    if (location == null) {
      return Left(Failure.cache(message: 'No saved location for Qibla'));
    }
    return Right(location);
  }

  @override
  Future<Either<Failure, void>> saveLocation({
    required double latitude,
    required double longitude,
  }) {
    return ErrorHandler.guard(() => _localDataSource.saveLocation(
          latitude: latitude,
          longitude: longitude,
        ));
  }

  @override
  Future<Either<Failure, bool>> isCompassAvailable() async {
    return Right(_localDataSource.isCompassAvailable());
  }
}
