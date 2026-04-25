import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:al_furkan/core/models/update_config.dart';
import 'package:al_furkan/core/repositories/update_repository.dart';

// ─────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────

sealed class UpdateCheckState {
  const UpdateCheckState();
}

final class UpdateCheckIdle extends UpdateCheckState {
  const UpdateCheckIdle();
}

final class UpdateCheckLoading extends UpdateCheckState {
  const UpdateCheckLoading();
}

/// An update is available.
final class UpdateAvailable extends UpdateCheckState {
  const UpdateAvailable(this.result);
  final UpdateCheckResult result;
}

/// App is up to date.
final class UpdateNotRequired extends UpdateCheckState {
  const UpdateNotRequired();
}

final class UpdateCheckError extends UpdateCheckState {
  const UpdateCheckError(this.message);
  final String message;
}

// ─────────────────────────────────────────────────────────────
// CUBIT
// ─────────────────────────────────────────────────────────────

class UpdateCheckCubit extends Cubit<UpdateCheckState> {
  UpdateCheckCubit({UpdateRepository? repository})
      : _repository = repository ?? UpdateRepository(),
        super(const UpdateCheckIdle());

  final UpdateRepository _repository;

  /// Check for updates by comparing the installed version against Firestore.
  Future<void> checkForUpdate() async {
    emit(const UpdateCheckLoading());

    try {
      final config = await _repository.getConfig();
      log('UpdateCheck: isEnabled=${config.isEnabled}, '
          'currentVersion=${config.currentVersion}, '
          'minRequired=${config.minRequiredVersion}',
          name: 'UpdateCheckCubit');

      // If updates are disabled, skip.
      if (!config.isEnabled) {
        log('UpdateCheck: Updates disabled in Firestore config', name: 'UpdateCheckCubit');
        emit(const UpdateNotRequired());
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      log('UpdateCheck: Installed version=$currentVersion', name: 'UpdateCheckCubit');

      final hasUpdate = _isNewerVersion(config.currentVersion, currentVersion);
      final isForced = config.isForce ||
          _isNewerVersion(config.minRequiredVersion, currentVersion);

      log('UpdateCheck: hasUpdate=$hasUpdate, isForced=$isForced', name: 'UpdateCheckCubit');

      if (hasUpdate) {
        emit(UpdateAvailable(UpdateCheckResult(
          hasUpdate: true,
          isForced: isForced,
          config: config,
        )));
      } else {
        emit(const UpdateNotRequired());
      }
    } catch (e, st) {
      log('checkForUpdate error: $e', name: 'UpdateCheckCubit', stackTrace: st);
      emit(const UpdateNotRequired()); // Fail silently for user.
    }
  }

  /// Dismiss the update dialog (only for non-forced updates).
  void dismiss() => emit(const UpdateNotRequired());

  /// Compares two semver strings. Returns true if [remote] > [local].
  bool _isNewerVersion(String remote, String local) {
    try {
      final cleanRemote = remote.split('+')[0];
      final cleanLocal = local.split('+')[0];

      final r = cleanRemote.split('.').map(int.parse).toList();
      final l = cleanLocal.split('.').map(int.parse).toList();

      // Pad to 3 segments.
      while (r.length < 3) { r.add(0); }
      while (l.length < 3) { l.add(0); }

      for (var i = 0; i < 3; i++) {
        if (r[i] > l[i]) return true;
        if (r[i] < l[i]) return false;
      }
      return false; // Equal.
    } catch (_) {
      return false;
    }
  }
}
