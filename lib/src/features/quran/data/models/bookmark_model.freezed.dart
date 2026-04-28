// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookmarkModel _$BookmarkModelFromJson(Map<String, dynamic> json) {
  return _BookmarkModel.fromJson(json);
}

/// @nodoc
mixin _$BookmarkModel {
  String get id => throw _privateConstructorUsedError;
  String get ayahKey => throw _privateConstructorUsedError;
  int get surahId => throw _privateConstructorUsedError;
  int get ayahNumber => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this BookmarkModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkModelCopyWith<BookmarkModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkModelCopyWith<$Res> {
  factory $BookmarkModelCopyWith(
    BookmarkModel value,
    $Res Function(BookmarkModel) then,
  ) = _$BookmarkModelCopyWithImpl<$Res, BookmarkModel>;
  @useResult
  $Res call({
    String id,
    String ayahKey,
    int surahId,
    int ayahNumber,
    int page,
    DateTime createdAt,
    String? note,
    String type,
  });
}

/// @nodoc
class _$BookmarkModelCopyWithImpl<$Res, $Val extends BookmarkModel>
    implements $BookmarkModelCopyWith<$Res> {
  _$BookmarkModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ayahKey = null,
    Object? surahId = null,
    Object? ayahNumber = null,
    Object? page = null,
    Object? createdAt = null,
    Object? note = freezed,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ayahKey: null == ayahKey
                ? _value.ayahKey
                : ayahKey // ignore: cast_nullable_to_non_nullable
                      as String,
            surahId: null == surahId
                ? _value.surahId
                : surahId // ignore: cast_nullable_to_non_nullable
                      as int,
            ayahNumber: null == ayahNumber
                ? _value.ayahNumber
                : ayahNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookmarkModelImplCopyWith<$Res>
    implements $BookmarkModelCopyWith<$Res> {
  factory _$$BookmarkModelImplCopyWith(
    _$BookmarkModelImpl value,
    $Res Function(_$BookmarkModelImpl) then,
  ) = __$$BookmarkModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ayahKey,
    int surahId,
    int ayahNumber,
    int page,
    DateTime createdAt,
    String? note,
    String type,
  });
}

/// @nodoc
class __$$BookmarkModelImplCopyWithImpl<$Res>
    extends _$BookmarkModelCopyWithImpl<$Res, _$BookmarkModelImpl>
    implements _$$BookmarkModelImplCopyWith<$Res> {
  __$$BookmarkModelImplCopyWithImpl(
    _$BookmarkModelImpl _value,
    $Res Function(_$BookmarkModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ayahKey = null,
    Object? surahId = null,
    Object? ayahNumber = null,
    Object? page = null,
    Object? createdAt = null,
    Object? note = freezed,
    Object? type = null,
  }) {
    return _then(
      _$BookmarkModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ayahKey: null == ayahKey
            ? _value.ayahKey
            : ayahKey // ignore: cast_nullable_to_non_nullable
                  as String,
        surahId: null == surahId
            ? _value.surahId
            : surahId // ignore: cast_nullable_to_non_nullable
                  as int,
        ayahNumber: null == ayahNumber
            ? _value.ayahNumber
            : ayahNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkModelImpl extends _BookmarkModel {
  const _$BookmarkModelImpl({
    required this.id,
    required this.ayahKey,
    required this.surahId,
    required this.ayahNumber,
    required this.page,
    required this.createdAt,
    this.note = null,
    required this.type,
  }) : super._();

  factory _$BookmarkModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkModelImplFromJson(json);

  @override
  final String id;
  @override
  final String ayahKey;
  @override
  final int surahId;
  @override
  final int ayahNumber;
  @override
  final int page;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String? note;
  @override
  final String type;

  @override
  String toString() {
    return 'BookmarkModel(id: $id, ayahKey: $ayahKey, surahId: $surahId, ayahNumber: $ayahNumber, page: $page, createdAt: $createdAt, note: $note, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ayahKey, ayahKey) || other.ayahKey == ayahKey) &&
            (identical(other.surahId, surahId) || other.surahId == surahId) &&
            (identical(other.ayahNumber, ayahNumber) ||
                other.ayahNumber == ayahNumber) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ayahKey,
    surahId,
    ayahNumber,
    page,
    createdAt,
    note,
    type,
  );

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkModelImplCopyWith<_$BookmarkModelImpl> get copyWith =>
      __$$BookmarkModelImplCopyWithImpl<_$BookmarkModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkModelImplToJson(this);
  }
}

abstract class _BookmarkModel extends BookmarkModel {
  const factory _BookmarkModel({
    required final String id,
    required final String ayahKey,
    required final int surahId,
    required final int ayahNumber,
    required final int page,
    required final DateTime createdAt,
    final String? note,
    required final String type,
  }) = _$BookmarkModelImpl;
  const _BookmarkModel._() : super._();

  factory _BookmarkModel.fromJson(Map<String, dynamic> json) =
      _$BookmarkModelImpl.fromJson;

  @override
  String get id;
  @override
  String get ayahKey;
  @override
  int get surahId;
  @override
  int get ayahNumber;
  @override
  int get page;
  @override
  DateTime get createdAt;
  @override
  String? get note;
  @override
  String get type;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkModelImplCopyWith<_$BookmarkModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
