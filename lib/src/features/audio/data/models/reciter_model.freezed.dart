// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reciter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReciterModel _$ReciterModelFromJson(Map<String, dynamic> json) {
  return _ReciterModel.fromJson(json);
}

/// @nodoc
mixin _$ReciterModel {
  int get id => throw _privateConstructorUsedError;
  String get nameArabic => throw _privateConstructorUsedError;
  String get nameEnglish => throw _privateConstructorUsedError;
  String get serverUrl => throw _privateConstructorUsedError;
  String get style => throw _privateConstructorUsedError; // ReciterStyle name
  bool get isOfflineAvailable => throw _privateConstructorUsedError;
  int get downloadedSurahs => throw _privateConstructorUsedError;

  /// Serializes this ReciterModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReciterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReciterModelCopyWith<ReciterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReciterModelCopyWith<$Res> {
  factory $ReciterModelCopyWith(
    ReciterModel value,
    $Res Function(ReciterModel) then,
  ) = _$ReciterModelCopyWithImpl<$Res, ReciterModel>;
  @useResult
  $Res call({
    int id,
    String nameArabic,
    String nameEnglish,
    String serverUrl,
    String style,
    bool isOfflineAvailable,
    int downloadedSurahs,
  });
}

/// @nodoc
class _$ReciterModelCopyWithImpl<$Res, $Val extends ReciterModel>
    implements $ReciterModelCopyWith<$Res> {
  _$ReciterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReciterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? serverUrl = null,
    Object? style = null,
    Object? isOfflineAvailable = null,
    Object? downloadedSurahs = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            nameArabic: null == nameArabic
                ? _value.nameArabic
                : nameArabic // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEnglish: null == nameEnglish
                ? _value.nameEnglish
                : nameEnglish // ignore: cast_nullable_to_non_nullable
                      as String,
            serverUrl: null == serverUrl
                ? _value.serverUrl
                : serverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            style: null == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as String,
            isOfflineAvailable: null == isOfflineAvailable
                ? _value.isOfflineAvailable
                : isOfflineAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            downloadedSurahs: null == downloadedSurahs
                ? _value.downloadedSurahs
                : downloadedSurahs // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReciterModelImplCopyWith<$Res>
    implements $ReciterModelCopyWith<$Res> {
  factory _$$ReciterModelImplCopyWith(
    _$ReciterModelImpl value,
    $Res Function(_$ReciterModelImpl) then,
  ) = __$$ReciterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String nameArabic,
    String nameEnglish,
    String serverUrl,
    String style,
    bool isOfflineAvailable,
    int downloadedSurahs,
  });
}

/// @nodoc
class __$$ReciterModelImplCopyWithImpl<$Res>
    extends _$ReciterModelCopyWithImpl<$Res, _$ReciterModelImpl>
    implements _$$ReciterModelImplCopyWith<$Res> {
  __$$ReciterModelImplCopyWithImpl(
    _$ReciterModelImpl _value,
    $Res Function(_$ReciterModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReciterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? serverUrl = null,
    Object? style = null,
    Object? isOfflineAvailable = null,
    Object? downloadedSurahs = null,
  }) {
    return _then(
      _$ReciterModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        nameArabic: null == nameArabic
            ? _value.nameArabic
            : nameArabic // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEnglish: null == nameEnglish
            ? _value.nameEnglish
            : nameEnglish // ignore: cast_nullable_to_non_nullable
                  as String,
        serverUrl: null == serverUrl
            ? _value.serverUrl
            : serverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        style: null == style
            ? _value.style
            : style // ignore: cast_nullable_to_non_nullable
                  as String,
        isOfflineAvailable: null == isOfflineAvailable
            ? _value.isOfflineAvailable
            : isOfflineAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        downloadedSurahs: null == downloadedSurahs
            ? _value.downloadedSurahs
            : downloadedSurahs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReciterModelImpl extends _ReciterModel {
  const _$ReciterModelImpl({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.serverUrl,
    required this.style,
    this.isOfflineAvailable = false,
    this.downloadedSurahs = 0,
  }) : super._();

  factory _$ReciterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReciterModelImplFromJson(json);

  @override
  final int id;
  @override
  final String nameArabic;
  @override
  final String nameEnglish;
  @override
  final String serverUrl;
  @override
  final String style;
  // ReciterStyle name
  @override
  @JsonKey()
  final bool isOfflineAvailable;
  @override
  @JsonKey()
  final int downloadedSurahs;

  @override
  String toString() {
    return 'ReciterModel(id: $id, nameArabic: $nameArabic, nameEnglish: $nameEnglish, serverUrl: $serverUrl, style: $style, isOfflineAvailable: $isOfflineAvailable, downloadedSurahs: $downloadedSurahs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReciterModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameArabic, nameArabic) ||
                other.nameArabic == nameArabic) &&
            (identical(other.nameEnglish, nameEnglish) ||
                other.nameEnglish == nameEnglish) &&
            (identical(other.serverUrl, serverUrl) ||
                other.serverUrl == serverUrl) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.isOfflineAvailable, isOfflineAvailable) ||
                other.isOfflineAvailable == isOfflineAvailable) &&
            (identical(other.downloadedSurahs, downloadedSurahs) ||
                other.downloadedSurahs == downloadedSurahs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nameArabic,
    nameEnglish,
    serverUrl,
    style,
    isOfflineAvailable,
    downloadedSurahs,
  );

  /// Create a copy of ReciterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReciterModelImplCopyWith<_$ReciterModelImpl> get copyWith =>
      __$$ReciterModelImplCopyWithImpl<_$ReciterModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReciterModelImplToJson(this);
  }
}

abstract class _ReciterModel extends ReciterModel {
  const factory _ReciterModel({
    required final int id,
    required final String nameArabic,
    required final String nameEnglish,
    required final String serverUrl,
    required final String style,
    final bool isOfflineAvailable,
    final int downloadedSurahs,
  }) = _$ReciterModelImpl;
  const _ReciterModel._() : super._();

  factory _ReciterModel.fromJson(Map<String, dynamic> json) =
      _$ReciterModelImpl.fromJson;

  @override
  int get id;
  @override
  String get nameArabic;
  @override
  String get nameEnglish;
  @override
  String get serverUrl;
  @override
  String get style; // ReciterStyle name
  @override
  bool get isOfflineAvailable;
  @override
  int get downloadedSurahs;

  /// Create a copy of ReciterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReciterModelImplCopyWith<_$ReciterModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
