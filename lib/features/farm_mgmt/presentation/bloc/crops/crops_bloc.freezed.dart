// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crops_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CropsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(CropEntity crop) add,
    required TResult Function(CropEntity crop) update,
    required TResult Function(String id) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(CropEntity crop)? add,
    TResult? Function(CropEntity crop)? update,
    TResult? Function(String id)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(CropEntity crop)? add,
    TResult Function(CropEntity crop)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadCrops value) load,
    required TResult Function(AddCropEvent value) add,
    required TResult Function(UpdateCropEvent value) update,
    required TResult Function(DeleteCropEvent value) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadCrops value)? load,
    TResult? Function(AddCropEvent value)? add,
    TResult? Function(UpdateCropEvent value)? update,
    TResult? Function(DeleteCropEvent value)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadCrops value)? load,
    TResult Function(AddCropEvent value)? add,
    TResult Function(UpdateCropEvent value)? update,
    TResult Function(DeleteCropEvent value)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CropsEventCopyWith<$Res> {
  factory $CropsEventCopyWith(
          CropsEvent value, $Res Function(CropsEvent) then) =
      _$CropsEventCopyWithImpl<$Res, CropsEvent>;
}

/// @nodoc
class _$CropsEventCopyWithImpl<$Res, $Val extends CropsEvent>
    implements $CropsEventCopyWith<$Res> {
  _$CropsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadCropsImplCopyWith<$Res> {
  factory _$$LoadCropsImplCopyWith(
          _$LoadCropsImpl value, $Res Function(_$LoadCropsImpl) then) =
      __$$LoadCropsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadCropsImplCopyWithImpl<$Res>
    extends _$CropsEventCopyWithImpl<$Res, _$LoadCropsImpl>
    implements _$$LoadCropsImplCopyWith<$Res> {
  __$$LoadCropsImplCopyWithImpl(
      _$LoadCropsImpl _value, $Res Function(_$LoadCropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadCropsImpl implements LoadCrops {
  const _$LoadCropsImpl();

  @override
  String toString() {
    return 'CropsEvent.load()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadCropsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(CropEntity crop) add,
    required TResult Function(CropEntity crop) update,
    required TResult Function(String id) delete,
  }) {
    return load();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(CropEntity crop)? add,
    TResult? Function(CropEntity crop)? update,
    TResult? Function(String id)? delete,
  }) {
    return load?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(CropEntity crop)? add,
    TResult Function(CropEntity crop)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadCrops value) load,
    required TResult Function(AddCropEvent value) add,
    required TResult Function(UpdateCropEvent value) update,
    required TResult Function(DeleteCropEvent value) delete,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadCrops value)? load,
    TResult? Function(AddCropEvent value)? add,
    TResult? Function(UpdateCropEvent value)? update,
    TResult? Function(DeleteCropEvent value)? delete,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadCrops value)? load,
    TResult Function(AddCropEvent value)? add,
    TResult Function(UpdateCropEvent value)? update,
    TResult Function(DeleteCropEvent value)? delete,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class LoadCrops implements CropsEvent {
  const factory LoadCrops() = _$LoadCropsImpl;
}

/// @nodoc
abstract class _$$AddCropEventImplCopyWith<$Res> {
  factory _$$AddCropEventImplCopyWith(
          _$AddCropEventImpl value, $Res Function(_$AddCropEventImpl) then) =
      __$$AddCropEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CropEntity crop});
}

/// @nodoc
class __$$AddCropEventImplCopyWithImpl<$Res>
    extends _$CropsEventCopyWithImpl<$Res, _$AddCropEventImpl>
    implements _$$AddCropEventImplCopyWith<$Res> {
  __$$AddCropEventImplCopyWithImpl(
      _$AddCropEventImpl _value, $Res Function(_$AddCropEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crop = null,
  }) {
    return _then(_$AddCropEventImpl(
      crop: null == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as CropEntity,
    ));
  }
}

/// @nodoc

class _$AddCropEventImpl implements AddCropEvent {
  const _$AddCropEventImpl({required this.crop});

  @override
  final CropEntity crop;

