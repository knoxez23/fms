// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MarketplaceEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(ProductEntity product) addProduct,
    required TResult Function(ProductEntity product) updateProduct,
    required TResult Function(String id) deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(ProductEntity product)? addProduct,
    TResult? Function(ProductEntity product)? updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(ProductEntity product)? addProduct,
    TResult Function(ProductEntity product)? updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMarketplace value) load,
    required TResult Function(AddMarketplaceProduct value) addProduct,
    required TResult Function(UpdateMarketplaceProduct value) updateProduct,
    required TResult Function(DeleteMarketplaceProduct value) deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMarketplace value)? load,
    TResult? Function(AddMarketplaceProduct value)? addProduct,
    TResult? Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult? Function(DeleteMarketplaceProduct value)? deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMarketplace value)? load,
    TResult Function(AddMarketplaceProduct value)? addProduct,
    TResult Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult Function(DeleteMarketplaceProduct value)? deleteProduct,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceEventCopyWith<$Res> {
  factory $MarketplaceEventCopyWith(
          MarketplaceEvent value, $Res Function(MarketplaceEvent) then) =
      _$MarketplaceEventCopyWithImpl<$Res, MarketplaceEvent>;
}

/// @nodoc
class _$MarketplaceEventCopyWithImpl<$Res, $Val extends MarketplaceEvent>
    implements $MarketplaceEventCopyWith<$Res> {
  _$MarketplaceEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadMarketplaceImplCopyWith<$Res> {
  factory _$$LoadMarketplaceImplCopyWith(_$LoadMarketplaceImpl value,
          $Res Function(_$LoadMarketplaceImpl) then) =
      __$$LoadMarketplaceImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadMarketplaceImplCopyWithImpl<$Res>
    extends _$MarketplaceEventCopyWithImpl<$Res, _$LoadMarketplaceImpl>
    implements _$$LoadMarketplaceImplCopyWith<$Res> {
  __$$LoadMarketplaceImplCopyWithImpl(
      _$LoadMarketplaceImpl _value, $Res Function(_$LoadMarketplaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadMarketplaceImpl implements LoadMarketplace {
  const _$LoadMarketplaceImpl();

  @override
  String toString() {
    return 'MarketplaceEvent.load()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadMarketplaceImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(ProductEntity product) addProduct,
    required TResult Function(ProductEntity product) updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return load();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(ProductEntity product)? addProduct,
    TResult? Function(ProductEntity product)? updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return load?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(ProductEntity product)? addProduct,
    TResult Function(ProductEntity product)? updateProduct,
    TResult Function(String id)? deleteProduct,
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
    required TResult Function(LoadMarketplace value) load,
    required TResult Function(AddMarketplaceProduct value) addProduct,
    required TResult Function(UpdateMarketplaceProduct value) updateProduct,
    required TResult Function(DeleteMarketplaceProduct value) deleteProduct,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMarketplace value)? load,
    TResult? Function(AddMarketplaceProduct value)? addProduct,
    TResult? Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult? Function(DeleteMarketplaceProduct value)? deleteProduct,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMarketplace value)? load,
    TResult Function(AddMarketplaceProduct value)? addProduct,
    TResult Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult Function(DeleteMarketplaceProduct value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class LoadMarketplace implements MarketplaceEvent {
  const factory LoadMarketplace() = _$LoadMarketplaceImpl;
}

/// @nodoc
abstract class _$$AddMarketplaceProductImplCopyWith<$Res> {
  factory _$$AddMarketplaceProductImplCopyWith(
          _$AddMarketplaceProductImpl value,
          $Res Function(_$AddMarketplaceProductImpl) then) =
      __$$AddMarketplaceProductImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ProductEntity product});
}

/// @nodoc
class __$$AddMarketplaceProductImplCopyWithImpl<$Res>
    extends _$MarketplaceEventCopyWithImpl<$Res, _$AddMarketplaceProductImpl>
    implements _$$AddMarketplaceProductImplCopyWith<$Res> {
  __$$AddMarketplaceProductImplCopyWithImpl(_$AddMarketplaceProductImpl _value,
      $Res Function(_$AddMarketplaceProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? product = null,
  }) {
    return _then(_$AddMarketplaceProductImpl(
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductEntity,
    ));
  }
}

/// @nodoc

class _$AddMarketplaceProductImpl implements AddMarketplaceProduct {
  const _$AddMarketplaceProductImpl({required this.product});

  @override
  final ProductEntity product;

  @override
  String toString() {
    return 'MarketplaceEvent.addProduct(product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddMarketplaceProductImpl &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddMarketplaceProductImplCopyWith<_$AddMarketplaceProductImpl>
      get copyWith => __$$AddMarketplaceProductImplCopyWithImpl<
          _$AddMarketplaceProductImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(ProductEntity product) addProduct,
    required TResult Function(ProductEntity product) updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return addProduct(product);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(ProductEntity product)? addProduct,
    TResult? Function(ProductEntity product)? updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return addProduct?.call(product);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(ProductEntity product)? addProduct,
    TResult Function(ProductEntity product)? updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (addProduct != null) {
      return addProduct(product);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMarketplace value) load,
    required TResult Function(AddMarketplaceProduct value) addProduct,
    required TResult Function(UpdateMarketplaceProduct value) updateProduct,
    required TResult Function(DeleteMarketplaceProduct value) deleteProduct,
  }) {
    return addProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMarketplace value)? load,
    TResult? Function(AddMarketplaceProduct value)? addProduct,
    TResult? Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult? Function(DeleteMarketplaceProduct value)? deleteProduct,
  }) {
    return addProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMarketplace value)? load,
    TResult Function(AddMarketplaceProduct value)? addProduct,
    TResult Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult Function(DeleteMarketplaceProduct value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (addProduct != null) {
      return addProduct(this);
    }
    return orElse();
  }
}

abstract class AddMarketplaceProduct implements MarketplaceEvent {
  const factory AddMarketplaceProduct({required final ProductEntity product}) =
      _$AddMarketplaceProductImpl;

  ProductEntity get product;

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddMarketplaceProductImplCopyWith<_$AddMarketplaceProductImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateMarketplaceProductImplCopyWith<$Res> {
  factory _$$UpdateMarketplaceProductImplCopyWith(
          _$UpdateMarketplaceProductImpl value,
          $Res Function(_$UpdateMarketplaceProductImpl) then) =
      __$$UpdateMarketplaceProductImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ProductEntity product});
}

