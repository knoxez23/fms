// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SalesEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSales,
    required TResult Function(SaleEntity sale) addSale,
    required TResult Function(SaleEntity sale) updateSale,
    required TResult Function(String id) deleteSale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSales,
    TResult? Function(SaleEntity sale)? addSale,
    TResult? Function(SaleEntity sale)? updateSale,
    TResult? Function(String id)? deleteSale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSales,
    TResult Function(SaleEntity sale)? addSale,
    TResult Function(SaleEntity sale)? updateSale,
    TResult Function(String id)? deleteSale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadSales value) loadSales,
    required TResult Function(AddSaleEvent value) addSale,
    required TResult Function(UpdateSaleEvent value) updateSale,
    required TResult Function(DeleteSaleEvent value) deleteSale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadSales value)? loadSales,
    TResult? Function(AddSaleEvent value)? addSale,
    TResult? Function(UpdateSaleEvent value)? updateSale,
    TResult? Function(DeleteSaleEvent value)? deleteSale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadSales value)? loadSales,
    TResult Function(AddSaleEvent value)? addSale,
    TResult Function(UpdateSaleEvent value)? updateSale,
    TResult Function(DeleteSaleEvent value)? deleteSale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesEventCopyWith<$Res> {
  factory $SalesEventCopyWith(
          SalesEvent value, $Res Function(SalesEvent) then) =
      _$SalesEventCopyWithImpl<$Res, SalesEvent>;
}

/// @nodoc
class _$SalesEventCopyWithImpl<$Res, $Val extends SalesEvent>
    implements $SalesEventCopyWith<$Res> {
  _$SalesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadSalesImplCopyWith<$Res> {
  factory _$$LoadSalesImplCopyWith(
          _$LoadSalesImpl value, $Res Function(_$LoadSalesImpl) then) =
      __$$LoadSalesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadSalesImplCopyWithImpl<$Res>
    extends _$SalesEventCopyWithImpl<$Res, _$LoadSalesImpl>
    implements _$$LoadSalesImplCopyWith<$Res> {
  __$$LoadSalesImplCopyWithImpl(
      _$LoadSalesImpl _value, $Res Function(_$LoadSalesImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadSalesImpl implements LoadSales {
  const _$LoadSalesImpl();

  @override
  String toString() {
    return 'SalesEvent.loadSales()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadSalesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSales,
    required TResult Function(SaleEntity sale) addSale,
    required TResult Function(SaleEntity sale) updateSale,
    required TResult Function(String id) deleteSale,
  }) {
    return loadSales();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSales,
    TResult? Function(SaleEntity sale)? addSale,
    TResult? Function(SaleEntity sale)? updateSale,
    TResult? Function(String id)? deleteSale,
  }) {
    return loadSales?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSales,
    TResult Function(SaleEntity sale)? addSale,
    TResult Function(SaleEntity sale)? updateSale,
    TResult Function(String id)? deleteSale,
    required TResult orElse(),
  }) {
    if (loadSales != null) {
      return loadSales();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadSales value) loadSales,
    required TResult Function(AddSaleEvent value) addSale,
    required TResult Function(UpdateSaleEvent value) updateSale,
    required TResult Function(DeleteSaleEvent value) deleteSale,
  }) {
    return loadSales(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadSales value)? loadSales,
    TResult? Function(AddSaleEvent value)? addSale,
    TResult? Function(UpdateSaleEvent value)? updateSale,
    TResult? Function(DeleteSaleEvent value)? deleteSale,
  }) {
    return loadSales?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadSales value)? loadSales,
    TResult Function(AddSaleEvent value)? addSale,
    TResult Function(UpdateSaleEvent value)? updateSale,
    TResult Function(DeleteSaleEvent value)? deleteSale,
    required TResult orElse(),
  }) {
    if (loadSales != null) {
      return loadSales(this);
    }
    return orElse();
  }
}

abstract class LoadSales implements SalesEvent {
  const factory LoadSales() = _$LoadSalesImpl;
}

/// @nodoc
abstract class _$$AddSaleEventImplCopyWith<$Res> {
  factory _$$AddSaleEventImplCopyWith(
          _$AddSaleEventImpl value, $Res Function(_$AddSaleEventImpl) then) =
      __$$AddSaleEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SaleEntity sale});
}

