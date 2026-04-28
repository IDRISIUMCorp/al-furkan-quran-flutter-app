import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/qibla.dart';
import '../domain/repositories/qibla_repository.dart';

// ── States ──

enum QiblaStatus { initial, loading, loaded, error }

class QiblaState {
  final QiblaStatus status;
  final QiblaInfo? qiblaInfo;
  final ({double latitude, double longitude})? savedLocation;
  final bool isCompassAvailable;
  final String? errorMessage;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.qiblaInfo,
    this.savedLocation,
    this.isCompassAvailable = true,
    this.errorMessage,
  });

  QiblaState copyWith({
    QiblaStatus? status,
    QiblaInfo? qiblaInfo,
    ({double latitude, double longitude})? savedLocation,
    bool? isCompassAvailable,
    String? errorMessage,
  }) =>
      QiblaState(
        status: status ?? this.status,
        qiblaInfo: qiblaInfo ?? this.qiblaInfo,
        savedLocation: savedLocation ?? this.savedLocation,
        isCompassAvailable: isCompassAvailable ?? this.isCompassAvailable,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class QiblaEvent {
  const QiblaEvent();
}

final class LoadQiblaInfo extends QiblaEvent {
  const LoadQiblaInfo();
}

final class UpdateLocation extends QiblaEvent {
  final double latitude;
  final double longitude;
  const UpdateLocation({required this.latitude, required this.longitude});
}

final class CheckCompassAvailability extends QiblaEvent {
  const CheckCompassAvailability();
}

// ── BLoC ──

class QiblaBloc extends Bloc<QiblaEvent, QiblaState> {
  final QiblaRepository _qiblaRepository;

  QiblaBloc({required QiblaRepository qiblaRepository})
      : _qiblaRepository = qiblaRepository,
        super(const QiblaState()) {
    on<LoadQiblaInfo>(_onLoadQiblaInfo);
    on<UpdateLocation>(_onUpdateLocation);
    on<CheckCompassAvailability>(_onCheckCompassAvailability);
  }

  Future<void> _onLoadQiblaInfo(
    LoadQiblaInfo event,
    Emitter<QiblaState> emit,
  ) async {
    emit(state.copyWith(status: QiblaStatus.loading));
    final result = await _qiblaRepository.getQiblaInfo();
    result.fold(
      (failure) => emit(state.copyWith(
        status: QiblaStatus.error,
        errorMessage: failure.message,
      )),
      (qiblaInfo) => emit(state.copyWith(
        status: QiblaStatus.loaded,
        qiblaInfo: qiblaInfo,
      )),
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<QiblaState> emit,
  ) async {
    // Save new location
    final saveResult = await _qiblaRepository.saveLocation(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    saveResult.fold(
      (failure) => emit(state.copyWith(
        status: QiblaStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // Recalculate Qibla bearing with new location
        final bearing = QiblaInfo.calculateBearing(
          event.latitude,
          event.longitude,
        );
        emit(state.copyWith(
          status: QiblaStatus.loaded,
          savedLocation: (latitude: event.latitude, longitude: event.longitude),
          qiblaInfo: QiblaInfo(
            latitude: event.latitude,
            longitude: event.longitude,
            qiblaBearing: bearing,
            locationName: '',
          ),
        ));
      },
    );
  }

  Future<void> _onCheckCompassAvailability(
    CheckCompassAvailability event,
    Emitter<QiblaState> emit,
  ) async {
    final result = await _qiblaRepository.isCompassAvailable();
    result.fold(
      (failure) => emit(state.copyWith(isCompassAvailable: false)),
      (available) => emit(state.copyWith(isCompassAvailable: available)),
    );
  }
}
