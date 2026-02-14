// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feeding_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedingEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(int scheduleId) toggleComplete,
    required TResult Function(int logId) deleteHistory,
    required TResult Function() completeAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(int scheduleId)? toggleComplete,
    TResult? Function(int logId)? deleteHistory,
    TResult? Function()? completeAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(int scheduleId)? toggleComplete,
    TResult Function(int logId)? deleteHistory,
    TResult Function()? completeAll,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadFeedingData value) load,
    required TResult Function(ToggleFeedingComplete value) toggleComplete,
    required TResult Function(DeleteFeedingHistory value) deleteHistory,
    required TResult Function(CompleteAllFeedings value) completeAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadFeedingData value)? load,
    TResult? Function(ToggleFeedingComplete value)? toggleComplete,
    TResult? Function(DeleteFeedingHistory value)? deleteHistory,
    TResult? Function(CompleteAllFeedings value)? completeAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadFeedingData value)? load,
    TResult Function(ToggleFeedingComplete value)? toggleComplete,
    TResult Function(DeleteFeedingHistory value)? deleteHistory,
    TResult Function(CompleteAllFeedings value)? completeAll,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedingEventCopyWith<$Res> {
  factory $FeedingEventCopyWith(
          FeedingEvent value, $Res Function(FeedingEvent) then) =
      _$FeedingEventCopyWithImpl<$Res, FeedingEvent>;
}

/// @nodoc
class _$FeedingEventCopyWithImpl<$Res, $Val extends FeedingEvent>
    implements $FeedingEventCopyWith<$Res> {
  _$FeedingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadFeedingDataImplCopyWith<$Res> {
  factory _$$LoadFeedingDataImplCopyWith(_$LoadFeedingDataImpl value,
          $Res Function(_$LoadFeedingDataImpl) then) =
      __$$LoadFeedingDataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadFeedingDataImplCopyWithImpl<$Res>
    extends _$FeedingEventCopyWithImpl<$Res, _$LoadFeedingDataImpl>
    implements _$$LoadFeedingDataImplCopyWith<$Res> {
  __$$LoadFeedingDataImplCopyWithImpl(
      _$LoadFeedingDataImpl _value, $Res Function(_$LoadFeedingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadFeedingDataImpl implements LoadFeedingData {
  const _$LoadFeedingDataImpl();

  @override
  String toString() {
    return 'FeedingEvent.load()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadFeedingDataImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(int scheduleId) toggleComplete,
    required TResult Function(int logId) deleteHistory,
    required TResult Function() completeAll,
  }) {
    return load();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(int scheduleId)? toggleComplete,
    TResult? Function(int logId)? deleteHistory,
    TResult? Function()? completeAll,
  }) {
    return load?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(int scheduleId)? toggleComplete,
    TResult Function(int logId)? deleteHistory,
    TResult Function()? completeAll,
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
    required TResult Function(LoadFeedingData value) load,
    required TResult Function(ToggleFeedingComplete value) toggleComplete,
    required TResult Function(DeleteFeedingHistory value) deleteHistory,
    required TResult Function(CompleteAllFeedings value) completeAll,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadFeedingData value)? load,
    TResult? Function(ToggleFeedingComplete value)? toggleComplete,
    TResult? Function(DeleteFeedingHistory value)? deleteHistory,
    TResult? Function(CompleteAllFeedings value)? completeAll,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadFeedingData value)? load,
    TResult Function(ToggleFeedingComplete value)? toggleComplete,
    TResult Function(DeleteFeedingHistory value)? deleteHistory,
    TResult Function(CompleteAllFeedings value)? completeAll,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class LoadFeedingData implements FeedingEvent {
  const factory LoadFeedingData() = _$LoadFeedingDataImpl;
}

/// @nodoc
abstract class _$$ToggleFeedingCompleteImplCopyWith<$Res> {
  factory _$$ToggleFeedingCompleteImplCopyWith(
          _$ToggleFeedingCompleteImpl value,
          $Res Function(_$ToggleFeedingCompleteImpl) then) =
      __$$ToggleFeedingCompleteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int scheduleId});
}

/// @nodoc
class __$$ToggleFeedingCompleteImplCopyWithImpl<$Res>
    extends _$FeedingEventCopyWithImpl<$Res, _$ToggleFeedingCompleteImpl>
    implements _$$ToggleFeedingCompleteImplCopyWith<$Res> {
  __$$ToggleFeedingCompleteImplCopyWithImpl(_$ToggleFeedingCompleteImpl _value,
      $Res Function(_$ToggleFeedingCompleteImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
  }) {
    return _then(_$ToggleFeedingCompleteImpl(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ToggleFeedingCompleteImpl implements ToggleFeedingComplete {
  const _$ToggleFeedingCompleteImpl({required this.scheduleId});

  @override
  final int scheduleId;

  @override
  String toString() {
    return 'FeedingEvent.toggleComplete(scheduleId: $scheduleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToggleFeedingCompleteImpl &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToggleFeedingCompleteImplCopyWith<_$ToggleFeedingCompleteImpl>
      get copyWith => __$$ToggleFeedingCompleteImplCopyWithImpl<
          _$ToggleFeedingCompleteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(int scheduleId) toggleComplete,
    required TResult Function(int logId) deleteHistory,
    required TResult Function() completeAll,
  }) {
    return toggleComplete(scheduleId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(int scheduleId)? toggleComplete,
    TResult? Function(int logId)? deleteHistory,
    TResult? Function()? completeAll,
  }) {
    return toggleComplete?.call(scheduleId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(int scheduleId)? toggleComplete,
    TResult Function(int logId)? deleteHistory,
    TResult Function()? completeAll,
    required TResult orElse(),
  }) {
    if (toggleComplete != null) {
      return toggleComplete(scheduleId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadFeedingData value) load,
    required TResult Function(ToggleFeedingComplete value) toggleComplete,
    required TResult Function(DeleteFeedingHistory value) deleteHistory,
    required TResult Function(CompleteAllFeedings value) completeAll,
  }) {
    return toggleComplete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadFeedingData value)? load,
    TResult? Function(ToggleFeedingComplete value)? toggleComplete,
    TResult? Function(DeleteFeedingHistory value)? deleteHistory,
    TResult? Function(CompleteAllFeedings value)? completeAll,
  }) {
    return toggleComplete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadFeedingData value)? load,
    TResult Function(ToggleFeedingComplete value)? toggleComplete,
    TResult Function(DeleteFeedingHistory value)? deleteHistory,
    TResult Function(CompleteAllFeedings value)? completeAll,
    required TResult orElse(),
  }) {
    if (toggleComplete != null) {
      return toggleComplete(this);
    }
    return orElse();
  }
}