  @override
  String toString() {
    return 'CropsEvent.add(crop: $crop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCropEventImpl &&
            (identical(other.crop, crop) || other.crop == crop));
  }

  @override
  int get hashCode => Object.hash(runtimeType, crop);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCropEventImplCopyWith<_$AddCropEventImpl> get copyWith =>
      __$$AddCropEventImplCopyWithImpl<_$AddCropEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(CropEntity crop) add,
    required TResult Function(CropEntity crop) update,
    required TResult Function(String id) delete,
  }) {
    return add(crop);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(CropEntity crop)? add,
    TResult? Function(CropEntity crop)? update,
    TResult? Function(String id)? delete,
  }) {
    return add?.call(crop);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(CropEntity crop)? add,
    TResult Function(CropEntity crop)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(crop);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadCrops value) load,
    required TResult Function(AddCropEvent value) add,
    required TResult Function(UpdateCropEvent value) update,
    required TResult Function(DeleteCropEvent value) delete,
  }) {
    return add(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadCrops value)? load,
    TResult? Function(AddCropEvent value)? add,
    TResult? Function(UpdateCropEvent value)? update,
    TResult? Function(DeleteCropEvent value)? delete,
  }) {
    return add?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadCrops value)? load,
    TResult Function(AddCropEvent value)? add,
    TResult Function(UpdateCropEvent value)? update,
    TResult Function(DeleteCropEvent value)? delete,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class AddCropEvent implements CropsEvent {
  const factory AddCropEvent({required final CropEntity crop}) =
      _$AddCropEventImpl;

  CropEntity get crop;

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddCropEventImplCopyWith<_$AddCropEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateCropEventImplCopyWith<$Res> {
  factory _$$UpdateCropEventImplCopyWith(_$UpdateCropEventImpl value,
          $Res Function(_$UpdateCropEventImpl) then) =
      __$$UpdateCropEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CropEntity crop});
}

/// @nodoc
class __$$UpdateCropEventImplCopyWithImpl<$Res>
    extends _$CropsEventCopyWithImpl<$Res, _$UpdateCropEventImpl>
    implements _$$UpdateCropEventImplCopyWith<$Res> {
  __$$UpdateCropEventImplCopyWithImpl(
      _$UpdateCropEventImpl _value, $Res Function(_$UpdateCropEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crop = null,
  }) {
    return _then(_$UpdateCropEventImpl(
      crop: null == crop
          ? _value.crop
          : crop // ignore: cast_nullable_to_non_nullable
              as CropEntity,
    ));
  }
}

/// @nodoc

class _$UpdateCropEventImpl implements UpdateCropEvent {
  const _$UpdateCropEventImpl({required this.crop});

  @override
  final CropEntity crop;

