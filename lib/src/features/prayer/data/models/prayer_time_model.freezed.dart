// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_time_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrayerTimeModel _$PrayerTimeModelFromJson(Map<String, dynamic> json) {
  return _PrayerTimeModel.fromJson(json);
}

/// @nodoc
mixin _$PrayerTimeModel {
  String get name => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError; // ISO 8601 string
  String get type => throw _privateConstructorUsedError; // PrayerType name
  bool get isCurrent => throw _privateConstructorUsedError;

  /// Serializes this PrayerTimeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrayerTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrayerTimeModelCopyWith<PrayerTimeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerTimeModelCopyWith<$Res> {
  factory $PrayerTimeModelCopyWith(
    PrayerTimeModel value,
    $Res Function(PrayerTimeModel) then,
  ) = _$PrayerTimeModelCopyWithImpl<$Res, PrayerTimeModel>;
  @useResult
  $Res call({String name, String time, String type, bool isCurrent});
}

/// @nodoc
class _$PrayerTimeModelCopyWithImpl<$Res, $Val extends PrayerTimeModel>
    implements $PrayerTimeModelCopyWith<$Res> {
  _$PrayerTimeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrayerTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? time = null,
    Object? type = null,
    Object? isCurrent = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            isCurrent: null == isCurrent
                ? _value.isCurrent
                : isCurrent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrayerTimeModelImplCopyWith<$Res>
    implements $PrayerTimeModelCopyWith<$Res> {
  factory _$$PrayerTimeModelImplCopyWith(
    _$PrayerTimeModelImpl value,
    $Res Function(_$PrayerTimeModelImpl) then,
  ) = __$$PrayerTimeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String time, String type, bool isCurrent});
}

