// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overview_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OverviewEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadOverview value) load,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadOverview value)? load,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadOverview value)? load,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OverviewEventCopyWith<$Res> {
  factory $OverviewEventCopyWith(
          OverviewEvent value, $Res Function(OverviewEvent) then) =
      _$OverviewEventCopyWithImpl<$Res, OverviewEvent>;
}

/// @nodoc
class _$OverviewEventCopyWithImpl<$Res, $Val extends OverviewEvent>
    implements $OverviewEventCopyWith<$Res> {
  _$OverviewEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OverviewEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadOverviewImplCopyWith<$Res> {
  factory _$$LoadOverviewImplCopyWith(
          _$LoadOverviewImpl value, $Res Function(_$LoadOverviewImpl) then) =
      __$$LoadOverviewImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadOverviewImplCopyWithImpl<$Res>
    extends _$OverviewEventCopyWithImpl<$Res, _$LoadOverviewImpl>
    implements _$$LoadOverviewImplCopyWith<$Res> {
  __$$LoadOverviewImplCopyWithImpl(
      _$LoadOverviewImpl _value, $Res Function(_$LoadOverviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of OverviewEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadOverviewImpl implements LoadOverview {
  const _$LoadOverviewImpl();

  @override
  String toString() {
    return 'OverviewEvent.load()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadOverviewImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
  }) {
    return load();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
  }) {
    return load?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
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
    required TResult Function(LoadOverview value) load,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadOverview value)? load,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadOverview value)? load,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class LoadOverview implements OverviewEvent {
  const factory LoadOverview() = _$LoadOverviewImpl;
}

/// @nodoc
mixin _$OverviewState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OverviewSummaryEntity summary) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OverviewSummaryEntity summary)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OverviewSummaryEntity summary)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OverviewInitial value) initial,
    required TResult Function(OverviewLoading value) loading,
    required TResult Function(OverviewLoaded value) loaded,
    required TResult Function(OverviewError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OverviewInitial value)? initial,
    TResult? Function(OverviewLoading value)? loading,
    TResult? Function(OverviewLoaded value)? loaded,
    TResult? Function(OverviewError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OverviewInitial value)? initial,
    TResult Function(OverviewLoading value)? loading,
    TResult Function(OverviewLoaded value)? loaded,
    TResult Function(OverviewError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OverviewStateCopyWith<$Res> {
  factory $OverviewStateCopyWith(
          OverviewState value, $Res Function(OverviewState) then) =
      _$OverviewStateCopyWithImpl<$Res, OverviewState>;
}

/// @nodoc
class _$OverviewStateCopyWithImpl<$Res, $Val extends OverviewState>
    implements $OverviewStateCopyWith<$Res> {
  _$OverviewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OverviewInitialImplCopyWith<$Res> {
  factory _$$OverviewInitialImplCopyWith(_$OverviewInitialImpl value,
          $Res Function(_$OverviewInitialImpl) then) =
      __$$OverviewInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OverviewInitialImplCopyWithImpl<$Res>
    extends _$OverviewStateCopyWithImpl<$Res, _$OverviewInitialImpl>
    implements _$$OverviewInitialImplCopyWith<$Res> {
  __$$OverviewInitialImplCopyWithImpl(
      _$OverviewInitialImpl _value, $Res Function(_$OverviewInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OverviewInitialImpl implements OverviewInitial {
  const _$OverviewInitialImpl();

  @override
  String toString() {
    return 'OverviewState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OverviewInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OverviewSummaryEntity summary) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OverviewSummaryEntity summary)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OverviewSummaryEntity summary)? loaded,
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
    required TResult Function(OverviewInitial value) initial,
    required TResult Function(OverviewLoading value) loading,
    required TResult Function(OverviewLoaded value) loaded,
    required TResult Function(OverviewError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OverviewInitial value)? initial,
    TResult? Function(OverviewLoading value)? loading,
    TResult? Function(OverviewLoaded value)? loaded,
    TResult? Function(OverviewError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OverviewInitial value)? initial,
    TResult Function(OverviewLoading value)? loading,
    TResult Function(OverviewLoaded value)? loaded,
    TResult Function(OverviewError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class OverviewInitial implements OverviewState {
  const factory OverviewInitial() = _$OverviewInitialImpl;
}

/// @nodoc
abstract class _$$OverviewLoadingImplCopyWith<$Res> {
  factory _$$OverviewLoadingImplCopyWith(_$OverviewLoadingImpl value,
          $Res Function(_$OverviewLoadingImpl) then) =
      __$$OverviewLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OverviewLoadingImplCopyWithImpl<$Res>
    extends _$OverviewStateCopyWithImpl<$Res, _$OverviewLoadingImpl>
    implements _$$OverviewLoadingImplCopyWith<$Res> {
  __$$OverviewLoadingImplCopyWithImpl(
      _$OverviewLoadingImpl _value, $Res Function(_$OverviewLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OverviewLoadingImpl implements OverviewLoading {
  const _$OverviewLoadingImpl();

  @override
  String toString() {
    return 'OverviewState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OverviewLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OverviewSummaryEntity summary) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OverviewSummaryEntity summary)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OverviewSummaryEntity summary)? loaded,
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
    required TResult Function(OverviewInitial value) initial,
    required TResult Function(OverviewLoading value) loading,
    required TResult Function(OverviewLoaded value) loaded,
    required TResult Function(OverviewError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OverviewInitial value)? initial,
    TResult? Function(OverviewLoading value)? loading,
    TResult? Function(OverviewLoaded value)? loaded,
    TResult? Function(OverviewError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OverviewInitial value)? initial,
    TResult Function(OverviewLoading value)? loading,
    TResult Function(OverviewLoaded value)? loaded,
    TResult Function(OverviewError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class OverviewLoading implements OverviewState {
  const factory OverviewLoading() = _$OverviewLoadingImpl;
}

/// @nodoc
abstract class _$$OverviewLoadedImplCopyWith<$Res> {
  factory _$$OverviewLoadedImplCopyWith(_$OverviewLoadedImpl value,
          $Res Function(_$OverviewLoadedImpl) then) =
      __$$OverviewLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({OverviewSummaryEntity summary});
}

/// @nodoc
class __$$OverviewLoadedImplCopyWithImpl<$Res>
    extends _$OverviewStateCopyWithImpl<$Res, _$OverviewLoadedImpl>
    implements _$$OverviewLoadedImplCopyWith<$Res> {
  __$$OverviewLoadedImplCopyWithImpl(
      _$OverviewLoadedImpl _value, $Res Function(_$OverviewLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
  }) {
    return _then(_$OverviewLoadedImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as OverviewSummaryEntity,
    ));
  }
}

/// @nodoc

class _$OverviewLoadedImpl implements OverviewLoaded {
  const _$OverviewLoadedImpl({required this.summary});

  @override
  final OverviewSummaryEntity summary;

  @override
  String toString() {
    return 'OverviewState.loaded(summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OverviewLoadedImpl &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(runtimeType, summary);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OverviewLoadedImplCopyWith<_$OverviewLoadedImpl> get copyWith =>
      __$$OverviewLoadedImplCopyWithImpl<_$OverviewLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OverviewSummaryEntity summary) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(summary);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OverviewSummaryEntity summary)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(summary);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OverviewSummaryEntity summary)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(summary);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OverviewInitial value) initial,
    required TResult Function(OverviewLoading value) loading,
    required TResult Function(OverviewLoaded value) loaded,
    required TResult Function(OverviewError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OverviewInitial value)? initial,
    TResult? Function(OverviewLoading value)? loading,
    TResult? Function(OverviewLoaded value)? loaded,
    TResult? Function(OverviewError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OverviewInitial value)? initial,
    TResult Function(OverviewLoading value)? loading,
    TResult Function(OverviewLoaded value)? loaded,
    TResult Function(OverviewError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class OverviewLoaded implements OverviewState {
  const factory OverviewLoaded({required final OverviewSummaryEntity summary}) =
      _$OverviewLoadedImpl;

  OverviewSummaryEntity get summary;

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OverviewLoadedImplCopyWith<_$OverviewLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OverviewErrorImplCopyWith<$Res> {
  factory _$$OverviewErrorImplCopyWith(
          _$OverviewErrorImpl value, $Res Function(_$OverviewErrorImpl) then) =
      __$$OverviewErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OverviewErrorImplCopyWithImpl<$Res>
    extends _$OverviewStateCopyWithImpl<$Res, _$OverviewErrorImpl>
    implements _$$OverviewErrorImplCopyWith<$Res> {
  __$$OverviewErrorImplCopyWithImpl(
      _$OverviewErrorImpl _value, $Res Function(_$OverviewErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$OverviewErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$OverviewErrorImpl implements OverviewError {
  const _$OverviewErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'OverviewState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OverviewErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OverviewErrorImplCopyWith<_$OverviewErrorImpl> get copyWith =>
      __$$OverviewErrorImplCopyWithImpl<_$OverviewErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(OverviewSummaryEntity summary) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OverviewSummaryEntity summary)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OverviewSummaryEntity summary)? loaded,
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
    required TResult Function(OverviewInitial value) initial,
    required TResult Function(OverviewLoading value) loading,
    required TResult Function(OverviewLoaded value) loaded,
    required TResult Function(OverviewError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OverviewInitial value)? initial,
    TResult? Function(OverviewLoading value)? loading,
    TResult? Function(OverviewLoaded value)? loaded,
    TResult? Function(OverviewError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OverviewInitial value)? initial,
    TResult Function(OverviewLoading value)? loading,
    TResult Function(OverviewLoaded value)? loaded,
    TResult Function(OverviewError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class OverviewError implements OverviewState {
  const factory OverviewError({required final String message}) =
      _$OverviewErrorImpl;

  String get message;

  /// Create a copy of OverviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OverviewErrorImplCopyWith<_$OverviewErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
