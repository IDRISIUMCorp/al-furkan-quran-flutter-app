import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/quran_repository.dart';

/// Get Quran Page Use Case — Single Responsibility: fetch a single Mushaf page
class GetQuranPageUseCase {
  final QuranRepository _repository;
  GetQuranPageUseCase(this._repository);

  Future<Either<Failure, QuranPage>> call(int pageNumber) =>
      _repository.getPage(pageNumber);
}