  @override
  String toString() {
    return 'CropsEvent.update(crop: $crop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateCropEventImpl &&
            (identical(other.crop, crop) || other.crop == crop));
  }

  @override
  int get hashCode => Object.hash(runtimeType, crop);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateCropEventImplCopyWith<_$UpdateCropEventImpl> get copyWith =>
      __$$UpdateCropEventImplCopyWithImpl<_$UpdateCropEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(CropEntity crop) add,
    required TResult Function(CropEntity crop) update,
    required TResult Function(String id) delete,
  }) {
    return update(crop);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(CropEntity crop)? add,
    TResult? Function(CropEntity crop)? update,
    TResult? Function(String id)? delete,
  }) {
    return update?.call(crop);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(CropEntity crop)? add,
    TResult Function(CropEntity crop)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(crop);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadCrops value) load,
    required TResult Function(AddCropEvent value) add,
    required TResult Function(UpdateCropEvent value) update,
    required TResult Function(DeleteCropEvent value) delete,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadCrops value)? load,
    TResult? Function(AddCropEvent value)? add,
    TResult? Function(UpdateCropEvent value)? update,
    TResult? Function(DeleteCropEvent value)? delete,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadCrops value)? load,
    TResult Function(AddCropEvent value)? add,
    TResult Function(UpdateCropEvent value)? update,
    TResult Function(DeleteCropEvent value)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class UpdateCropEvent implements CropsEvent {
  const factory UpdateCropEvent({required final CropEntity crop}) =
      _$UpdateCropEventImpl;

  CropEntity get crop;

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateCropEventImplCopyWith<_$UpdateCropEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteCropEventImplCopyWith<$Res> {
  factory _$$DeleteCropEventImplCopyWith(_$DeleteCropEventImpl value,
          $Res Function(_$DeleteCropEventImpl) then) =
      __$$DeleteCropEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteCropEventImplCopyWithImpl<$Res>
    extends _$CropsEventCopyWithImpl<$Res, _$DeleteCropEventImpl>
    implements _$$DeleteCropEventImplCopyWith<$Res> {
  __$$DeleteCropEventImplCopyWithImpl(
      _$DeleteCropEventImpl _value, $Res Function(_$DeleteCropEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteCropEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteCropEventImpl implements DeleteCropEvent {
  const _$DeleteCropEventImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'CropsEvent.delete(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteCropEventImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteCropEventImplCopyWith<_$DeleteCropEventImpl> get copyWith =>
      __$$DeleteCropEventImplCopyWithImpl<_$DeleteCropEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(CropEntity crop) add,
    required TResult Function(CropEntity crop) update,
    required TResult Function(String id) delete,
  }) {
    return delete(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(CropEntity crop)? add,
    TResult? Function(CropEntity crop)? update,
    TResult? Function(String id)? delete,
  }) {
    return delete?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(CropEntity crop)? add,
    TResult Function(CropEntity crop)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadCrops value) load,
    required TResult Function(AddCropEvent value) add,
    required TResult Function(UpdateCropEvent value) update,
    required TResult Function(DeleteCropEvent value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadCrops value)? load,
    TResult? Function(AddCropEvent value)? add,
    TResult? Function(UpdateCropEvent value)? update,
    TResult? Function(DeleteCropEvent value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadCrops value)? load,
    TResult Function(AddCropEvent value)? add,
    TResult Function(UpdateCropEvent value)? update,
    TResult Function(DeleteCropEvent value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class DeleteCropEvent implements CropsEvent {
  const factory DeleteCropEvent({required final String id}) =
      _$DeleteCropEventImpl;

  String get id;

  /// Create a copy of CropsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteCropEventImplCopyWith<_$DeleteCropEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CropsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<CropEntity> crops) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<CropEntity> crops)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<CropEntity> crops)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CropsInitial value) initial,
    required TResult Function(CropsLoading value) loading,
    required TResult Function(CropsLoaded value) loaded,
    required TResult Function(CropsError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CropsInitial value)? initial,
    TResult? Function(CropsLoading value)? loading,
    TResult? Function(CropsLoaded value)? loaded,
    TResult? Function(CropsError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CropsInitial value)? initial,
    TResult Function(CropsLoading value)? loading,
    TResult Function(CropsLoaded value)? loaded,
    TResult Function(CropsError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CropsStateCopyWith<$Res> {
  factory $CropsStateCopyWith(
          CropsState value, $Res Function(CropsState) then) =
      _$CropsStateCopyWithImpl<$Res, CropsState>;
}

/// @nodoc
class _$CropsStateCopyWithImpl<$Res, $Val extends CropsState>
    implements $CropsStateCopyWith<$Res> {
  _$CropsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CropsInitialImplCopyWith<$Res> {
  factory _$$CropsInitialImplCopyWith(
          _$CropsInitialImpl value, $Res Function(_$CropsInitialImpl) then) =
      __$$CropsInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CropsInitialImplCopyWithImpl<$Res>
    extends _$CropsStateCopyWithImpl<$Res, _$CropsInitialImpl>
    implements _$$CropsInitialImplCopyWith<$Res> {
  __$$CropsInitialImplCopyWithImpl(
      _$CropsInitialImpl _value, $Res Function(_$CropsInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CropsInitialImpl implements CropsInitial {
  const _$CropsInitialImpl();

  @override
  String toString() {
    return 'CropsState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CropsInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<CropEntity> crops) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<CropEntity> crops)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<CropEntity> crops)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CropsInitial value) initial,
    required TResult Function(CropsLoading value) loading,
    required TResult Function(CropsLoaded value) loaded,
    required TResult Function(CropsError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CropsInitial value)? initial,
    TResult? Function(CropsLoading value)? loading,
    TResult? Function(CropsLoaded value)? loaded,
    TResult? Function(CropsError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CropsInitial value)? initial,
    TResult Function(CropsLoading value)? loading,
    TResult Function(CropsLoaded value)? loaded,
    TResult Function(CropsError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class CropsInitial implements CropsState {
  const factory CropsInitial() = _$CropsInitialImpl;
}

/// @nodoc
abstract class _$$CropsLoadingImplCopyWith<$Res> {
  factory _$$CropsLoadingImplCopyWith(
          _$CropsLoadingImpl value, $Res Function(_$CropsLoadingImpl) then) =
      __$$CropsLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CropsLoadingImplCopyWithImpl<$Res>
    extends _$CropsStateCopyWithImpl<$Res, _$CropsLoadingImpl>
    implements _$$CropsLoadingImplCopyWith<$Res> {
  __$$CropsLoadingImplCopyWithImpl(
      _$CropsLoadingImpl _value, $Res Function(_$CropsLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CropsLoadingImpl implements CropsLoading {
  const _$CropsLoadingImpl();

  @override
  String toString() {
    return 'CropsState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CropsLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<CropEntity> crops) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<CropEntity> crops)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<CropEntity> crops)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CropsInitial value) initial,
    required TResult Function(CropsLoading value) loading,
    required TResult Function(CropsLoaded value) loaded,
    required TResult Function(CropsError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CropsInitial value)? initial,
    TResult? Function(CropsLoading value)? loading,
    TResult? Function(CropsLoaded value)? loaded,
    TResult? Function(CropsError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CropsInitial value)? initial,
    TResult Function(CropsLoading value)? loading,
    TResult Function(CropsLoaded value)? loaded,
    TResult Function(CropsError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class CropsLoading implements CropsState {
  const factory CropsLoading() = _$CropsLoadingImpl;
}

/// @nodoc
abstract class _$$CropsLoadedImplCopyWith<$Res> {
  factory _$$CropsLoadedImplCopyWith(
          _$CropsLoadedImpl value, $Res Function(_$CropsLoadedImpl) then) =
      __$$CropsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<CropEntity> crops});
}

/// @nodoc
class __$$CropsLoadedImplCopyWithImpl<$Res>
    extends _$CropsStateCopyWithImpl<$Res, _$CropsLoadedImpl>
    implements _$$CropsLoadedImplCopyWith<$Res> {
  __$$CropsLoadedImplCopyWithImpl(
      _$CropsLoadedImpl _value, $Res Function(_$CropsLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crops = null,
  }) {
    return _then(_$CropsLoadedImpl(
      crops: null == crops
          ? _value._crops
          : crops // ignore: cast_nullable_to_non_nullable
              as List<CropEntity>,
    ));
  }
}

/// @nodoc

class _$CropsLoadedImpl implements CropsLoaded {
  const _$CropsLoadedImpl({required final List<CropEntity> crops})
      : _crops = crops;

  final List<CropEntity> _crops;
  @override
  List<CropEntity> get crops {
    if (_crops is EqualUnmodifiableListView) return _crops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crops);
  }

  @override
  String toString() {
    return 'CropsState.loaded(crops: $crops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CropsLoadedImpl &&
            const DeepCollectionEquality().equals(other._crops, _crops));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_crops));

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CropsLoadedImplCopyWith<_$CropsLoadedImpl> get copyWith =>
      __$$CropsLoadedImplCopyWithImpl<_$CropsLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<CropEntity> crops) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(crops);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<CropEntity> crops)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(crops);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<CropEntity> crops)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(crops);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CropsInitial value) initial,
    required TResult Function(CropsLoading value) loading,
    required TResult Function(CropsLoaded value) loaded,
    required TResult Function(CropsError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CropsInitial value)? initial,
    TResult? Function(CropsLoading value)? loading,
    TResult? Function(CropsLoaded value)? loaded,
    TResult? Function(CropsError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CropsInitial value)? initial,
    TResult Function(CropsLoading value)? loading,
    TResult Function(CropsLoaded value)? loaded,
    TResult Function(CropsError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class CropsLoaded implements CropsState {
  const factory CropsLoaded({required final List<CropEntity> crops}) =
      _$CropsLoadedImpl;

  List<CropEntity> get crops;

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CropsLoadedImplCopyWith<_$CropsLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CropsErrorImplCopyWith<$Res> {
  factory _$$CropsErrorImplCopyWith(
          _$CropsErrorImpl value, $Res Function(_$CropsErrorImpl) then) =
      __$$CropsErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$CropsErrorImplCopyWithImpl<$Res>
    extends _$CropsStateCopyWithImpl<$Res, _$CropsErrorImpl>
    implements _$$CropsErrorImplCopyWith<$Res> {
  __$$CropsErrorImplCopyWithImpl(
      _$CropsErrorImpl _value, $Res Function(_$CropsErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$CropsErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CropsErrorImpl implements CropsError {
  const _$CropsErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'CropsState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CropsErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CropsErrorImplCopyWith<_$CropsErrorImpl> get copyWith =>
      __$$CropsErrorImplCopyWithImpl<_$CropsErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<CropEntity> crops) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<CropEntity> crops)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<CropEntity> crops)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CropsInitial value) initial,
    required TResult Function(CropsLoading value) loading,
    required TResult Function(CropsLoaded value) loaded,
    required TResult Function(CropsError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CropsInitial value)? initial,
    TResult? Function(CropsLoading value)? loading,
    TResult? Function(CropsLoaded value)? loaded,
    TResult? Function(CropsError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CropsInitial value)? initial,
    TResult Function(CropsLoading value)? loading,
    TResult Function(CropsLoaded value)? loaded,
    TResult Function(CropsError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class CropsError implements CropsState {
  const factory CropsError({required final String message}) = _$CropsErrorImpl;

  String get message;

  /// Create a copy of CropsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CropsErrorImplCopyWith<_$CropsErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
