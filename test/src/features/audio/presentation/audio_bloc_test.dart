import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_furkan/src/core/error/failures.dart';
import 'package:al_furkan/src/features/audio/domain/entities/reciter.dart';
import 'package:al_furkan/src/features/audio/domain/repositories/audio_repository.dart';
import 'package:al_furkan/src/features/audio/presentation/audio_bloc.dart';

const _testReciter = Reciter(
  id: 1,
  nameArabic: 'عبد الباسط عبد الصمد',
  nameEnglish: 'Abdul Basit Abdul Samad',
  serverUrl: 'https://server.example.com',
  style: ReciterStyle.murattal,
);

class MockAudioRepository implements AudioRepository {
  final Either<Failure, List<Reciter>> allRecitersResponse;
  final Either<Failure, Reciter> reciterResponse;
  final Either<Failure, Reciter> selectedReciterResponse;
  final Either<Failure, void> saveSelectedReciterResponse;
  final Either<Failure, String> ayahAudioUrlResponse;
  final Either<Failure, String> surahAudioUrlResponse;
  final Either<Failure, void> downloadSurahAudioResponse;
  final Either<Failure, void> deleteSurahAudioResponse;
  final Either<Failure, bool> isSurahDownloadedResponse;

  MockAudioRepository({
    this.allRecitersResponse = const Right([]),
    this.reciterResponse = const Right(_testReciter),
    this.selectedReciterResponse = const Right(_testReciter),
    this.saveSelectedReciterResponse = const Right(null),
    this.ayahAudioUrlResponse = const Right('https://audio.example.com/ayah.mp3'),
    this.surahAudioUrlResponse = const Right('https://audio.example.com/surah.mp3'),
    this.downloadSurahAudioResponse = const Right(null),
    this.deleteSurahAudioResponse = const Right(null),
    this.isSurahDownloadedResponse = const Right(false),
  });

  @override
  Future<Either<Failure, List<Reciter>>> getAllReciters() async =>
      allRecitersResponse;

  @override
  Future<Either<Failure, Reciter>> getReciter(int id) async =>
      reciterResponse;

  @override
  Future<Either<Failure, Reciter>> getSelectedReciter() async =>
      selectedReciterResponse;

  @override
  Future<Either<Failure, void>> saveSelectedReciter(int reciterId) async =>
      saveSelectedReciterResponse;

  @override
  Future<Either<Failure, String>> getAyahAudioUrl({
    required int reciterId,
    required String ayahKey,
  }) async => ayahAudioUrlResponse;

  @override
  Future<Either<Failure, String>> getSurahAudioUrl({
    required int reciterId,
    required int surahId,
  }) async => surahAudioUrlResponse;

  @override
  Future<Either<Failure, void>> downloadSurahAudio({
    required int reciterId,
    required int surahId,
  }) async => downloadSurahAudioResponse;

  @override
  Future<Either<Failure, void>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) async => deleteSurahAudioResponse;

  @override
  Future<Either<Failure, bool>> isSurahDownloaded({
    required int reciterId,
    required int surahId,
  }) async => isSurahDownloadedResponse;
}

void main() {
  group('AudioBloc', () {
    late AudioBloc bloc;

    setUp(() {
      bloc = AudioBloc(audioRepository: MockAudioRepository());
    });

    tearDown(() => bloc.close());

    test('initial state has status initial', () {
      expect(bloc.state.status, AudioStatus.initial);
      expect(bloc.state.reciters, isEmpty);
      expect(bloc.state.selectedReciter, isNull);
    });

    test('LoadReciters emits [loading, loaded] with reciters', () async {
      final recitersBloc = AudioBloc(
        audioRepository: MockAudioRepository(
          allRecitersResponse: Right([_testReciter]),
        ),
      );

      final states = <AudioState>[];
      final subscription = recitersBloc.stream.listen(states.add);

      recitersBloc.add(const LoadReciters());
      await recitersBloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, AudioStatus.loading);
      expect(states.last.status, AudioStatus.loaded);
      expect(states.last.reciters.length, 1);
      expect(states.last.reciters.first.nameEnglish, 'Abdul Basit Abdul Samad');

      await recitersBloc.close();
    });

    test('LoadReciters on error emits [loading, error]', () async {
      final errorBloc = AudioBloc(
        audioRepository: MockAudioRepository(
          allRecitersResponse: Left(const Failure.network(message: 'No connection')),
        ),
      );

      final states = <AudioState>[];
      final subscription = errorBloc.stream.listen(states.add);

      errorBloc.add(const LoadReciters());
      await errorBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, AudioStatus.error);
      expect(states.last.errorMessage, 'No connection');

      await errorBloc.close();
    });

    test('SelectReciter sets selectedReciter', () async {
      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const SelectReciter(1));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.selectedReciter, isNotNull);
      expect(states.last.selectedReciter!.id, 1);
    });

    test('PlaySurah sets status to playing and currentSurahId', () async {
      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const PlaySurah(1));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, AudioStatus.playing);
      expect(states.last.currentSurahId, 1);
    });

    test('PauseAudio sets status to paused', () async {
      // Start playing first
      bloc.add(const PlaySurah(1));
      await bloc.stream.first;

      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const PauseAudio());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, AudioStatus.paused);
    });

    test('ResumeAudio sets status back to playing', () async {
      bloc.add(const PlaySurah(1));
      await bloc.stream.first;
      bloc.add(const PauseAudio());
      await bloc.stream.first;

      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const ResumeAudio());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, AudioStatus.playing);
    });

    test('StopAudio sets status to loaded', () async {
      bloc.add(const PlaySurah(1));
      await bloc.stream.first;

      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const StopAudio());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, AudioStatus.loaded);
    });

    test('UpdatePlaybackPosition updates position and duration', () async {
      final states = <AudioState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const UpdatePlaybackPosition(
        Duration(minutes: 2),
        Duration(minutes: 30),
      ));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.currentPosition, const Duration(minutes: 2));
      expect(states.last.totalDuration, const Duration(minutes: 30));
    });
  });
}
