// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animals_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AnimalsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(AnimalEntity animal) add,
    required TResult Function(AnimalEntity animal) update,
    required TResult Function(String id) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(AnimalEntity animal)? add,
    TResult? Function(AnimalEntity animal)? update,
    TResult? Function(String id)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(AnimalEntity animal)? add,
    TResult Function(AnimalEntity animal)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadAnimals value) load,
    required TResult Function(AddAnimalEvent value) add,
    required TResult Function(UpdateAnimalEvent value) update,
    required TResult Function(DeleteAnimalEvent value) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadAnimals value)? load,
    TResult? Function(AddAnimalEvent value)? add,
    TResult? Function(UpdateAnimalEvent value)? update,
    TResult? Function(DeleteAnimalEvent value)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadAnimals value)? load,
    TResult Function(AddAnimalEvent value)? add,
    TResult Function(UpdateAnimalEvent value)? update,
    TResult Function(DeleteAnimalEvent value)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimalsEventCopyWith<$Res> {
  factory $AnimalsEventCopyWith(
          AnimalsEvent value, $Res Function(AnimalsEvent) then) =
      _$AnimalsEventCopyWithImpl<$Res, AnimalsEvent>;
}

/// @nodoc
class _$AnimalsEventCopyWithImpl<$Res, $Val extends AnimalsEvent>
    implements $AnimalsEventCopyWith<$Res> {
  _$AnimalsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadAnimalsImplCopyWith<$Res> {
  factory _$$LoadAnimalsImplCopyWith(
          _$LoadAnimalsImpl value, $Res Function(_$LoadAnimalsImpl) then) =
      __$$LoadAnimalsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadAnimalsImplCopyWithImpl<$Res>
    extends _$AnimalsEventCopyWithImpl<$Res, _$LoadAnimalsImpl>
    implements _$$LoadAnimalsImplCopyWith<$Res> {
  __$$LoadAnimalsImplCopyWithImpl(
      _$LoadAnimalsImpl _value, $Res Function(_$LoadAnimalsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadAnimalsImpl implements LoadAnimals {
  const _$LoadAnimalsImpl();

  @override
  String toString() {
    return 'AnimalsEvent.load()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadAnimalsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(AnimalEntity animal) add,
    required TResult Function(AnimalEntity animal) update,
    required TResult Function(String id) delete,
  }) {
    return load();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(AnimalEntity animal)? add,
    TResult? Function(AnimalEntity animal)? update,
    TResult? Function(String id)? delete,
  }) {
    return load?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(AnimalEntity animal)? add,
    TResult Function(AnimalEntity animal)? update,
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
    required TResult Function(LoadAnimals value) load,
    required TResult Function(AddAnimalEvent value) add,
    required TResult Function(UpdateAnimalEvent value) update,
    required TResult Function(DeleteAnimalEvent value) delete,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadAnimals value)? load,
    TResult? Function(AddAnimalEvent value)? add,
    TResult? Function(UpdateAnimalEvent value)? update,
    TResult? Function(DeleteAnimalEvent value)? delete,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadAnimals value)? load,
    TResult Function(AddAnimalEvent value)? add,
    TResult Function(UpdateAnimalEvent value)? update,
    TResult Function(DeleteAnimalEvent value)? delete,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class LoadAnimals implements AnimalsEvent {
  const factory LoadAnimals() = _$LoadAnimalsImpl;
}

/// @nodoc
abstract class _$$AddAnimalEventImplCopyWith<$Res> {
  factory _$$AddAnimalEventImplCopyWith(_$AddAnimalEventImpl value,
          $Res Function(_$AddAnimalEventImpl) then) =
      __$$AddAnimalEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AnimalEntity animal});
}

/// @nodoc
class __$$AddAnimalEventImplCopyWithImpl<$Res>
    extends _$AnimalsEventCopyWithImpl<$Res, _$AddAnimalEventImpl>
    implements _$$AddAnimalEventImplCopyWith<$Res> {
  __$$AddAnimalEventImplCopyWithImpl(
      _$AddAnimalEventImpl _value, $Res Function(_$AddAnimalEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? animal = null,
  }) {
    return _then(_$AddAnimalEventImpl(
      animal: null == animal
          ? _value.animal
          : animal // ignore: cast_nullable_to_non_nullable
              as AnimalEntity,
    ));
  }
}

/// @nodoc

class _$AddAnimalEventImpl implements AddAnimalEvent {
  const _$AddAnimalEventImpl({required this.animal});

  @override
  final AnimalEntity animal;

  @override
  String toString() {
    return 'AnimalsEvent.add(animal: $animal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddAnimalEventImpl &&
            (identical(other.animal, animal) || other.animal == animal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, animal);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddAnimalEventImplCopyWith<_$AddAnimalEventImpl> get copyWith =>
      __$$AddAnimalEventImplCopyWithImpl<_$AddAnimalEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(AnimalEntity animal) add,
    required TResult Function(AnimalEntity animal) update,
    required TResult Function(String id) delete,
  }) {
    return add(animal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(AnimalEntity animal)? add,
    TResult? Function(AnimalEntity animal)? update,
    TResult? Function(String id)? delete,
  }) {
    return add?.call(animal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(AnimalEntity animal)? add,
    TResult Function(AnimalEntity animal)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(animal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadAnimals value) load,
    required TResult Function(AddAnimalEvent value) add,
    required TResult Function(UpdateAnimalEvent value) update,
    required TResult Function(DeleteAnimalEvent value) delete,
  }) {
    return add(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadAnimals value)? load,
    TResult? Function(AddAnimalEvent value)? add,
    TResult? Function(UpdateAnimalEvent value)? update,
    TResult? Function(DeleteAnimalEvent value)? delete,
  }) {
    return add?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadAnimals value)? load,
    TResult Function(AddAnimalEvent value)? add,
    TResult Function(UpdateAnimalEvent value)? update,
    TResult Function(DeleteAnimalEvent value)? delete,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class AddAnimalEvent implements AnimalsEvent {
  const factory AddAnimalEvent({required final AnimalEntity animal}) =
      _$AddAnimalEventImpl;

  AnimalEntity get animal;

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddAnimalEventImplCopyWith<_$AddAnimalEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateAnimalEventImplCopyWith<$Res> {
  factory _$$UpdateAnimalEventImplCopyWith(_$UpdateAnimalEventImpl value,
          $Res Function(_$UpdateAnimalEventImpl) then) =
      __$$UpdateAnimalEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AnimalEntity animal});
}

