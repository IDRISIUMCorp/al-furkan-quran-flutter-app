// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'azkar_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AzkarCategoryModel _$AzkarCategoryModelFromJson(Map<String, dynamic> json) {
  return _AzkarCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$AzkarCategoryModel {
  int get id => throw _privateConstructorUsedError;
  String get nameArabic => throw _privateConstructorUsedError;
  String get nameEnglish => throw _privateConstructorUsedError;
  String get iconKey => throw _privateConstructorUsedError;
  int get azkarCount => throw _privateConstructorUsedError;

  /// Serializes this AzkarCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AzkarCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AzkarCategoryModelCopyWith<AzkarCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AzkarCategoryModelCopyWith<$Res> {
  factory $AzkarCategoryModelCopyWith(
    AzkarCategoryModel value,
    $Res Function(AzkarCategoryModel) then,
  ) = _$AzkarCategoryModelCopyWithImpl<$Res, AzkarCategoryModel>;
  @useResult
  $Res call({
    int id,
    String nameArabic,
    String nameEnglish,
    String iconKey,
    int azkarCount,
  });
}

/// @nodoc
class _$AzkarCategoryModelCopyWithImpl<$Res, $Val extends AzkarCategoryModel>
    implements $AzkarCategoryModelCopyWith<$Res> {
  _$AzkarCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AzkarCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? iconKey = null,
    Object? azkarCount = null,
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
            iconKey: null == iconKey
                ? _value.iconKey
                : iconKey // ignore: cast_nullable_to_non_nullable
                      as String,
            azkarCount: null == azkarCount
                ? _value.azkarCount
                : azkarCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AzkarCategoryModelImplCopyWith<$Res>
    implements $AzkarCategoryModelCopyWith<$Res> {
  factory _$$AzkarCategoryModelImplCopyWith(
    _$AzkarCategoryModelImpl value,
    $Res Function(_$AzkarCategoryModelImpl) then,
  ) = __$$AzkarCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String nameArabic,
    String nameEnglish,
    String iconKey,
    int azkarCount,
  });
}

/// @nodoc
class __$$AzkarCategoryModelImplCopyWithImpl<$Res>
    extends _$AzkarCategoryModelCopyWithImpl<$Res, _$AzkarCategoryModelImpl>
    implements _$$AzkarCategoryModelImplCopyWith<$Res> {
  __$$AzkarCategoryModelImplCopyWithImpl(
    _$AzkarCategoryModelImpl _value,
    $Res Function(_$AzkarCategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AzkarCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? iconKey = null,
    Object? azkarCount = null,
  }) {
    return _then(
      _$AzkarCategoryModelImpl(
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
        iconKey: null == iconKey
            ? _value.iconKey
            : iconKey // ignore: cast_nullable_to_non_nullable
                  as String,
        azkarCount: null == azkarCount
            ? _value.azkarCount
            : azkarCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AzkarCategoryModelImpl extends _AzkarCategoryModel {
  const _$AzkarCategoryModelImpl({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.iconKey,
    required this.azkarCount,
  }) : super._();

  factory _$AzkarCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AzkarCategoryModelImplFromJson(json);

  @override
  final int id;
  @override
  final String nameArabic;
  @override
  final String nameEnglish;
  @override
  final String iconKey;
  @override
  final int azkarCount;

  @override
  String toString() {
    return 'AzkarCategoryModel(id: $id, nameArabic: $nameArabic, nameEnglish: $nameEnglish, iconKey: $iconKey, azkarCount: $azkarCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AzkarCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameArabic, nameArabic) ||
                other.nameArabic == nameArabic) &&
            (identical(other.nameEnglish, nameEnglish) ||
                other.nameEnglish == nameEnglish) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.azkarCount, azkarCount) ||
                other.azkarCount == azkarCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nameArabic,
    nameEnglish,
    iconKey,
    azkarCount,
  );

  /// Create a copy of AzkarCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AzkarCategoryModelImplCopyWith<_$AzkarCategoryModelImpl> get copyWith =>
      __$$AzkarCategoryModelImplCopyWithImpl<_$AzkarCategoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AzkarCategoryModelImplToJson(this);
  }
}

abstract class _AzkarCategoryModel extends AzkarCategoryModel {
  const factory _AzkarCategoryModel({
    required final int id,
    required final String nameArabic,
    required final String nameEnglish,
    required final String iconKey,
    required final int azkarCount,
  }) = _$AzkarCategoryModelImpl;
  const _AzkarCategoryModel._() : super._();

  factory _AzkarCategoryModel.fromJson(Map<String, dynamic> json) =
      _$AzkarCategoryModelImpl.fromJson;

  @override
  int get id;
  @override
  String get nameArabic;
  @override
  String get nameEnglish;
  @override
  String get iconKey;
  @override
  int get azkarCount;

  /// Create a copy of AzkarCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AzkarCategoryModelImplCopyWith<_$AzkarCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AzkarItemModel _$AzkarItemModelFromJson(Map<String, dynamic> json) {
  return _AzkarItemModel.fromJson(json);
}

/// @nodoc
mixin _$AzkarItemModel {
  int get id => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  String get textArabic => throw _privateConstructorUsedError;
  String? get textTransliteration => throw _privateConstructorUsedError;
  String? get textTranslation => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // AzkarType name
  String? get audioAsset => throw _privateConstructorUsedError;

  /// Serializes this AzkarItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AzkarItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AzkarItemModelCopyWith<AzkarItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AzkarItemModelCopyWith<$Res> {
  factory $AzkarItemModelCopyWith(
    AzkarItemModel value,
    $Res Function(AzkarItemModel) then,
  ) = _$AzkarItemModelCopyWithImpl<$Res, AzkarItemModel>;
  @useResult
  $Res call({
    int id,
    int categoryId,
    String textArabic,
    String? textTransliteration,
    String? textTranslation,
    int count,
    String? reference,
    String type,
    String? audioAsset,
  });
}

/// @nodoc
class _$AzkarItemModelCopyWithImpl<$Res, $Val extends AzkarItemModel>
    implements $AzkarItemModelCopyWith<$Res> {
  _$AzkarItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AzkarItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? textArabic = null,
    Object? textTransliteration = freezed,
    Object? textTranslation = freezed,
    Object? count = null,
    Object? reference = freezed,
    Object? type = null,
    Object? audioAsset = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            textArabic: null == textArabic
                ? _value.textArabic
                : textArabic // ignore: cast_nullable_to_non_nullable
                      as String,
            textTransliteration: freezed == textTransliteration
                ? _value.textTransliteration
                : textTransliteration // ignore: cast_nullable_to_non_nullable
                      as String?,
            textTranslation: freezed == textTranslation
                ? _value.textTranslation
                : textTranslation // ignore: cast_nullable_to_non_nullable
                      as String?,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            audioAsset: freezed == audioAsset
                ? _value.audioAsset
                : audioAsset // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AzkarItemModelImplCopyWith<$Res>
    implements $AzkarItemModelCopyWith<$Res> {
  factory _$$AzkarItemModelImplCopyWith(
    _$AzkarItemModelImpl value,
    $Res Function(_$AzkarItemModelImpl) then,
  ) = __$$AzkarItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int categoryId,
    String textArabic,
    String? textTransliteration,
    String? textTranslation,
    int count,
    String? reference,
    String type,
    String? audioAsset,
  });
}