/// @nodoc
class __$$UpdateMarketplaceProductImplCopyWithImpl<$Res>
    extends _$MarketplaceEventCopyWithImpl<$Res, _$UpdateMarketplaceProductImpl>
    implements _$$UpdateMarketplaceProductImplCopyWith<$Res> {
  __$$UpdateMarketplaceProductImplCopyWithImpl(
      _$UpdateMarketplaceProductImpl _value,
      $Res Function(_$UpdateMarketplaceProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? product = null,
  }) {
    return _then(_$UpdateMarketplaceProductImpl(
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductEntity,
    ));
  }
}

/// @nodoc

class _$UpdateMarketplaceProductImpl implements UpdateMarketplaceProduct {
  const _$UpdateMarketplaceProductImpl({required this.product});

  @override
  final ProductEntity product;

  @override
  String toString() {
    return 'MarketplaceEvent.updateProduct(product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateMarketplaceProductImpl &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateMarketplaceProductImplCopyWith<_$UpdateMarketplaceProductImpl>
      get copyWith => __$$UpdateMarketplaceProductImplCopyWithImpl<
          _$UpdateMarketplaceProductImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(ProductEntity product) addProduct,
    required TResult Function(ProductEntity product) updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return updateProduct(product);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(ProductEntity product)? addProduct,
    TResult? Function(ProductEntity product)? updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return updateProduct?.call(product);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(ProductEntity product)? addProduct,
    TResult Function(ProductEntity product)? updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (updateProduct != null) {
      return updateProduct(product);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMarketplace value) load,
    required TResult Function(AddMarketplaceProduct value) addProduct,
    required TResult Function(UpdateMarketplaceProduct value) updateProduct,
    required TResult Function(DeleteMarketplaceProduct value) deleteProduct,
  }) {
    return updateProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMarketplace value)? load,
    TResult? Function(AddMarketplaceProduct value)? addProduct,
    TResult? Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult? Function(DeleteMarketplaceProduct value)? deleteProduct,
  }) {
    return updateProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMarketplace value)? load,
    TResult Function(AddMarketplaceProduct value)? addProduct,
    TResult Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult Function(DeleteMarketplaceProduct value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (updateProduct != null) {
      return updateProduct(this);
    }
    return orElse();
  }
}