abstract class ToggleFeedingComplete implements FeedingEvent {
  const factory ToggleFeedingComplete({required final int scheduleId}) =
      _$ToggleFeedingCompleteImpl;

  int get scheduleId;

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToggleFeedingCompleteImplCopyWith<_$ToggleFeedingCompleteImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteFeedingHistoryImplCopyWith<$Res> {
  factory _$$DeleteFeedingHistoryImplCopyWith(_$DeleteFeedingHistoryImpl value,
          $Res Function(_$DeleteFeedingHistoryImpl) then) =
      __$$DeleteFeedingHistoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int logId});
}

/// @nodoc
class __$$DeleteFeedingHistoryImplCopyWithImpl<$Res>
    extends _$FeedingEventCopyWithImpl<$Res, _$DeleteFeedingHistoryImpl>
    implements _$$DeleteFeedingHistoryImplCopyWith<$Res> {
  __$$DeleteFeedingHistoryImplCopyWithImpl(_$DeleteFeedingHistoryImpl _value,
      $Res Function(_$DeleteFeedingHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
  }) {
    return _then(_$DeleteFeedingHistoryImpl(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DeleteFeedingHistoryImpl implements DeleteFeedingHistory {
  const _$DeleteFeedingHistoryImpl({required this.logId});

  @override
  final int logId;

  @override
  String toString() {
    return 'FeedingEvent.deleteHistory(logId: $logId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteFeedingHistoryImpl &&
            (identical(other.logId, logId) || other.logId == logId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, logId);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteFeedingHistoryImplCopyWith<_$DeleteFeedingHistoryImpl>
      get copyWith =>
          __$$DeleteFeedingHistoryImplCopyWithImpl<_$DeleteFeedingHistoryImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(int scheduleId) toggleComplete,
    required TResult Function(int logId) deleteHistory,
    required TResult Function() completeAll,
  }) {
    return deleteHistory(logId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(int scheduleId)? toggleComplete,
    TResult? Function(int logId)? deleteHistory,
    TResult? Function()? completeAll,
  }) {
    return deleteHistory?.call(logId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(int scheduleId)? toggleComplete,
    TResult Function(int logId)? deleteHistory,
    TResult Function()? completeAll,
    required TResult orElse(),
  }) {
    if (deleteHistory != null) {
      return deleteHistory(logId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadFeedingData value) load,
    required TResult Function(ToggleFeedingComplete value) toggleComplete,
    required TResult Function(DeleteFeedingHistory value) deleteHistory,
    required TResult Function(CompleteAllFeedings value) completeAll,
  }) {
    return deleteHistory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadFeedingData value)? load,
    TResult? Function(ToggleFeedingComplete value)? toggleComplete,
    TResult? Function(DeleteFeedingHistory value)? deleteHistory,
    TResult? Function(CompleteAllFeedings value)? completeAll,
  }) {
    return deleteHistory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadFeedingData value)? load,
    TResult Function(ToggleFeedingComplete value)? toggleComplete,
    TResult Function(DeleteFeedingHistory value)? deleteHistory,
    TResult Function(CompleteAllFeedings value)? completeAll,
    required TResult orElse(),
  }) {
    if (deleteHistory != null) {
      return deleteHistory(this);
    }
    return orElse();
  }
}