/// @nodoc
class __$$AzkarItemModelImplCopyWithImpl<$Res>
    extends _$AzkarItemModelCopyWithImpl<$Res, _$AzkarItemModelImpl>
    implements _$$AzkarItemModelImplCopyWith<$Res> {
  __$$AzkarItemModelImplCopyWithImpl(
    _$AzkarItemModelImpl _value,
    $Res Function(_$AzkarItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AzkarItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? textArabic = null,
    Object? textTransliteration = freezed,
    Object? textTranslation = freezed,
    Object? count = null,
    Object? reference = freezed,
    Object? type = null,
    Object? audioAsset = freezed,
  }) {
    return _then(
      _$AzkarItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        textArabic: null == textArabic
            ? _value.textArabic
            : textArabic // ignore: cast_nullable_to_non_nullable
                  as String,
        textTransliteration: freezed == textTransliteration
            ? _value.textTransliteration
            : textTransliteration // ignore: cast_nullable_to_non_nullable
                  as String?,
        textTranslation: freezed == textTranslation
            ? _value.textTranslation
            : textTranslation // ignore: cast_nullable_to_non_nullable
                  as String?,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        audioAsset: freezed == audioAsset
            ? _value.audioAsset
            : audioAsset // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AzkarItemModelImpl extends _AzkarItemModel {
  const _$AzkarItemModelImpl({
    required this.id,
    required this.categoryId,
    required this.textArabic,
    this.textTransliteration,
    this.textTranslation,
    required this.count,
    this.reference,
    required this.type,
    this.audioAsset,
  }) : super._();

  factory _$AzkarItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AzkarItemModelImplFromJson(json);

  @override
  final int id;
  @override
  final int categoryId;
  @override
  final String textArabic;
  @override
  final String? textTransliteration;
  @override
  final String? textTranslation;
  @override
  final int count;
  @override
  final String? reference;
  @override
  final String type;
  // AzkarType name
  @override
  final String? audioAsset;

  @override
  String toString() {
    return 'AzkarItemModel(id: $id, categoryId: $categoryId, textArabic: $textArabic, textTransliteration: $textTransliteration, textTranslation: $textTranslation, count: $count, reference: $reference, type: $type, audioAsset: $audioAsset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AzkarItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.textArabic, textArabic) ||
                other.textArabic == textArabic) &&
            (identical(other.textTransliteration, textTransliteration) ||
                other.textTransliteration == textTransliteration) &&
            (identical(other.textTranslation, textTranslation) ||
                other.textTranslation == textTranslation) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.audioAsset, audioAsset) ||
                other.audioAsset == audioAsset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    textArabic,
    textTransliteration,
    textTranslation,
    count,
    reference,
    type,
    audioAsset,
  );

  /// Create a copy of AzkarItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AzkarItemModelImplCopyWith<_$AzkarItemModelImpl> get copyWith =>
      __$$AzkarItemModelImplCopyWithImpl<_$AzkarItemModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AzkarItemModelImplToJson(this);
  }
}

abstract class _AzkarItemModel extends AzkarItemModel {
  const factory _AzkarItemModel({
    required final int id,
    required final int categoryId,
    required final String textArabic,
    final String? textTransliteration,
    final String? textTranslation,
    required final int count,
    final String? reference,
    required final String type,
    final String? audioAsset,
  }) = _$AzkarItemModelImpl;
  const _AzkarItemModel._() : super._();

  factory _AzkarItemModel.fromJson(Map<String, dynamic> json) =
      _$AzkarItemModelImpl.fromJson;

  @override
  int get id;
  @override
  int get categoryId;
  @override
  String get textArabic;
  @override
  String? get textTransliteration;
  @override
  String? get textTranslation;
  @override
  int get count;
  @override
  String? get reference;
  @override
  String get type; // AzkarType name
  @override
  String? get audioAsset;

  /// Create a copy of AzkarItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AzkarItemModelImplCopyWith<_$AzkarItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