/// @nodoc
class __$$PrayerTimeModelImplCopyWithImpl<$Res>
    extends _$PrayerTimeModelCopyWithImpl<$Res, _$PrayerTimeModelImpl>
    implements _$$PrayerTimeModelImplCopyWith<$Res> {
  __$$PrayerTimeModelImplCopyWithImpl(
    _$PrayerTimeModelImpl _value,
    $Res Function(_$PrayerTimeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrayerTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? time = null,
    Object? type = null,
    Object? isCurrent = null,
  }) {
    return _then(
      _$PrayerTimeModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        isCurrent: null == isCurrent
            ? _value.isCurrent
            : isCurrent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrayerTimeModelImpl extends _PrayerTimeModel {
  const _$PrayerTimeModelImpl({
    required this.name,
    required this.time,
    required this.type,
    this.isCurrent = false,
  }) : super._();

  factory _$PrayerTimeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrayerTimeModelImplFromJson(json);

  @override
  final String name;
  @override
  final String time;
  // ISO 8601 string
  @override
  final String type;
  // PrayerType name
  @override
  @JsonKey()
  final bool isCurrent;

  @override
  String toString() {
    return 'PrayerTimeModel(name: $name, time: $time, type: $type, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayerTimeModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, time, type, isCurrent);

  /// Create a copy of PrayerTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayerTimeModelImplCopyWith<_$PrayerTimeModelImpl> get copyWith =>
      __$$PrayerTimeModelImplCopyWithImpl<_$PrayerTimeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrayerTimeModelImplToJson(this);
  }
}

abstract class _PrayerTimeModel extends PrayerTimeModel {
  const factory _PrayerTimeModel({
    required final String name,
    required final String time,
    required final String type,
    final bool isCurrent,
  }) = _$PrayerTimeModelImpl;
  const _PrayerTimeModel._() : super._();

  factory _PrayerTimeModel.fromJson(Map<String, dynamic> json) =
      _$PrayerTimeModelImpl.fromJson;

  @override
  String get name;
  @override
  String get time; // ISO 8601 string
  @override
  String get type; // PrayerType name
  @override
  bool get isCurrent;

  /// Create a copy of PrayerTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayerTimeModelImplCopyWith<_$PrayerTimeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPrayerScheduleModel _$DailyPrayerScheduleModelFromJson(
  Map<String, dynamic> json,
) {
  return _DailyPrayerScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$DailyPrayerScheduleModel {
  String get date => throw _privateConstructorUsedError; // ISO 8601
  String get hijriDate => throw _privateConstructorUsedError;
  String get hijriMonth => throw _privateConstructorUsedError;
  int get hijriYear => throw _privateConstructorUsedError;
  List<PrayerTimeModel> get prayers => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get calculationMethod => throw _privateConstructorUsedError;

  /// Serializes this DailyPrayerScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPrayerScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPrayerScheduleModelCopyWith<DailyPrayerScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPrayerScheduleModelCopyWith<$Res> {
  factory $DailyPrayerScheduleModelCopyWith(
    DailyPrayerScheduleModel value,
    $Res Function(DailyPrayerScheduleModel) then,
  ) = _$DailyPrayerScheduleModelCopyWithImpl<$Res, DailyPrayerScheduleModel>;
  @useResult
  $Res call({
    String date,
    String hijriDate,
    String hijriMonth,
    int hijriYear,
    List<PrayerTimeModel> prayers,
    String location,
    double latitude,
    double longitude,
    String calculationMethod,
  });
}

/// @nodoc
class _$DailyPrayerScheduleModelCopyWithImpl<
  $Res,
  $Val extends DailyPrayerScheduleModel
>
    implements $DailyPrayerScheduleModelCopyWith<$Res> {
  _$DailyPrayerScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPrayerScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? hijriDate = null,
    Object? hijriMonth = null,
    Object? hijriYear = null,
    Object? prayers = null,
    Object? location = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? calculationMethod = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            hijriDate: null == hijriDate
                ? _value.hijriDate
                : hijriDate // ignore: cast_nullable_to_non_nullable
                      as String,
            hijriMonth: null == hijriMonth
                ? _value.hijriMonth
                : hijriMonth // ignore: cast_nullable_to_non_nullable
                      as String,
            hijriYear: null == hijriYear
                ? _value.hijriYear
                : hijriYear // ignore: cast_nullable_to_non_nullable
                      as int,
            prayers: null == prayers
                ? _value.prayers
                : prayers // ignore: cast_nullable_to_non_nullable
                      as List<PrayerTimeModel>,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            calculationMethod: null == calculationMethod
                ? _value.calculationMethod
                : calculationMethod // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPrayerScheduleModelImplCopyWith<$Res>
    implements $DailyPrayerScheduleModelCopyWith<$Res> {
  factory _$$DailyPrayerScheduleModelImplCopyWith(
    _$DailyPrayerScheduleModelImpl value,
    $Res Function(_$DailyPrayerScheduleModelImpl) then,
  ) = __$$DailyPrayerScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    String hijriDate,
    String hijriMonth,
    int hijriYear,
    List<PrayerTimeModel> prayers,
    String location,
    double latitude,
    double longitude,
    String calculationMethod,
  });
}

/// @nodoc
class __$$DailyPrayerScheduleModelImplCopyWithImpl<$Res>
    extends
        _$DailyPrayerScheduleModelCopyWithImpl<
          $Res,
          _$DailyPrayerScheduleModelImpl
        >
    implements _$$DailyPrayerScheduleModelImplCopyWith<$Res> {
  __$$DailyPrayerScheduleModelImplCopyWithImpl(
    _$DailyPrayerScheduleModelImpl _value,
    $Res Function(_$DailyPrayerScheduleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPrayerScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? hijriDate = null,
    Object? hijriMonth = null,
    Object? hijriYear = null,
    Object? prayers = null,
    Object? location = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? calculationMethod = null,
  }) {
    return _then(
      _$DailyPrayerScheduleModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        hijriDate: null == hijriDate
            ? _value.hijriDate
            : hijriDate // ignore: cast_nullable_to_non_nullable
                  as String,
        hijriMonth: null == hijriMonth
            ? _value.hijriMonth
            : hijriMonth // ignore: cast_nullable_to_non_nullable
                  as String,
        hijriYear: null == hijriYear
            ? _value.hijriYear
            : hijriYear // ignore: cast_nullable_to_non_nullable
                  as int,
        prayers: null == prayers
            ? _value._prayers
            : prayers // ignore: cast_nullable_to_non_nullable
                  as List<PrayerTimeModel>,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        calculationMethod: null == calculationMethod
            ? _value.calculationMethod
            : calculationMethod // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPrayerScheduleModelImpl extends _DailyPrayerScheduleModel {
  const _$DailyPrayerScheduleModelImpl({
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required final List<PrayerTimeModel> prayers,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.calculationMethod,
  }) : _prayers = prayers,
       super._();

  factory _$DailyPrayerScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPrayerScheduleModelImplFromJson(json);

  @override
  final String date;
  // ISO 8601
  @override
  final String hijriDate;
  @override
  final String hijriMonth;
  @override
  final int hijriYear;
  final List<PrayerTimeModel> _prayers;
  @override
  List<PrayerTimeModel> get prayers {
    if (_prayers is EqualUnmodifiableListView) return _prayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prayers);
  }

  @override
  final String location;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String calculationMethod;

  @override
  String toString() {
    return 'DailyPrayerScheduleModel(date: $date, hijriDate: $hijriDate, hijriMonth: $hijriMonth, hijriYear: $hijriYear, prayers: $prayers, location: $location, latitude: $latitude, longitude: $longitude, calculationMethod: $calculationMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPrayerScheduleModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.hijriDate, hijriDate) ||
                other.hijriDate == hijriDate) &&
            (identical(other.hijriMonth, hijriMonth) ||
                other.hijriMonth == hijriMonth) &&
            (identical(other.hijriYear, hijriYear) ||
                other.hijriYear == hijriYear) &&
            const DeepCollectionEquality().equals(other._prayers, _prayers) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.calculationMethod, calculationMethod) ||
                other.calculationMethod == calculationMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    hijriDate,
    hijriMonth,
    hijriYear,
    const DeepCollectionEquality().hash(_prayers),
    location,
    latitude,
    longitude,
    calculationMethod,
  );

  /// Create a copy of DailyPrayerScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPrayerScheduleModelImplCopyWith<_$DailyPrayerScheduleModelImpl>
  get copyWith =>
      __$$DailyPrayerScheduleModelImplCopyWithImpl<
        _$DailyPrayerScheduleModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPrayerScheduleModelImplToJson(this);
  }
}

abstract class _DailyPrayerScheduleModel extends DailyPrayerScheduleModel {
  const factory _DailyPrayerScheduleModel({
    required final String date,
    required final String hijriDate,
    required final String hijriMonth,
    required final int hijriYear,
    required final List<PrayerTimeModel> prayers,
    required final String location,
    required final double latitude,
    required final double longitude,
    required final String calculationMethod,
  }) = _$DailyPrayerScheduleModelImpl;
  const _DailyPrayerScheduleModel._() : super._();

  factory _DailyPrayerScheduleModel.fromJson(Map<String, dynamic> json) =
      _$DailyPrayerScheduleModelImpl.fromJson;

  @override
  String get date; // ISO 8601
  @override
  String get hijriDate;
  @override
  String get hijriMonth;
  @override
  int get hijriYear;
  @override
  List<PrayerTimeModel> get prayers;
  @override
  String get location;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get calculationMethod;

  /// Create a copy of DailyPrayerScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPrayerScheduleModelImplCopyWith<_$DailyPrayerScheduleModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