/// @nodoc
class __$$AddSaleEventImplCopyWithImpl<$Res>
    extends _$SalesEventCopyWithImpl<$Res, _$AddSaleEventImpl>
    implements _$$AddSaleEventImplCopyWith<$Res> {
  __$$AddSaleEventImplCopyWithImpl(
      _$AddSaleEventImpl _value, $Res Function(_$AddSaleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sale = null,
  }) {
    return _then(_$AddSaleEventImpl(
      sale: null == sale
          ? _value.sale
          : sale // ignore: cast_nullable_to_non_nullable
              as SaleEntity,
    ));
  }
}

/// @nodoc

class _$AddSaleEventImpl implements AddSaleEvent {
  const _$AddSaleEventImpl({required this.sale});

  @override
  final SaleEntity sale;

  @override
  String toString() {
    return 'SalesEvent.addSale(sale: $sale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddSaleEventImpl &&
            (identical(other.sale, sale) || other.sale == sale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sale);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddSaleEventImplCopyWith<_$AddSaleEventImpl> get copyWith =>
      __$$AddSaleEventImplCopyWithImpl<_$AddSaleEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSales,
    required TResult Function(SaleEntity sale) addSale,
    required TResult Function(SaleEntity sale) updateSale,
    required TResult Function(String id) deleteSale,
  }) {
    return addSale(sale);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSales,
    TResult? Function(SaleEntity sale)? addSale,
    TResult? Function(SaleEntity sale)? updateSale,
    TResult? Function(String id)? deleteSale,
  }) {
    return addSale?.call(sale);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSales,
    TResult Function(SaleEntity sale)? addSale,
    TResult Function(SaleEntity sale)? updateSale,
    TResult Function(String id)? deleteSale,
    required TResult orElse(),
  }) {
    if (addSale != null) {
      return addSale(sale);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadSales value) loadSales,
    required TResult Function(AddSaleEvent value) addSale,
    required TResult Function(UpdateSaleEvent value) updateSale,
    required TResult Function(DeleteSaleEvent value) deleteSale,
  }) {
    return addSale(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadSales value)? loadSales,
    TResult? Function(AddSaleEvent value)? addSale,
    TResult? Function(UpdateSaleEvent value)? updateSale,
    TResult? Function(DeleteSaleEvent value)? deleteSale,
  }) {
    return addSale?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadSales value)? loadSales,
    TResult Function(AddSaleEvent value)? addSale,
    TResult Function(UpdateSaleEvent value)? updateSale,
    TResult Function(DeleteSaleEvent value)? deleteSale,
    required TResult orElse(),
  }) {
    if (addSale != null) {
      return addSale(this);
    }
    return orElse();
  }
}

abstract class AddSaleEvent implements SalesEvent {
  const factory AddSaleEvent({required final SaleEntity sale}) =
      _$AddSaleEventImpl;

  SaleEntity get sale;

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddSaleEventImplCopyWith<_$AddSaleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateSaleEventImplCopyWith<$Res> {
  factory _$$UpdateSaleEventImplCopyWith(_$UpdateSaleEventImpl value,
          $Res Function(_$UpdateSaleEventImpl) then) =
      __$$UpdateSaleEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SaleEntity sale});
}

/// @nodoc
class __$$UpdateSaleEventImplCopyWithImpl<$Res>
    extends _$SalesEventCopyWithImpl<$Res, _$UpdateSaleEventImpl>
    implements _$$UpdateSaleEventImplCopyWith<$Res> {
  __$$UpdateSaleEventImplCopyWithImpl(
      _$UpdateSaleEventImpl _value, $Res Function(_$UpdateSaleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sale = null,
  }) {
    return _then(_$UpdateSaleEventImpl(
      sale: null == sale
          ? _value.sale
          : sale // ignore: cast_nullable_to_non_nullable
              as SaleEntity,
    ));
  }
}

/// @nodoc

class _$UpdateSaleEventImpl implements UpdateSaleEvent {
  const _$UpdateSaleEventImpl({required this.sale});

  @override
  final SaleEntity sale;