abstract class DeleteFeedingHistory implements FeedingEvent {
  const factory DeleteFeedingHistory({required final int logId}) =
      _$DeleteFeedingHistoryImpl;

  int get logId;

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteFeedingHistoryImplCopyWith<_$DeleteFeedingHistoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompleteAllFeedingsImplCopyWith<$Res> {
  factory _$$CompleteAllFeedingsImplCopyWith(_$CompleteAllFeedingsImpl value,
          $Res Function(_$CompleteAllFeedingsImpl) then) =
      __$$CompleteAllFeedingsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CompleteAllFeedingsImplCopyWithImpl<$Res>
    extends _$FeedingEventCopyWithImpl<$Res, _$CompleteAllFeedingsImpl>
    implements _$$CompleteAllFeedingsImplCopyWith<$Res> {
  __$$CompleteAllFeedingsImplCopyWithImpl(_$CompleteAllFeedingsImpl _value,
      $Res Function(_$CompleteAllFeedingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CompleteAllFeedingsImpl implements CompleteAllFeedings {
  const _$CompleteAllFeedingsImpl();

  @override
  String toString() {
    return 'FeedingEvent.completeAll()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteAllFeedingsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(int scheduleId) toggleComplete,
    required TResult Function(int logId) deleteHistory,
    required TResult Function() completeAll,
  }) {
    return completeAll();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(int scheduleId)? toggleComplete,
    TResult? Function(int logId)? deleteHistory,
    TResult? Function()? completeAll,
  }) {
    return completeAll?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(int scheduleId)? toggleComplete,
    TResult Function(int logId)? deleteHistory,
    TResult Function()? completeAll,
    required TResult orElse(),
  }) {
    if (completeAll != null) {
      return completeAll();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadFeedingData value) load,
    required TResult Function(ToggleFeedingComplete value) toggleComplete,
    required TResult Function(DeleteFeedingHistory value) deleteHistory,
    required TResult Function(CompleteAllFeedings value) completeAll,
  }) {
    return completeAll(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadFeedingData value)? load,
    TResult? Function(ToggleFeedingComplete value)? toggleComplete,
    TResult? Function(DeleteFeedingHistory value)? deleteHistory,
    TResult? Function(CompleteAllFeedings value)? completeAll,
  }) {
    return completeAll?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadFeedingData value)? load,
    TResult Function(ToggleFeedingComplete value)? toggleComplete,
    TResult Function(DeleteFeedingHistory value)? deleteHistory,
    TResult Function(CompleteAllFeedings value)? completeAll,
    required TResult orElse(),
  }) {
    if (completeAll != null) {
      return completeAll(this);
    }
    return orElse();
  }
}

abstract class CompleteAllFeedings implements FeedingEvent {
  const factory CompleteAllFeedings() = _$CompleteAllFeedingsImpl;
}

