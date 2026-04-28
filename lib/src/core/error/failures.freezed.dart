// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message!
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? statusCode = freezed}) {
    return _then(
      _$NetworkFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl({required this.message, this.statusCode});

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'Failure.network(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return network(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return network?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure({
    required final String message,
    final int? statusCode,
  }) = _$NetworkFailureImpl;

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
    _$ServerFailureImpl value,
    $Res Function(_$ServerFailureImpl) then,
  ) = __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
    _$ServerFailureImpl _value,
    $Res Function(_$ServerFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? statusCode = freezed}) {
    return _then(
      _$ServerFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl({required this.message, this.statusCode});

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'Failure.server(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return server(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return server?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure({
    required final String message,
    final int? statusCode,
  }) = _$ServerFailureImpl;

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimeoutFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$TimeoutFailureImplCopyWith(
    _$TimeoutFailureImpl value,
    $Res Function(_$TimeoutFailureImpl) then,
  ) = __$$TimeoutFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$TimeoutFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$TimeoutFailureImpl>
    implements _$$TimeoutFailureImplCopyWith<$Res> {
  __$$TimeoutFailureImplCopyWithImpl(
    _$TimeoutFailureImpl _value,
    $Res Function(_$TimeoutFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$TimeoutFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TimeoutFailureImpl implements TimeoutFailure {
  const _$TimeoutFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.timeout(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeoutFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeoutFailureImplCopyWith<_$TimeoutFailureImpl> get copyWith =>
      __$$TimeoutFailureImplCopyWithImpl<_$TimeoutFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return timeout(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return timeout?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return timeout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return timeout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(this);
    }
    return orElse();
  }
}

abstract class TimeoutFailure implements Failure {
  const factory TimeoutFailure({final String? message}) = _$TimeoutFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeoutFailureImplCopyWith<_$TimeoutFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
    _$CacheFailureImpl value,
    $Res Function(_$CacheFailureImpl) then,
  ) = __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
    _$CacheFailureImpl _value,
    $Res Function(_$CacheFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$CacheFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.cache(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return cache(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return cache?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements Failure {
  const factory CacheFailure({required final String message}) =
      _$CacheFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DataIntegrityFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$DataIntegrityFailureImplCopyWith(
    _$DataIntegrityFailureImpl value,
    $Res Function(_$DataIntegrityFailureImpl) then,
  ) = __$$DataIntegrityFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    String resourceKey,
    String? expectedHash,
    String? actualHash,
  });
}

/// @nodoc
class __$$DataIntegrityFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$DataIntegrityFailureImpl>
    implements _$$DataIntegrityFailureImplCopyWith<$Res> {
  __$$DataIntegrityFailureImplCopyWithImpl(
    _$DataIntegrityFailureImpl _value,
    $Res Function(_$DataIntegrityFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? resourceKey = null,
    Object? expectedHash = freezed,
    Object? actualHash = freezed,
  }) {
    return _then(
      _$DataIntegrityFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        resourceKey: null == resourceKey
            ? _value.resourceKey
            : resourceKey // ignore: cast_nullable_to_non_nullable
                  as String,
        expectedHash: freezed == expectedHash
            ? _value.expectedHash
            : expectedHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        actualHash: freezed == actualHash
            ? _value.actualHash
            : actualHash // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DataIntegrityFailureImpl implements DataIntegrityFailure {
  const _$DataIntegrityFailureImpl({
    required this.message,
    required this.resourceKey,
    this.expectedHash,
    this.actualHash,
  });

  @override
  final String message;
  @override
  final String resourceKey;
  @override
  final String? expectedHash;
  @override
  final String? actualHash;

  @override
  String toString() {
    return 'Failure.dataIntegrity(message: $message, resourceKey: $resourceKey, expectedHash: $expectedHash, actualHash: $actualHash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataIntegrityFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.resourceKey, resourceKey) ||
                other.resourceKey == resourceKey) &&
            (identical(other.expectedHash, expectedHash) ||
                other.expectedHash == expectedHash) &&
            (identical(other.actualHash, actualHash) ||
                other.actualHash == actualHash));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, message, resourceKey, expectedHash, actualHash);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataIntegrityFailureImplCopyWith<_$DataIntegrityFailureImpl>
  get copyWith =>
      __$$DataIntegrityFailureImplCopyWithImpl<_$DataIntegrityFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return dataIntegrity(message, resourceKey, expectedHash, actualHash);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return dataIntegrity?.call(message, resourceKey, expectedHash, actualHash);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (dataIntegrity != null) {
      return dataIntegrity(message, resourceKey, expectedHash, actualHash);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return dataIntegrity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return dataIntegrity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (dataIntegrity != null) {
      return dataIntegrity(this);
    }
    return orElse();
  }
}

abstract class DataIntegrityFailure implements Failure {
  const factory DataIntegrityFailure({
    required final String message,
    required final String resourceKey,
    final String? expectedHash,
    final String? actualHash,
  }) = _$DataIntegrityFailureImpl;

  @override
  String get message;
  String get resourceKey;
  String? get expectedHash;
  String? get actualHash;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataIntegrityFailureImplCopyWith<_$DataIntegrityFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NotFoundFailureImplCopyWith(
    _$NotFoundFailureImpl value,
    $Res Function(_$NotFoundFailureImpl) then,
  ) = __$$NotFoundFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NotFoundFailureImpl>
    implements _$$NotFoundFailureImplCopyWith<$Res> {
  __$$NotFoundFailureImplCopyWithImpl(
    _$NotFoundFailureImpl _value,
    $Res Function(_$NotFoundFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$NotFoundFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundFailureImpl implements NotFoundFailure {
  const _$NotFoundFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      __$$NotFoundFailureImplCopyWithImpl<_$NotFoundFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundFailure implements Failure {
  const factory NotFoundFailure({required final String message}) =
      _$NotFoundFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$PermissionFailureImplCopyWith(
    _$PermissionFailureImpl value,
    $Res Function(_$PermissionFailureImpl) then,
  ) = __$$PermissionFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$PermissionFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PermissionFailureImpl>
    implements _$$PermissionFailureImplCopyWith<$Res> {
  __$$PermissionFailureImplCopyWithImpl(
    _$PermissionFailureImpl _value,
    $Res Function(_$PermissionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$PermissionFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PermissionFailureImpl implements PermissionFailure {
  const _$PermissionFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.permission(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      __$$PermissionFailureImplCopyWithImpl<_$PermissionFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return permission(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return permission?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionFailure implements Failure {
  const factory PermissionFailure({required final String message}) =
      _$PermissionFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(
    _$ValidationFailureImpl value,
    $Res Function(_$ValidationFailureImpl) then,
  ) = __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(
    _$ValidationFailureImpl _value,
    $Res Function(_$ValidationFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ValidationFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.validation(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return validation(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return validation?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure({required final String message}) =
      _$ValidationFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? originalError});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? originalError = freezed}) {
    return _then(
      _$UnknownFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        originalError: freezed == originalError
            ? _value.originalError
            : originalError,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({required this.message, this.originalError});

  @override
  final String message;
  @override
  final Object? originalError;

  @override
  String toString() {
    return 'Failure.unknown(message: $message, originalError: $originalError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other.originalError,
              originalError,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(originalError),
  );

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String? message) timeout,
    required TResult Function(String message) cache,
    required TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )
    dataIntegrity,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) validation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return unknown(message, originalError);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String? message)? timeout,
    TResult? Function(String message)? cache,
    TResult? Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? validation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return unknown?.call(message, originalError);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String? message)? timeout,
    TResult Function(String message)? cache,
    TResult Function(
      String message,
      String resourceKey,
      String? expectedHash,
      String? actualHash,
    )?
    dataIntegrity,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? validation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, originalError);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(TimeoutFailure value) timeout,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(DataIntegrityFailure value) dataIntegrity,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(TimeoutFailure value)? timeout,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(DataIntegrityFailure value)? dataIntegrity,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(TimeoutFailure value)? timeout,
    TResult Function(CacheFailure value)? cache,
    TResult Function(DataIntegrityFailure value)? dataIntegrity,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({
    required final String message,
    final Object? originalError,
  }) = _$UnknownFailureImpl;

  @override
  String get message;
  Object? get originalError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