/// @nodoc
class __$$UpdateAnimalEventImplCopyWithImpl<$Res>
    extends _$AnimalsEventCopyWithImpl<$Res, _$UpdateAnimalEventImpl>
    implements _$$UpdateAnimalEventImplCopyWith<$Res> {
  __$$UpdateAnimalEventImplCopyWithImpl(_$UpdateAnimalEventImpl _value,
      $Res Function(_$UpdateAnimalEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? animal = null,
  }) {
    return _then(_$UpdateAnimalEventImpl(
      animal: null == animal
          ? _value.animal
          : animal // ignore: cast_nullable_to_non_nullable
              as AnimalEntity,
    ));
  }
}

/// @nodoc

class _$UpdateAnimalEventImpl implements UpdateAnimalEvent {
  const _$UpdateAnimalEventImpl({required this.animal});

  @override
  final AnimalEntity animal;

  @override
  String toString() {
    return 'AnimalsEvent.update(animal: $animal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAnimalEventImpl &&
            (identical(other.animal, animal) || other.animal == animal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, animal);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAnimalEventImplCopyWith<_$UpdateAnimalEventImpl> get copyWith =>
      __$$UpdateAnimalEventImplCopyWithImpl<_$UpdateAnimalEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(AnimalEntity animal) add,
    required TResult Function(AnimalEntity animal) update,
    required TResult Function(String id) delete,
  }) {
    return update(animal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(AnimalEntity animal)? add,
    TResult? Function(AnimalEntity animal)? update,
    TResult? Function(String id)? delete,
  }) {
    return update?.call(animal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(AnimalEntity animal)? add,
    TResult Function(AnimalEntity animal)? update,
    TResult Function(String id)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(animal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadAnimals value) load,
    required TResult Function(AddAnimalEvent value) add,
    required TResult Function(UpdateAnimalEvent value) update,
    required TResult Function(DeleteAnimalEvent value) delete,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadAnimals value)? load,
    TResult? Function(AddAnimalEvent value)? add,
    TResult? Function(UpdateAnimalEvent value)? update,
    TResult? Function(DeleteAnimalEvent value)? delete,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadAnimals value)? load,
    TResult Function(AddAnimalEvent value)? add,
    TResult Function(UpdateAnimalEvent value)? update,
    TResult Function(DeleteAnimalEvent value)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class UpdateAnimalEvent implements AnimalsEvent {
  const factory UpdateAnimalEvent({required final AnimalEntity animal}) =
      _$UpdateAnimalEventImpl;

  AnimalEntity get animal;

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAnimalEventImplCopyWith<_$UpdateAnimalEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteAnimalEventImplCopyWith<$Res> {
  factory _$$DeleteAnimalEventImplCopyWith(_$DeleteAnimalEventImpl value,
          $Res Function(_$DeleteAnimalEventImpl) then) =
      __$$DeleteAnimalEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteAnimalEventImplCopyWithImpl<$Res>
    extends _$AnimalsEventCopyWithImpl<$Res, _$DeleteAnimalEventImpl>
    implements _$$DeleteAnimalEventImplCopyWith<$Res> {
  __$$DeleteAnimalEventImplCopyWithImpl(_$DeleteAnimalEventImpl _value,
      $Res Function(_$DeleteAnimalEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteAnimalEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteAnimalEventImpl implements DeleteAnimalEvent {
  const _$DeleteAnimalEventImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'AnimalsEvent.delete(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteAnimalEventImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteAnimalEventImplCopyWith<_$DeleteAnimalEventImpl> get copyWith =>
      __$$DeleteAnimalEventImplCopyWithImpl<_$DeleteAnimalEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(AnimalEntity animal) add,
    required TResult Function(AnimalEntity animal) update,
    required TResult Function(String id) delete,
  }) {
    return delete(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(AnimalEntity animal)? add,
    TResult? Function(AnimalEntity animal)? update,
    TResult? Function(String id)? delete,
  }) {
    return delete?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(AnimalEntity animal)? add,
    TResult Function(AnimalEntity animal)? update,
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
    required TResult Function(LoadAnimals value) load,
    required TResult Function(AddAnimalEvent value) add,
    required TResult Function(UpdateAnimalEvent value) update,
    required TResult Function(DeleteAnimalEvent value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadAnimals value)? load,
    TResult? Function(AddAnimalEvent value)? add,
    TResult? Function(UpdateAnimalEvent value)? update,
    TResult? Function(DeleteAnimalEvent value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadAnimals value)? load,
    TResult Function(AddAnimalEvent value)? add,
    TResult Function(UpdateAnimalEvent value)? update,
    TResult Function(DeleteAnimalEvent value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class DeleteAnimalEvent implements AnimalsEvent {
  const factory DeleteAnimalEvent({required final String id}) =
      _$DeleteAnimalEventImpl;

  String get id;

  /// Create a copy of AnimalsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteAnimalEventImplCopyWith<_$DeleteAnimalEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnimalsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AnimalEntity> animals) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AnimalEntity> animals)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AnimalEntity> animals)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AnimalsInitial value) initial,
    required TResult Function(AnimalsLoading value) loading,
    required TResult Function(AnimalsLoaded value) loaded,
    required TResult Function(AnimalsError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnimalsInitial value)? initial,
    TResult? Function(AnimalsLoading value)? loading,
    TResult? Function(AnimalsLoaded value)? loaded,
    TResult? Function(AnimalsError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnimalsInitial value)? initial,
    TResult Function(AnimalsLoading value)? loading,
    TResult Function(AnimalsLoaded value)? loaded,
    TResult Function(AnimalsError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimalsStateCopyWith<$Res> {
  factory $AnimalsStateCopyWith(
          AnimalsState value, $Res Function(AnimalsState) then) =
      _$AnimalsStateCopyWithImpl<$Res, AnimalsState>;
}

/// @nodoc
class _$AnimalsStateCopyWithImpl<$Res, $Val extends AnimalsState>
    implements $AnimalsStateCopyWith<$Res> {
  _$AnimalsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AnimalsInitialImplCopyWith<$Res> {
  factory _$$AnimalsInitialImplCopyWith(_$AnimalsInitialImpl value,
          $Res Function(_$AnimalsInitialImpl) then) =
      __$$AnimalsInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AnimalsInitialImplCopyWithImpl<$Res>
    extends _$AnimalsStateCopyWithImpl<$Res, _$AnimalsInitialImpl>
    implements _$$AnimalsInitialImplCopyWith<$Res> {
  __$$AnimalsInitialImplCopyWithImpl(
      _$AnimalsInitialImpl _value, $Res Function(_$AnimalsInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AnimalsInitialImpl implements AnimalsInitial {
  const _$AnimalsInitialImpl();

  @override
  String toString() {
    return 'AnimalsState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AnimalsInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AnimalEntity> animals) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AnimalEntity> animals)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AnimalEntity> animals)? loaded,
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
    required TResult Function(AnimalsInitial value) initial,
    required TResult Function(AnimalsLoading value) loading,
    required TResult Function(AnimalsLoaded value) loaded,
    required TResult Function(AnimalsError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnimalsInitial value)? initial,
    TResult? Function(AnimalsLoading value)? loading,
    TResult? Function(AnimalsLoaded value)? loaded,
    TResult? Function(AnimalsError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnimalsInitial value)? initial,
    TResult Function(AnimalsLoading value)? loading,
    TResult Function(AnimalsLoaded value)? loaded,
    TResult Function(AnimalsError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AnimalsInitial implements AnimalsState {
  const factory AnimalsInitial() = _$AnimalsInitialImpl;
}

/// @nodoc
abstract class _$$AnimalsLoadingImplCopyWith<$Res> {
  factory _$$AnimalsLoadingImplCopyWith(_$AnimalsLoadingImpl value,
          $Res Function(_$AnimalsLoadingImpl) then) =
      __$$AnimalsLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AnimalsLoadingImplCopyWithImpl<$Res>
    extends _$AnimalsStateCopyWithImpl<$Res, _$AnimalsLoadingImpl>
    implements _$$AnimalsLoadingImplCopyWith<$Res> {
  __$$AnimalsLoadingImplCopyWithImpl(
      _$AnimalsLoadingImpl _value, $Res Function(_$AnimalsLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AnimalsLoadingImpl implements AnimalsLoading {
  const _$AnimalsLoadingImpl();

  @override
  String toString() {
    return 'AnimalsState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AnimalsLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AnimalEntity> animals) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AnimalEntity> animals)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AnimalEntity> animals)? loaded,
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
    required TResult Function(AnimalsInitial value) initial,
    required TResult Function(AnimalsLoading value) loading,
    required TResult Function(AnimalsLoaded value) loaded,
    required TResult Function(AnimalsError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnimalsInitial value)? initial,
    TResult? Function(AnimalsLoading value)? loading,
    TResult? Function(AnimalsLoaded value)? loaded,
    TResult? Function(AnimalsError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnimalsInitial value)? initial,
    TResult Function(AnimalsLoading value)? loading,
    TResult Function(AnimalsLoaded value)? loaded,
    TResult Function(AnimalsError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AnimalsLoading implements AnimalsState {
  const factory AnimalsLoading() = _$AnimalsLoadingImpl;
}

/// @nodoc
abstract class _$$AnimalsLoadedImplCopyWith<$Res> {
  factory _$$AnimalsLoadedImplCopyWith(
          _$AnimalsLoadedImpl value, $Res Function(_$AnimalsLoadedImpl) then) =
      __$$AnimalsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<AnimalEntity> animals});
}

/// @nodoc
class __$$AnimalsLoadedImplCopyWithImpl<$Res>
    extends _$AnimalsStateCopyWithImpl<$Res, _$AnimalsLoadedImpl>
    implements _$$AnimalsLoadedImplCopyWith<$Res> {
  __$$AnimalsLoadedImplCopyWithImpl(
      _$AnimalsLoadedImpl _value, $Res Function(_$AnimalsLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? animals = null,
  }) {
    return _then(_$AnimalsLoadedImpl(
      animals: null == animals
          ? _value._animals
          : animals // ignore: cast_nullable_to_non_nullable
              as List<AnimalEntity>,
    ));
  }
}

/// @nodoc

class _$AnimalsLoadedImpl implements AnimalsLoaded {
  const _$AnimalsLoadedImpl({required final List<AnimalEntity> animals})
      : _animals = animals;

  final List<AnimalEntity> _animals;
  @override
  List<AnimalEntity> get animals {
    if (_animals is EqualUnmodifiableListView) return _animals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_animals);
  }

  @override
  String toString() {
    return 'AnimalsState.loaded(animals: $animals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimalsLoadedImpl &&
            const DeepCollectionEquality().equals(other._animals, _animals));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_animals));

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimalsLoadedImplCopyWith<_$AnimalsLoadedImpl> get copyWith =>
      __$$AnimalsLoadedImplCopyWithImpl<_$AnimalsLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AnimalEntity> animals) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(animals);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AnimalEntity> animals)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(animals);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AnimalEntity> animals)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(animals);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AnimalsInitial value) initial,
    required TResult Function(AnimalsLoading value) loading,
    required TResult Function(AnimalsLoaded value) loaded,
    required TResult Function(AnimalsError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnimalsInitial value)? initial,
    TResult? Function(AnimalsLoading value)? loading,
    TResult? Function(AnimalsLoaded value)? loaded,
    TResult? Function(AnimalsError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnimalsInitial value)? initial,
    TResult Function(AnimalsLoading value)? loading,
    TResult Function(AnimalsLoaded value)? loaded,
    TResult Function(AnimalsError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class AnimalsLoaded implements AnimalsState {
  const factory AnimalsLoaded({required final List<AnimalEntity> animals}) =
      _$AnimalsLoadedImpl;

  List<AnimalEntity> get animals;

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimalsLoadedImplCopyWith<_$AnimalsLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AnimalsErrorImplCopyWith<$Res> {
  factory _$$AnimalsErrorImplCopyWith(
          _$AnimalsErrorImpl value, $Res Function(_$AnimalsErrorImpl) then) =
      __$$AnimalsErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AnimalsErrorImplCopyWithImpl<$Res>
    extends _$AnimalsStateCopyWithImpl<$Res, _$AnimalsErrorImpl>
    implements _$$AnimalsErrorImplCopyWith<$Res> {
  __$$AnimalsErrorImplCopyWithImpl(
      _$AnimalsErrorImpl _value, $Res Function(_$AnimalsErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AnimalsErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AnimalsErrorImpl implements AnimalsError {
  const _$AnimalsErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AnimalsState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimalsErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimalsErrorImplCopyWith<_$AnimalsErrorImpl> get copyWith =>
      __$$AnimalsErrorImplCopyWithImpl<_$AnimalsErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AnimalEntity> animals) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AnimalEntity> animals)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AnimalEntity> animals)? loaded,
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
    required TResult Function(AnimalsInitial value) initial,
    required TResult Function(AnimalsLoading value) loading,
    required TResult Function(AnimalsLoaded value) loaded,
    required TResult Function(AnimalsError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnimalsInitial value)? initial,
    TResult? Function(AnimalsLoading value)? loading,
    TResult? Function(AnimalsLoaded value)? loaded,
    TResult? Function(AnimalsError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnimalsInitial value)? initial,
    TResult Function(AnimalsLoading value)? loading,
    TResult Function(AnimalsLoaded value)? loaded,
    TResult Function(AnimalsError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AnimalsError implements AnimalsState {
  const factory AnimalsError({required final String message}) =
      _$AnimalsErrorImpl;

  String get message;

  /// Create a copy of AnimalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimalsErrorImplCopyWith<_$AnimalsErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
