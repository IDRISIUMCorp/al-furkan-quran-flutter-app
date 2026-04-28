import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/quran_repository.dart';

/// Search Ayahs Use Case — Single Responsibility: search Quran text
class SearchAyahsUseCase {
  final QuranRepository _repository;
  SearchAyahsUseCase(this._repository);

  Future<Either<Failure, List<Ayah>>> call(String query) =>
      _repository.searchAyahs(query);
}