  @override
  String toString() {
    return 'SalesEvent.updateSale(sale: $sale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateSaleEventImpl &&
            (identical(other.sale, sale) || other.sale == sale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sale);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateSaleEventImplCopyWith<_$UpdateSaleEventImpl> get copyWith =>
      __$$UpdateSaleEventImplCopyWithImpl<_$UpdateSaleEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSales,
    required TResult Function(SaleEntity sale) addSale,
    required TResult Function(SaleEntity sale) updateSale,
    required TResult Function(String id) deleteSale,
  }) {
    return updateSale(sale);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSales,
    TResult? Function(SaleEntity sale)? addSale,
    TResult? Function(SaleEntity sale)? updateSale,
    TResult? Function(String id)? deleteSale,
  }) {
    return updateSale?.call(sale);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSales,
    TResult Function(SaleEntity sale)? addSale,
    TResult Function(SaleEntity sale)? updateSale,
    TResult Function(String id)? deleteSale,
    required TResult orElse(),
  }) {
    if (updateSale != null) {
      return updateSale(sale);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadSales value) loadSales,
    required TResult Function(AddSaleEvent value) addSale,
    required TResult Function(UpdateSaleEvent value) updateSale,
    required TResult Function(DeleteSaleEvent value) deleteSale,
  }) {
    return updateSale(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadSales value)? loadSales,
    TResult? Function(AddSaleEvent value)? addSale,
    TResult? Function(UpdateSaleEvent value)? updateSale,
    TResult? Function(DeleteSaleEvent value)? deleteSale,
  }) {
    return updateSale?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadSales value)? loadSales,
    TResult Function(AddSaleEvent value)? addSale,
    TResult Function(UpdateSaleEvent value)? updateSale,
    TResult Function(DeleteSaleEvent value)? deleteSale,
    required TResult orElse(),
  }) {
    if (updateSale != null) {
      return updateSale(this);
    }
    return orElse();
  }
}

abstract class UpdateSaleEvent implements SalesEvent {
  const factory UpdateSaleEvent({required final SaleEntity sale}) =
      _$UpdateSaleEventImpl;

  SaleEntity get sale;

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateSaleEventImplCopyWith<_$UpdateSaleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteSaleEventImplCopyWith<$Res> {
  factory _$$DeleteSaleEventImplCopyWith(_$DeleteSaleEventImpl value,
          $Res Function(_$DeleteSaleEventImpl) then) =
      __$$DeleteSaleEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteSaleEventImplCopyWithImpl<$Res>
    extends _$SalesEventCopyWithImpl<$Res, _$DeleteSaleEventImpl>
    implements _$$DeleteSaleEventImplCopyWith<$Res> {
  __$$DeleteSaleEventImplCopyWithImpl(
      _$DeleteSaleEventImpl _value, $Res Function(_$DeleteSaleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteSaleEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteSaleEventImpl implements DeleteSaleEvent {
  const _$DeleteSaleEventImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'SalesEvent.deleteSale(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteSaleEventImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteSaleEventImplCopyWith<_$DeleteSaleEventImpl> get copyWith =>
      __$$DeleteSaleEventImplCopyWithImpl<_$DeleteSaleEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadSales,
    required TResult Function(SaleEntity sale) addSale,
    required TResult Function(SaleEntity sale) updateSale,
    required TResult Function(String id) deleteSale,
  }) {
    return deleteSale(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadSales,
    TResult? Function(SaleEntity sale)? addSale,
    TResult? Function(SaleEntity sale)? updateSale,
    TResult? Function(String id)? deleteSale,
  }) {
    return deleteSale?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadSales,
    TResult Function(SaleEntity sale)? addSale,
    TResult Function(SaleEntity sale)? updateSale,
    TResult Function(String id)? deleteSale,
    required TResult orElse(),
  }) {
    if (deleteSale != null) {
      return deleteSale(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadSales value) loadSales,
    required TResult Function(AddSaleEvent value) addSale,
    required TResult Function(UpdateSaleEvent value) updateSale,
    required TResult Function(DeleteSaleEvent value) deleteSale,
  }) {
    return deleteSale(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadSales value)? loadSales,
    TResult? Function(AddSaleEvent value)? addSale,
    TResult? Function(UpdateSaleEvent value)? updateSale,
    TResult? Function(DeleteSaleEvent value)? deleteSale,
  }) {
    return deleteSale?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadSales value)? loadSales,
    TResult Function(AddSaleEvent value)? addSale,
    TResult Function(UpdateSaleEvent value)? updateSale,
    TResult Function(DeleteSaleEvent value)? deleteSale,
    required TResult orElse(),
  }) {
    if (deleteSale != null) {
      return deleteSale(this);
    }
    return orElse();
  }
}

