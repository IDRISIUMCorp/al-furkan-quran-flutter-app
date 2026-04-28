import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_furkan/src/core/error/failures.dart';
import 'package:al_furkan/src/features/tafsir/domain/entities/tafsir.dart';
import 'package:al_furkan/src/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:al_furkan/src/features/tafsir/presentation/tafsir_bloc.dart';

const _testTafsir = Tafsir(
  id: 1,
  nameArabic: 'تفسير الطبري',
  nameEnglish: 'Tafsir Al-Tabari',
  authorArabic: 'الإمام الطبري',
  authorEnglish: 'Imam Al-Tabari',
  languageCode: 'ar',
  type: TafsirType.tafsir,
);

const _testEntry = TafsirEntry(
  ayahKey: '1:1',
  tafsirId: 1,
  text: 'بسم الله الرحمن الرحيم',
);

class MockTafsirRepository implements TafsirRepository {
  final Either<Failure, List<Tafsir>> allTafsirsResponse;
  final Either<Failure, Tafsir> tafsirResponse;
  final Either<Failure, TafsirEntry> tafsirEntryResponse;
  final Either<Failure, List<TafsirEntry>> tafsirForSurahResponse;
  final Either<Failure, Tafsir> selectedTafsirResponse;
  final Either<Failure, void> saveSelectedTafsirResponse;
  final Either<Failure, void> downloadTafsirResponse;
  final Either<Failure, void> deleteTafsirResponse;
  final Either<Failure, bool> isTafsirDownloadedResponse;

  MockTafsirRepository({
    this.allTafsirsResponse = const Right([]),
    this.tafsirResponse = const Right(_testTafsir),
    this.tafsirEntryResponse = const Right(_testEntry),
    this.tafsirForSurahResponse = const Right([_testEntry]),
    this.selectedTafsirResponse = const Right(_testTafsir),
    this.saveSelectedTafsirResponse = const Right(null),
    this.downloadTafsirResponse = const Right(null),
    this.deleteTafsirResponse = const Right(null),
    this.isTafsirDownloadedResponse = const Right(false),
  });

  @override
  Future<Either<Failure, List<Tafsir>>> getAllTafsirs() async =>
      allTafsirsResponse;

  @override
  Future<Either<Failure, Tafsir>> getTafsir(int id) async =>
      tafsirResponse;

  @override
  Future<Either<Failure, TafsirEntry>> getTafsirEntry({
    required int tafsirId,
    required String ayahKey,
  }) async => tafsirEntryResponse;

  @override
  Future<Either<Failure, List<TafsirEntry>>> getTafsirForSurah({
    required int tafsirId,
    required int surahId,
  }) async => tafsirForSurahResponse;

  @override
  Future<Either<Failure, Tafsir>> getSelectedTafsir() async =>
      selectedTafsirResponse;

  @override
  Future<Either<Failure, void>> saveSelectedTafsir(int tafsirId) async =>
      saveSelectedTafsirResponse;

  @override
  Future<Either<Failure, void>> downloadTafsir(int tafsirId) async =>
      downloadTafsirResponse;

  @override
  Future<Either<Failure, void>> deleteTafsir(int tafsirId) async =>
      deleteTafsirResponse;

  @override
  Future<Either<Failure, bool>> isTafsirDownloaded(int tafsirId) async =>
      isTafsirDownloadedResponse;
}

void main() {
  group('TafsirBloc', () {
    late TafsirBloc bloc;

    setUp(() {
      bloc = TafsirBloc(tafsirRepository: MockTafsirRepository());
    });

    tearDown(() => bloc.close());

    test('initial state has status initial', () {
      expect(bloc.state.status, TafsirStatus.initial);
      expect(bloc.state.tafsirs, isEmpty);
      expect(bloc.state.selectedTafsir, isNull);
    });

    test('LoadAllTafsirs emits [loading, loaded] with tafsirs', () async {
      final tafsirsBloc = TafsirBloc(
        tafsirRepository: MockTafsirRepository(
          allTafsirsResponse: Right([_testTafsir]),
        ),
      );

      final states = <TafsirState>[];
      final subscription = tafsirsBloc.stream.listen(states.add);

      tafsirsBloc.add(const LoadAllTafsirs());
      await tafsirsBloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, TafsirStatus.loading);
      expect(states.last.status, TafsirStatus.loaded);
      expect(states.last.tafsirs.length, 1);
      expect(states.last.tafsirs.first.nameArabic, 'تفسير الطبري');

      await tafsirsBloc.close();
    });

    test('LoadAllTafsirs on error emits [loading, error]', () async {
      final errorBloc = TafsirBloc(
        tafsirRepository: MockTafsirRepository(
          allTafsirsResponse: Left(const Failure.cache(message: 'DB error')),
        ),
      );

      final states = <TafsirState>[];
      final subscription = errorBloc.stream.listen(states.add);

      errorBloc.add(const LoadAllTafsirs());
      await errorBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, TafsirStatus.error);
      expect(states.last.errorMessage, 'DB error');

      await errorBloc.close();
    });

    test('SelectTafsir sets selectedTafsir', () async {
      final states = <TafsirState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const SelectTafsir(1));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.selectedTafsir, isNotNull);
      expect(states.last.selectedTafsir!.id, 1);
    });

    test('LoadTafsirForAyah sets currentEntries', () async {
      final states = <TafsirState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadTafsirForAyah(tafsirId: 1, ayahKey: '1:1'));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, TafsirStatus.loaded);
      expect(states.last.currentEntries.length, 1);
      expect(states.last.currentEntries.first.ayahKey, '1:1');
    });

    test('LoadTafsirForSurah emits [loading, loaded] with entries', () async {
      final states = <TafsirState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadTafsirForSurah(tafsirId: 1, surahId: 1));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, TafsirStatus.loading);
      expect(states.last.status, TafsirStatus.loaded);
      expect(states.last.currentEntries.length, 1);
    });
  });
}