abstract class UpdateMarketplaceProduct implements MarketplaceEvent {
  const factory UpdateMarketplaceProduct(
      {required final ProductEntity product}) = _$UpdateMarketplaceProductImpl;

  ProductEntity get product;

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateMarketplaceProductImplCopyWith<_$UpdateMarketplaceProductImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteMarketplaceProductImplCopyWith<$Res> {
  factory _$$DeleteMarketplaceProductImplCopyWith(
          _$DeleteMarketplaceProductImpl value,
          $Res Function(_$DeleteMarketplaceProductImpl) then) =
      __$$DeleteMarketplaceProductImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteMarketplaceProductImplCopyWithImpl<$Res>
    extends _$MarketplaceEventCopyWithImpl<$Res, _$DeleteMarketplaceProductImpl>
    implements _$$DeleteMarketplaceProductImplCopyWith<$Res> {
  __$$DeleteMarketplaceProductImplCopyWithImpl(
      _$DeleteMarketplaceProductImpl _value,
      $Res Function(_$DeleteMarketplaceProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteMarketplaceProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteMarketplaceProductImpl implements DeleteMarketplaceProduct {
  const _$DeleteMarketplaceProductImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'MarketplaceEvent.deleteProduct(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteMarketplaceProductImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteMarketplaceProductImplCopyWith<_$DeleteMarketplaceProductImpl>
      get copyWith => __$$DeleteMarketplaceProductImplCopyWithImpl<
          _$DeleteMarketplaceProductImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(ProductEntity product) addProduct,
    required TResult Function(ProductEntity product) updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return deleteProduct(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(ProductEntity product)? addProduct,
    TResult? Function(ProductEntity product)? updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return deleteProduct?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(ProductEntity product)? addProduct,
    TResult Function(ProductEntity product)? updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (deleteProduct != null) {
      return deleteProduct(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMarketplace value) load,
    required TResult Function(AddMarketplaceProduct value) addProduct,
    required TResult Function(UpdateMarketplaceProduct value) updateProduct,
    required TResult Function(DeleteMarketplaceProduct value) deleteProduct,
  }) {
    return deleteProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMarketplace value)? load,
    TResult? Function(AddMarketplaceProduct value)? addProduct,
    TResult? Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult? Function(DeleteMarketplaceProduct value)? deleteProduct,
  }) {
    return deleteProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMarketplace value)? load,
    TResult Function(AddMarketplaceProduct value)? addProduct,
    TResult Function(UpdateMarketplaceProduct value)? updateProduct,
    TResult Function(DeleteMarketplaceProduct value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (deleteProduct != null) {
      return deleteProduct(this);
    }
    return orElse();
  }
}

abstract class DeleteMarketplaceProduct implements MarketplaceEvent {
  const factory DeleteMarketplaceProduct({required final String id}) =
      _$DeleteMarketplaceProductImpl;

  String get id;

  /// Create a copy of MarketplaceEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteMarketplaceProductImplCopyWith<_$DeleteMarketplaceProductImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MarketplaceState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ProductEntity> products) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ProductEntity> products)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ProductEntity> products)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarketplaceInitial value) initial,
    required TResult Function(MarketplaceLoading value) loading,
    required TResult Function(MarketplaceLoaded value) loaded,
    required TResult Function(MarketplaceError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarketplaceInitial value)? initial,
    TResult? Function(MarketplaceLoading value)? loading,
    TResult? Function(MarketplaceLoaded value)? loaded,
    TResult? Function(MarketplaceError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarketplaceInitial value)? initial,
    TResult Function(MarketplaceLoading value)? loading,
    TResult Function(MarketplaceLoaded value)? loaded,
    TResult Function(MarketplaceError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceStateCopyWith<$Res> {
  factory $MarketplaceStateCopyWith(
          MarketplaceState value, $Res Function(MarketplaceState) then) =
      _$MarketplaceStateCopyWithImpl<$Res, MarketplaceState>;
}

/// @nodoc
class _$MarketplaceStateCopyWithImpl<$Res, $Val extends MarketplaceState>
    implements $MarketplaceStateCopyWith<$Res> {
  _$MarketplaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MarketplaceInitialImplCopyWith<$Res> {
  factory _$$MarketplaceInitialImplCopyWith(_$MarketplaceInitialImpl value,
          $Res Function(_$MarketplaceInitialImpl) then) =
      __$$MarketplaceInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MarketplaceInitialImplCopyWithImpl<$Res>
    extends _$MarketplaceStateCopyWithImpl<$Res, _$MarketplaceInitialImpl>
    implements _$$MarketplaceInitialImplCopyWith<$Res> {
  __$$MarketplaceInitialImplCopyWithImpl(_$MarketplaceInitialImpl _value,
      $Res Function(_$MarketplaceInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MarketplaceInitialImpl implements MarketplaceInitial {
  const _$MarketplaceInitialImpl();

  @override
  String toString() {
    return 'MarketplaceState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MarketplaceInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ProductEntity> products) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ProductEntity> products)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ProductEntity> products)? loaded,
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
    required TResult Function(MarketplaceInitial value) initial,
    required TResult Function(MarketplaceLoading value) loading,
    required TResult Function(MarketplaceLoaded value) loaded,
    required TResult Function(MarketplaceError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarketplaceInitial value)? initial,
    TResult? Function(MarketplaceLoading value)? loading,
    TResult? Function(MarketplaceLoaded value)? loaded,
    TResult? Function(MarketplaceError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarketplaceInitial value)? initial,
    TResult Function(MarketplaceLoading value)? loading,
    TResult Function(MarketplaceLoaded value)? loaded,
    TResult Function(MarketplaceError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class MarketplaceInitial implements MarketplaceState {
  const factory MarketplaceInitial() = _$MarketplaceInitialImpl;
}

/// @nodoc
abstract class _$$MarketplaceLoadingImplCopyWith<$Res> {
  factory _$$MarketplaceLoadingImplCopyWith(_$MarketplaceLoadingImpl value,
          $Res Function(_$MarketplaceLoadingImpl) then) =
      __$$MarketplaceLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MarketplaceLoadingImplCopyWithImpl<$Res>
    extends _$MarketplaceStateCopyWithImpl<$Res, _$MarketplaceLoadingImpl>
    implements _$$MarketplaceLoadingImplCopyWith<$Res> {
  __$$MarketplaceLoadingImplCopyWithImpl(_$MarketplaceLoadingImpl _value,
      $Res Function(_$MarketplaceLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MarketplaceLoadingImpl implements MarketplaceLoading {
  const _$MarketplaceLoadingImpl();

  @override
  String toString() {
    return 'MarketplaceState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MarketplaceLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ProductEntity> products) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ProductEntity> products)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ProductEntity> products)? loaded,
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
    required TResult Function(MarketplaceInitial value) initial,
    required TResult Function(MarketplaceLoading value) loading,
    required TResult Function(MarketplaceLoaded value) loaded,
    required TResult Function(MarketplaceError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarketplaceInitial value)? initial,
    TResult? Function(MarketplaceLoading value)? loading,
    TResult? Function(MarketplaceLoaded value)? loaded,
    TResult? Function(MarketplaceError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarketplaceInitial value)? initial,
    TResult Function(MarketplaceLoading value)? loading,
    TResult Function(MarketplaceLoaded value)? loaded,
    TResult Function(MarketplaceError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class MarketplaceLoading implements MarketplaceState {
  const factory MarketplaceLoading() = _$MarketplaceLoadingImpl;
}

/// @nodoc
abstract class _$$MarketplaceLoadedImplCopyWith<$Res> {
  factory _$$MarketplaceLoadedImplCopyWith(_$MarketplaceLoadedImpl value,
          $Res Function(_$MarketplaceLoadedImpl) then) =
      __$$MarketplaceLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ProductEntity> products});
}

/// @nodoc
class __$$MarketplaceLoadedImplCopyWithImpl<$Res>
    extends _$MarketplaceStateCopyWithImpl<$Res, _$MarketplaceLoadedImpl>
    implements _$$MarketplaceLoadedImplCopyWith<$Res> {
  __$$MarketplaceLoadedImplCopyWithImpl(_$MarketplaceLoadedImpl _value,
      $Res Function(_$MarketplaceLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
  }) {
    return _then(_$MarketplaceLoadedImpl(
      products: null == products
          ? _value._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<ProductEntity>,
    ));
  }
}

/// @nodoc

class _$MarketplaceLoadedImpl implements MarketplaceLoaded {
  const _$MarketplaceLoadedImpl({required final List<ProductEntity> products})
      : _products = products;

  final List<ProductEntity> _products;
  @override
  List<ProductEntity> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  String toString() {
    return 'MarketplaceState.loaded(products: $products)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceLoadedImpl &&
            const DeepCollectionEquality().equals(other._products, _products));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_products));

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceLoadedImplCopyWith<_$MarketplaceLoadedImpl> get copyWith =>
      __$$MarketplaceLoadedImplCopyWithImpl<_$MarketplaceLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ProductEntity> products) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(products);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ProductEntity> products)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(products);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ProductEntity> products)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(products);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarketplaceInitial value) initial,
    required TResult Function(MarketplaceLoading value) loading,
    required TResult Function(MarketplaceLoaded value) loaded,
    required TResult Function(MarketplaceError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarketplaceInitial value)? initial,
    TResult? Function(MarketplaceLoading value)? loading,
    TResult? Function(MarketplaceLoaded value)? loaded,
    TResult? Function(MarketplaceError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarketplaceInitial value)? initial,
    TResult Function(MarketplaceLoading value)? loading,
    TResult Function(MarketplaceLoaded value)? loaded,
    TResult Function(MarketplaceError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class MarketplaceLoaded implements MarketplaceState {
  const factory MarketplaceLoaded(
      {required final List<ProductEntity> products}) = _$MarketplaceLoadedImpl;

  List<ProductEntity> get products;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceLoadedImplCopyWith<_$MarketplaceLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MarketplaceErrorImplCopyWith<$Res> {
  factory _$$MarketplaceErrorImplCopyWith(_$MarketplaceErrorImpl value,
          $Res Function(_$MarketplaceErrorImpl) then) =
      __$$MarketplaceErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$MarketplaceErrorImplCopyWithImpl<$Res>
    extends _$MarketplaceStateCopyWithImpl<$Res, _$MarketplaceErrorImpl>
    implements _$$MarketplaceErrorImplCopyWith<$Res> {
  __$$MarketplaceErrorImplCopyWithImpl(_$MarketplaceErrorImpl _value,
      $Res Function(_$MarketplaceErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$MarketplaceErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MarketplaceErrorImpl implements MarketplaceError {
  const _$MarketplaceErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'MarketplaceState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceErrorImplCopyWith<_$MarketplaceErrorImpl> get copyWith =>
      __$$MarketplaceErrorImplCopyWithImpl<_$MarketplaceErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ProductEntity> products) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ProductEntity> products)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ProductEntity> products)? loaded,
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
    required TResult Function(MarketplaceInitial value) initial,
    required TResult Function(MarketplaceLoading value) loading,
    required TResult Function(MarketplaceLoaded value) loaded,
    required TResult Function(MarketplaceError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarketplaceInitial value)? initial,
    TResult? Function(MarketplaceLoading value)? loading,
    TResult? Function(MarketplaceLoaded value)? loaded,
    TResult? Function(MarketplaceError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarketplaceInitial value)? initial,
    TResult Function(MarketplaceLoading value)? loading,
    TResult Function(MarketplaceLoaded value)? loaded,
    TResult Function(MarketplaceError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class MarketplaceError implements MarketplaceState {
  const factory MarketplaceError({required final String message}) =
      _$MarketplaceErrorImpl;

  String get message;

  /// Create a copy of MarketplaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceErrorImplCopyWith<_$MarketplaceErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
