import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/quran_repository.dart';

/// Get All Surahs Use Case — Single Responsibility: fetch all 114 surahs
class GetAllSurahsUseCase {
  final QuranRepository _repository;
  GetAllSurahsUseCase(this._repository);

  Future<Either<Failure, List<Surah>>> call() => _repository.getAllSurahs();
}