/// @nodoc
mixin _$FeedingState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeedingInitial value) initial,
    required TResult Function(FeedingLoading value) loading,
    required TResult Function(FeedingLoaded value) loaded,
    required TResult Function(FeedingError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedingInitial value)? initial,
    TResult? Function(FeedingLoading value)? loading,
    TResult? Function(FeedingLoaded value)? loaded,
    TResult? Function(FeedingError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedingInitial value)? initial,
    TResult Function(FeedingLoading value)? loading,
    TResult Function(FeedingLoaded value)? loaded,
    TResult Function(FeedingError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedingStateCopyWith<$Res> {
  factory $FeedingStateCopyWith(
          FeedingState value, $Res Function(FeedingState) then) =
      _$FeedingStateCopyWithImpl<$Res, FeedingState>;
}

/// @nodoc
class _$FeedingStateCopyWithImpl<$Res, $Val extends FeedingState>
    implements $FeedingStateCopyWith<$Res> {
  _$FeedingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FeedingInitialImplCopyWith<$Res> {
  factory _$$FeedingInitialImplCopyWith(_$FeedingInitialImpl value,
          $Res Function(_$FeedingInitialImpl) then) =
      __$$FeedingInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FeedingInitialImplCopyWithImpl<$Res>
    extends _$FeedingStateCopyWithImpl<$Res, _$FeedingInitialImpl>
    implements _$$FeedingInitialImplCopyWith<$Res> {
  __$$FeedingInitialImplCopyWithImpl(
      _$FeedingInitialImpl _value, $Res Function(_$FeedingInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FeedingInitialImpl implements FeedingInitial {
  const _$FeedingInitialImpl();

  @override
  String toString() {
    return 'FeedingState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FeedingInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
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
    required TResult Function(FeedingInitial value) initial,
    required TResult Function(FeedingLoading value) loading,
    required TResult Function(FeedingLoaded value) loaded,
    required TResult Function(FeedingError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedingInitial value)? initial,
    TResult? Function(FeedingLoading value)? loading,
    TResult? Function(FeedingLoaded value)? loaded,
    TResult? Function(FeedingError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedingInitial value)? initial,
    TResult Function(FeedingLoading value)? loading,
    TResult Function(FeedingLoaded value)? loaded,
    TResult Function(FeedingError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class FeedingInitial implements FeedingState {
  const factory FeedingInitial() = _$FeedingInitialImpl;
}

/// @nodoc
abstract class _$$FeedingLoadingImplCopyWith<$Res> {
  factory _$$FeedingLoadingImplCopyWith(_$FeedingLoadingImpl value,
          $Res Function(_$FeedingLoadingImpl) then) =
      __$$FeedingLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FeedingLoadingImplCopyWithImpl<$Res>
    extends _$FeedingStateCopyWithImpl<$Res, _$FeedingLoadingImpl>
    implements _$$FeedingLoadingImplCopyWith<$Res> {
  __$$FeedingLoadingImplCopyWithImpl(
      _$FeedingLoadingImpl _value, $Res Function(_$FeedingLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FeedingLoadingImpl implements FeedingLoading {
  const _$FeedingLoadingImpl();

  @override
  String toString() {
    return 'FeedingState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FeedingLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
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
    required TResult Function(FeedingInitial value) initial,
    required TResult Function(FeedingLoading value) loading,
    required TResult Function(FeedingLoaded value) loaded,
    required TResult Function(FeedingError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedingInitial value)? initial,
    TResult? Function(FeedingLoading value)? loading,
    TResult? Function(FeedingLoaded value)? loaded,
    TResult? Function(FeedingError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedingInitial value)? initial,
    TResult Function(FeedingLoading value)? loading,
    TResult Function(FeedingLoaded value)? loaded,
    TResult Function(FeedingError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class FeedingLoading implements FeedingState {
  const factory FeedingLoading() = _$FeedingLoadingImpl;
}

/// @nodoc
abstract class _$$FeedingLoadedImplCopyWith<$Res> {
  factory _$$FeedingLoadedImplCopyWith(
          _$FeedingLoadedImpl value, $Res Function(_$FeedingLoadedImpl) then) =
      __$$FeedingLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<FeedingScheduleEntity> schedules,
      List<FeedingLogEntity> logs,
      List<AnimalEntity> animals});
}

/// @nodoc
class __$$FeedingLoadedImplCopyWithImpl<$Res>
    extends _$FeedingStateCopyWithImpl<$Res, _$FeedingLoadedImpl>
    implements _$$FeedingLoadedImplCopyWith<$Res> {
  __$$FeedingLoadedImplCopyWithImpl(
      _$FeedingLoadedImpl _value, $Res Function(_$FeedingLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedules = null,
    Object? logs = null,
    Object? animals = null,
  }) {
    return _then(_$FeedingLoadedImpl(
      schedules: null == schedules
          ? _value._schedules
          : schedules // ignore: cast_nullable_to_non_nullable
              as List<FeedingScheduleEntity>,
      logs: null == logs
          ? _value._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<FeedingLogEntity>,
      animals: null == animals
          ? _value._animals
          : animals // ignore: cast_nullable_to_non_nullable
              as List<AnimalEntity>,
    ));
  }
}

/// @nodoc

class _$FeedingLoadedImpl implements FeedingLoaded {
  const _$FeedingLoadedImpl(
      {required final List<FeedingScheduleEntity> schedules,
      required final List<FeedingLogEntity> logs,
      required final List<AnimalEntity> animals})
      : _schedules = schedules,
        _logs = logs,
        _animals = animals;

  final List<FeedingScheduleEntity> _schedules;
  @override
  List<FeedingScheduleEntity> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  final List<FeedingLogEntity> _logs;
  @override
  List<FeedingLogEntity> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  final List<AnimalEntity> _animals;
  @override
  List<AnimalEntity> get animals {
    if (_animals is EqualUnmodifiableListView) return _animals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_animals);
  }

  @override
  String toString() {
    return 'FeedingState.loaded(schedules: $schedules, logs: $logs, animals: $animals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedingLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._schedules, _schedules) &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            const DeepCollectionEquality().equals(other._animals, _animals));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_schedules),
      const DeepCollectionEquality().hash(_logs),
      const DeepCollectionEquality().hash(_animals));

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedingLoadedImplCopyWith<_$FeedingLoadedImpl> get copyWith =>
      __$$FeedingLoadedImplCopyWithImpl<_$FeedingLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(schedules, logs, animals);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(schedules, logs, animals);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(schedules, logs, animals);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeedingInitial value) initial,
    required TResult Function(FeedingLoading value) loading,
    required TResult Function(FeedingLoaded value) loaded,
    required TResult Function(FeedingError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedingInitial value)? initial,
    TResult? Function(FeedingLoading value)? loading,
    TResult? Function(FeedingLoaded value)? loaded,
    TResult? Function(FeedingError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedingInitial value)? initial,
    TResult Function(FeedingLoading value)? loading,
    TResult Function(FeedingLoaded value)? loaded,
    TResult Function(FeedingError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class FeedingLoaded implements FeedingState {
  const factory FeedingLoaded(
      {required final List<FeedingScheduleEntity> schedules,
      required final List<FeedingLogEntity> logs,
      required final List<AnimalEntity> animals}) = _$FeedingLoadedImpl;

  List<FeedingScheduleEntity> get schedules;
  List<FeedingLogEntity> get logs;
  List<AnimalEntity> get animals;

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedingLoadedImplCopyWith<_$FeedingLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeedingErrorImplCopyWith<$Res> {
  factory _$$FeedingErrorImplCopyWith(
          _$FeedingErrorImpl value, $Res Function(_$FeedingErrorImpl) then) =
      __$$FeedingErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$FeedingErrorImplCopyWithImpl<$Res>
    extends _$FeedingStateCopyWithImpl<$Res, _$FeedingErrorImpl>
    implements _$$FeedingErrorImplCopyWith<$Res> {
  __$$FeedingErrorImplCopyWithImpl(
      _$FeedingErrorImpl _value, $Res Function(_$FeedingErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$FeedingErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FeedingErrorImpl implements FeedingError {
  const _$FeedingErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'FeedingState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedingErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedingErrorImplCopyWith<_$FeedingErrorImpl> get copyWith =>
      __$$FeedingErrorImplCopyWithImpl<_$FeedingErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<FeedingScheduleEntity> schedules,
            List<FeedingLogEntity> logs, List<AnimalEntity> animals)?
        loaded,
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
    required TResult Function(FeedingInitial value) initial,
    required TResult Function(FeedingLoading value) loading,
    required TResult Function(FeedingLoaded value) loaded,
    required TResult Function(FeedingError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedingInitial value)? initial,
    TResult? Function(FeedingLoading value)? loading,
    TResult? Function(FeedingLoaded value)? loaded,
    TResult? Function(FeedingError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedingInitial value)? initial,
    TResult Function(FeedingLoading value)? loading,
    TResult Function(FeedingLoaded value)? loaded,
    TResult Function(FeedingError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class FeedingError implements FeedingState {
  const factory FeedingError({required final String message}) =
      _$FeedingErrorImpl;

  String get message;

  /// Create a copy of FeedingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedingErrorImplCopyWith<_$FeedingErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