abstract class DeleteSaleEvent implements SalesEvent {
  const factory DeleteSaleEvent({required final String id}) =
      _$DeleteSaleEventImpl;

  String get id;

  /// Create a copy of SalesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteSaleEventImplCopyWith<_$DeleteSaleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SalesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SaleEntity> sales) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SaleEntity> sales)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SaleEntity> sales)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SalesInitial value) initial,
    required TResult Function(SalesLoading value) loading,
    required TResult Function(SalesLoaded value) loaded,
    required TResult Function(SalesError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SalesInitial value)? initial,
    TResult? Function(SalesLoading value)? loading,
    TResult? Function(SalesLoaded value)? loaded,
    TResult? Function(SalesError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SalesInitial value)? initial,
    TResult Function(SalesLoading value)? loading,
    TResult Function(SalesLoaded value)? loaded,
    TResult Function(SalesError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesStateCopyWith<$Res> {
  factory $SalesStateCopyWith(
          SalesState value, $Res Function(SalesState) then) =
      _$SalesStateCopyWithImpl<$Res, SalesState>;
}

/// @nodoc
class _$SalesStateCopyWithImpl<$Res, $Val extends SalesState>
    implements $SalesStateCopyWith<$Res> {
  _$SalesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SalesInitialImplCopyWith<$Res> {
  factory _$$SalesInitialImplCopyWith(
          _$SalesInitialImpl value, $Res Function(_$SalesInitialImpl) then) =
      __$$SalesInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SalesInitialImplCopyWithImpl<$Res>
    extends _$SalesStateCopyWithImpl<$Res, _$SalesInitialImpl>
    implements _$$SalesInitialImplCopyWith<$Res> {
  __$$SalesInitialImplCopyWithImpl(
      _$SalesInitialImpl _value, $Res Function(_$SalesInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SalesInitialImpl implements SalesInitial {
  const _$SalesInitialImpl();

  @override
  String toString() {
    return 'SalesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SalesInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SaleEntity> sales) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SaleEntity> sales)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SaleEntity> sales)? loaded,
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
    required TResult Function(SalesInitial value) initial,
    required TResult Function(SalesLoading value) loading,
    required TResult Function(SalesLoaded value) loaded,
    required TResult Function(SalesError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SalesInitial value)? initial,
    TResult? Function(SalesLoading value)? loading,
    TResult? Function(SalesLoaded value)? loaded,
    TResult? Function(SalesError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SalesInitial value)? initial,
    TResult Function(SalesLoading value)? loading,
    TResult Function(SalesLoaded value)? loaded,
    TResult Function(SalesError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class SalesInitial implements SalesState {
  const factory SalesInitial() = _$SalesInitialImpl;
}

/// @nodoc
abstract class _$$SalesLoadingImplCopyWith<$Res> {
  factory _$$SalesLoadingImplCopyWith(
          _$SalesLoadingImpl value, $Res Function(_$SalesLoadingImpl) then) =
      __$$SalesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SalesLoadingImplCopyWithImpl<$Res>
    extends _$SalesStateCopyWithImpl<$Res, _$SalesLoadingImpl>
    implements _$$SalesLoadingImplCopyWith<$Res> {
  __$$SalesLoadingImplCopyWithImpl(
      _$SalesLoadingImpl _value, $Res Function(_$SalesLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SalesLoadingImpl implements SalesLoading {
  const _$SalesLoadingImpl();

  @override
  String toString() {
    return 'SalesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SalesLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SaleEntity> sales) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SaleEntity> sales)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SaleEntity> sales)? loaded,
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
    required TResult Function(SalesInitial value) initial,
    required TResult Function(SalesLoading value) loading,
    required TResult Function(SalesLoaded value) loaded,
    required TResult Function(SalesError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SalesInitial value)? initial,
    TResult? Function(SalesLoading value)? loading,
    TResult? Function(SalesLoaded value)? loaded,
    TResult? Function(SalesError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SalesInitial value)? initial,
    TResult Function(SalesLoading value)? loading,
    TResult Function(SalesLoaded value)? loaded,
    TResult Function(SalesError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class SalesLoading implements SalesState {
  const factory SalesLoading() = _$SalesLoadingImpl;
}

/// @nodoc
abstract class _$$SalesLoadedImplCopyWith<$Res> {
  factory _$$SalesLoadedImplCopyWith(
          _$SalesLoadedImpl value, $Res Function(_$SalesLoadedImpl) then) =
      __$$SalesLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<SaleEntity> sales});
}

/// @nodoc
class __$$SalesLoadedImplCopyWithImpl<$Res>
    extends _$SalesStateCopyWithImpl<$Res, _$SalesLoadedImpl>
    implements _$$SalesLoadedImplCopyWith<$Res> {
  __$$SalesLoadedImplCopyWithImpl(
      _$SalesLoadedImpl _value, $Res Function(_$SalesLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sales = null,
  }) {
    return _then(_$SalesLoadedImpl(
      sales: null == sales
          ? _value._sales
          : sales // ignore: cast_nullable_to_non_nullable
              as List<SaleEntity>,
    ));
  }
}

/// @nodoc

class _$SalesLoadedImpl implements SalesLoaded {
  const _$SalesLoadedImpl({required final List<SaleEntity> sales})
      : _sales = sales;

  final List<SaleEntity> _sales;
  @override
  List<SaleEntity> get sales {
    if (_sales is EqualUnmodifiableListView) return _sales;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sales);
  }

  @override
  String toString() {
    return 'SalesState.loaded(sales: $sales)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesLoadedImpl &&
            const DeepCollectionEquality().equals(other._sales, _sales));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_sales));

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesLoadedImplCopyWith<_$SalesLoadedImpl> get copyWith =>
      __$$SalesLoadedImplCopyWithImpl<_$SalesLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SaleEntity> sales) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(sales);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SaleEntity> sales)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(sales);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SaleEntity> sales)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(sales);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SalesInitial value) initial,
    required TResult Function(SalesLoading value) loading,
    required TResult Function(SalesLoaded value) loaded,
    required TResult Function(SalesError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SalesInitial value)? initial,
    TResult? Function(SalesLoading value)? loading,
    TResult? Function(SalesLoaded value)? loaded,
    TResult? Function(SalesError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SalesInitial value)? initial,
    TResult Function(SalesLoading value)? loading,
    TResult Function(SalesLoaded value)? loaded,
    TResult Function(SalesError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class SalesLoaded implements SalesState {
  const factory SalesLoaded({required final List<SaleEntity> sales}) =
      _$SalesLoadedImpl;

  List<SaleEntity> get sales;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesLoadedImplCopyWith<_$SalesLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SalesErrorImplCopyWith<$Res> {
  factory _$$SalesErrorImplCopyWith(
          _$SalesErrorImpl value, $Res Function(_$SalesErrorImpl) then) =
      __$$SalesErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SalesErrorImplCopyWithImpl<$Res>
    extends _$SalesStateCopyWithImpl<$Res, _$SalesErrorImpl>
    implements _$$SalesErrorImplCopyWith<$Res> {
  __$$SalesErrorImplCopyWithImpl(
      _$SalesErrorImpl _value, $Res Function(_$SalesErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$SalesErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SalesErrorImpl implements SalesError {
  const _$SalesErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'SalesState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesErrorImplCopyWith<_$SalesErrorImpl> get copyWith =>
      __$$SalesErrorImplCopyWithImpl<_$SalesErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SaleEntity> sales) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SaleEntity> sales)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SaleEntity> sales)? loaded,
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
    required TResult Function(SalesInitial value) initial,
    required TResult Function(SalesLoading value) loading,
    required TResult Function(SalesLoaded value) loaded,
    required TResult Function(SalesError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SalesInitial value)? initial,
    TResult? Function(SalesLoading value)? loading,
    TResult? Function(SalesLoaded value)? loaded,
    TResult? Function(SalesError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SalesInitial value)? initial,
    TResult Function(SalesLoading value)? loading,
    TResult Function(SalesLoaded value)? loaded,
    TResult Function(SalesError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class SalesError implements SalesState {
  const factory SalesError({required final String message}) = _$SalesErrorImpl;

  String get message;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesErrorImplCopyWith<_$SalesErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
