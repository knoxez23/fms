// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InventoryEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryEventCopyWith<$Res> {
  factory $InventoryEventCopyWith(
          InventoryEvent value, $Res Function(InventoryEvent) then) =
      _$InventoryEventCopyWithImpl<$Res, InventoryEvent>;
}

/// @nodoc
class _$InventoryEventCopyWithImpl<$Res, $Val extends InventoryEvent>
    implements $InventoryEventCopyWith<$Res> {
  _$InventoryEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadInventoryImplCopyWith<$Res> {
  factory _$$LoadInventoryImplCopyWith(
          _$LoadInventoryImpl value, $Res Function(_$LoadInventoryImpl) then) =
      __$$LoadInventoryImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadInventoryImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$LoadInventoryImpl>
    implements _$$LoadInventoryImplCopyWith<$Res> {
  __$$LoadInventoryImplCopyWithImpl(
      _$LoadInventoryImpl _value, $Res Function(_$LoadInventoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadInventoryImpl implements LoadInventory {
  const _$LoadInventoryImpl();

  @override
  String toString() {
    return 'InventoryEvent.loadInventory()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadInventoryImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return loadInventory();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return loadInventory?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (loadInventory != null) {
      return loadInventory();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return loadInventory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return loadInventory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (loadInventory != null) {
      return loadInventory(this);
    }
    return orElse();
  }
}

abstract class LoadInventory implements InventoryEvent {
  const factory LoadInventory() = _$LoadInventoryImpl;
}

/// @nodoc
abstract class _$$AddItemImplCopyWith<$Res> {
  factory _$$AddItemImplCopyWith(
          _$AddItemImpl value, $Res Function(_$AddItemImpl) then) =
      __$$AddItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String itemName,
      String category,
      String? lotCode,
      String? sourceType,
      String? sourceRef,
      String? sourceLabel,
      double quantity,
      double? reservedQuantity,
      String unit,
      int? minStock,
      String? supplier,
      String? supplierId,
      double? unitPrice,
      double? totalValue,
      String? notes,
      DateTime? expiryDate,
      int? freshnessHours,
      DateTime? lastRestock});
}

/// @nodoc
class __$$AddItemImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$AddItemImpl>
    implements _$$AddItemImplCopyWith<$Res> {
  __$$AddItemImplCopyWithImpl(
      _$AddItemImpl _value, $Res Function(_$AddItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemName = null,
    Object? category = null,
    Object? lotCode = freezed,
    Object? sourceType = freezed,
    Object? sourceRef = freezed,
    Object? sourceLabel = freezed,
    Object? quantity = null,
    Object? reservedQuantity = freezed,
    Object? unit = null,
    Object? minStock = freezed,
    Object? supplier = freezed,
    Object? supplierId = freezed,
    Object? unitPrice = freezed,
    Object? totalValue = freezed,
    Object? notes = freezed,
    Object? expiryDate = freezed,
    Object? freshnessHours = freezed,
    Object? lastRestock = freezed,
  }) {
    return _then(_$AddItemImpl(
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      lotCode: freezed == lotCode
          ? _value.lotCode
          : lotCode // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceRef: freezed == sourceRef
          ? _value.sourceRef
          : sourceRef // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLabel: freezed == sourceLabel
          ? _value.sourceLabel
          : sourceLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      reservedQuantity: freezed == reservedQuantity
          ? _value.reservedQuantity
          : reservedQuantity // ignore: cast_nullable_to_non_nullable
              as double?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      minStock: freezed == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int?,
      supplier: freezed == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: freezed == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      totalValue: freezed == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      freshnessHours: freezed == freshnessHours
          ? _value.freshnessHours
          : freshnessHours // ignore: cast_nullable_to_non_nullable
              as int?,
      lastRestock: freezed == lastRestock
          ? _value.lastRestock
          : lastRestock // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$AddItemImpl implements AddItem {
  const _$AddItemImpl(
      {required this.itemName,
      required this.category,
      this.lotCode,
      this.sourceType,
      this.sourceRef,
      this.sourceLabel,
      required this.quantity,
      this.reservedQuantity,
      required this.unit,
      this.minStock,
      this.supplier,
      this.supplierId,
      this.unitPrice,
      this.totalValue,
      this.notes,
      this.expiryDate,
      this.freshnessHours,
      this.lastRestock});

  @override
  final String itemName;
  @override
  final String category;
  @override
  final String? lotCode;
  @override
  final String? sourceType;
  @override
  final String? sourceRef;
  @override
  final String? sourceLabel;
  @override
  final double quantity;
  @override
  final double? reservedQuantity;
  @override
  final String unit;
  @override
  final int? minStock;
  @override
  final String? supplier;
  @override
  final String? supplierId;
  @override
  final double? unitPrice;
  @override
  final double? totalValue;
  @override
  final String? notes;
  @override
  final DateTime? expiryDate;
  @override
  final int? freshnessHours;
  @override
  final DateTime? lastRestock;

  @override
  String toString() {
    return 'InventoryEvent.addItem(itemName: $itemName, category: $category, lotCode: $lotCode, sourceType: $sourceType, sourceRef: $sourceRef, sourceLabel: $sourceLabel, quantity: $quantity, reservedQuantity: $reservedQuantity, unit: $unit, minStock: $minStock, supplier: $supplier, supplierId: $supplierId, unitPrice: $unitPrice, totalValue: $totalValue, notes: $notes, expiryDate: $expiryDate, freshnessHours: $freshnessHours, lastRestock: $lastRestock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddItemImpl &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.lotCode, lotCode) || other.lotCode == lotCode) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceRef, sourceRef) ||
                other.sourceRef == sourceRef) &&
            (identical(other.sourceLabel, sourceLabel) ||
                other.sourceLabel == sourceLabel) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.reservedQuantity, reservedQuantity) ||
                other.reservedQuantity == reservedQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.freshnessHours, freshnessHours) ||
                other.freshnessHours == freshnessHours) &&
            (identical(other.lastRestock, lastRestock) ||
                other.lastRestock == lastRestock));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemName,
      category,
      lotCode,
      sourceType,
      sourceRef,
      sourceLabel,
      quantity,
      reservedQuantity,
      unit,
      minStock,
      supplier,
      supplierId,
      unitPrice,
      totalValue,
      notes,
      expiryDate,
      freshnessHours,
      lastRestock);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddItemImplCopyWith<_$AddItemImpl> get copyWith =>
      __$$AddItemImplCopyWithImpl<_$AddItemImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return addItem(
        itemName,
        category,
        lotCode,
        sourceType,
        sourceRef,
        sourceLabel,
        quantity,
        reservedQuantity,
        unit,
        minStock,
        supplier,
        supplierId,
        unitPrice,
        totalValue,
        notes,
        expiryDate,
        freshnessHours,
        lastRestock);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return addItem?.call(
        itemName,
        category,
        lotCode,
        sourceType,
        sourceRef,
        sourceLabel,
        quantity,
        reservedQuantity,
        unit,
        minStock,
        supplier,
        supplierId,
        unitPrice,
        totalValue,
        notes,
        expiryDate,
        freshnessHours,
        lastRestock);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (addItem != null) {
      return addItem(
          itemName,
          category,
          lotCode,
          sourceType,
          sourceRef,
          sourceLabel,
          quantity,
          reservedQuantity,
          unit,
          minStock,
          supplier,
          supplierId,
          unitPrice,
          totalValue,
          notes,
          expiryDate,
          freshnessHours,
          lastRestock);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return addItem(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return addItem?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (addItem != null) {
      return addItem(this);
    }
    return orElse();
  }
}

abstract class AddItem implements InventoryEvent {
  const factory AddItem(
      {required final String itemName,
      required final String category,
      final String? lotCode,
      final String? sourceType,
      final String? sourceRef,
      final String? sourceLabel,
      required final double quantity,
      final double? reservedQuantity,
      required final String unit,
      final int? minStock,
      final String? supplier,
      final String? supplierId,
      final double? unitPrice,
      final double? totalValue,
      final String? notes,
      final DateTime? expiryDate,
      final int? freshnessHours,
      final DateTime? lastRestock}) = _$AddItemImpl;

  String get itemName;
  String get category;
  String? get lotCode;
  String? get sourceType;
  String? get sourceRef;
  String? get sourceLabel;
  double get quantity;
  double? get reservedQuantity;
  String get unit;
  int? get minStock;
  String? get supplier;
  String? get supplierId;
  double? get unitPrice;
  double? get totalValue;
  String? get notes;
  DateTime? get expiryDate;
  int? get freshnessHours;
  DateTime? get lastRestock;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddItemImplCopyWith<_$AddItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateItemImplCopyWith<$Res> {
  factory _$$UpdateItemImplCopyWith(
          _$UpdateItemImpl value, $Res Function(_$UpdateItemImpl) then) =
      __$$UpdateItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int id,
      String? itemName,
      String? category,
      String? lotCode,
      String? sourceType,
      String? sourceRef,
      String? sourceLabel,
      double? quantity,
      double? reservedQuantity,
      String? unit,
      int? minStock,
      String? supplier,
      String? supplierId,
      double? unitPrice,
      double? totalValue,
      String? notes,
      DateTime? expiryDate,
      int? freshnessHours,
      DateTime? lastRestock});
}

/// @nodoc
class __$$UpdateItemImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$UpdateItemImpl>
    implements _$$UpdateItemImplCopyWith<$Res> {
  __$$UpdateItemImplCopyWithImpl(
      _$UpdateItemImpl _value, $Res Function(_$UpdateItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemName = freezed,
    Object? category = freezed,
    Object? lotCode = freezed,
    Object? sourceType = freezed,
    Object? sourceRef = freezed,
    Object? sourceLabel = freezed,
    Object? quantity = freezed,
    Object? reservedQuantity = freezed,
    Object? unit = freezed,
    Object? minStock = freezed,
    Object? supplier = freezed,
    Object? supplierId = freezed,
    Object? unitPrice = freezed,
    Object? totalValue = freezed,
    Object? notes = freezed,
    Object? expiryDate = freezed,
    Object? freshnessHours = freezed,
    Object? lastRestock = freezed,
  }) {
    return _then(_$UpdateItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      itemName: freezed == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      lotCode: freezed == lotCode
          ? _value.lotCode
          : lotCode // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceRef: freezed == sourceRef
          ? _value.sourceRef
          : sourceRef // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLabel: freezed == sourceLabel
          ? _value.sourceLabel
          : sourceLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double?,
      reservedQuantity: freezed == reservedQuantity
          ? _value.reservedQuantity
          : reservedQuantity // ignore: cast_nullable_to_non_nullable
              as double?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      minStock: freezed == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int?,
      supplier: freezed == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: freezed == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      totalValue: freezed == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      freshnessHours: freezed == freshnessHours
          ? _value.freshnessHours
          : freshnessHours // ignore: cast_nullable_to_non_nullable
              as int?,
      lastRestock: freezed == lastRestock
          ? _value.lastRestock
          : lastRestock // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$UpdateItemImpl implements UpdateItem {
  const _$UpdateItemImpl(
      {required this.id,
      this.itemName,
      this.category,
      this.lotCode,
      this.sourceType,
      this.sourceRef,
      this.sourceLabel,
      this.quantity,
      this.reservedQuantity,
      this.unit,
      this.minStock,
      this.supplier,
      this.supplierId,
      this.unitPrice,
      this.totalValue,
      this.notes,
      this.expiryDate,
      this.freshnessHours,
      this.lastRestock});

  @override
  final int id;
  @override
  final String? itemName;
  @override
  final String? category;
  @override
  final String? lotCode;
  @override
  final String? sourceType;
  @override
  final String? sourceRef;
  @override
  final String? sourceLabel;
  @override
  final double? quantity;
  @override
  final double? reservedQuantity;
  @override
  final String? unit;
  @override
  final int? minStock;
  @override
  final String? supplier;
  @override
  final String? supplierId;
  @override
  final double? unitPrice;
  @override
  final double? totalValue;
  @override
  final String? notes;
  @override
  final DateTime? expiryDate;
  @override
  final int? freshnessHours;
  @override
  final DateTime? lastRestock;

  @override
  String toString() {
    return 'InventoryEvent.updateItem(id: $id, itemName: $itemName, category: $category, lotCode: $lotCode, sourceType: $sourceType, sourceRef: $sourceRef, sourceLabel: $sourceLabel, quantity: $quantity, reservedQuantity: $reservedQuantity, unit: $unit, minStock: $minStock, supplier: $supplier, supplierId: $supplierId, unitPrice: $unitPrice, totalValue: $totalValue, notes: $notes, expiryDate: $expiryDate, freshnessHours: $freshnessHours, lastRestock: $lastRestock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.lotCode, lotCode) || other.lotCode == lotCode) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceRef, sourceRef) ||
                other.sourceRef == sourceRef) &&
            (identical(other.sourceLabel, sourceLabel) ||
                other.sourceLabel == sourceLabel) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.reservedQuantity, reservedQuantity) ||
                other.reservedQuantity == reservedQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.freshnessHours, freshnessHours) ||
                other.freshnessHours == freshnessHours) &&
            (identical(other.lastRestock, lastRestock) ||
                other.lastRestock == lastRestock));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        itemName,
        category,
        lotCode,
        sourceType,
        sourceRef,
        sourceLabel,
        quantity,
        reservedQuantity,
        unit,
        minStock,
        supplier,
        supplierId,
        unitPrice,
        totalValue,
        notes,
        expiryDate,
        freshnessHours,
        lastRestock
      ]);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateItemImplCopyWith<_$UpdateItemImpl> get copyWith =>
      __$$UpdateItemImplCopyWithImpl<_$UpdateItemImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return updateItem(
        id,
        itemName,
        category,
        lotCode,
        sourceType,
        sourceRef,
        sourceLabel,
        quantity,
        reservedQuantity,
        unit,
        minStock,
        supplier,
        supplierId,
        unitPrice,
        totalValue,
        notes,
        expiryDate,
        freshnessHours,
        lastRestock);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return updateItem?.call(
        id,
        itemName,
        category,
        lotCode,
        sourceType,
        sourceRef,
        sourceLabel,
        quantity,
        reservedQuantity,
        unit,
        minStock,
        supplier,
        supplierId,
        unitPrice,
        totalValue,
        notes,
        expiryDate,
        freshnessHours,
        lastRestock);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (updateItem != null) {
      return updateItem(
          id,
          itemName,
          category,
          lotCode,
          sourceType,
          sourceRef,
          sourceLabel,
          quantity,
          reservedQuantity,
          unit,
          minStock,
          supplier,
          supplierId,
          unitPrice,
          totalValue,
          notes,
          expiryDate,
          freshnessHours,
          lastRestock);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return updateItem(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return updateItem?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (updateItem != null) {
      return updateItem(this);
    }
    return orElse();
  }
}

abstract class UpdateItem implements InventoryEvent {
  const factory UpdateItem(
      {required final int id,
      final String? itemName,
      final String? category,
      final String? lotCode,
      final String? sourceType,
      final String? sourceRef,
      final String? sourceLabel,
      final double? quantity,
      final double? reservedQuantity,
      final String? unit,
      final int? minStock,
      final String? supplier,
      final String? supplierId,
      final double? unitPrice,
      final double? totalValue,
      final String? notes,
      final DateTime? expiryDate,
      final int? freshnessHours,
      final DateTime? lastRestock}) = _$UpdateItemImpl;

  int get id;
  String? get itemName;
  String? get category;
  String? get lotCode;
  String? get sourceType;
  String? get sourceRef;
  String? get sourceLabel;
  double? get quantity;
  double? get reservedQuantity;
  String? get unit;
  int? get minStock;
  String? get supplier;
  String? get supplierId;
  double? get unitPrice;
  double? get totalValue;
  String? get notes;
  DateTime? get expiryDate;
  int? get freshnessHours;
  DateTime? get lastRestock;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateItemImplCopyWith<_$UpdateItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteItemImplCopyWith<$Res> {
  factory _$$DeleteItemImplCopyWith(
          _$DeleteItemImpl value, $Res Function(_$DeleteItemImpl) then) =
      __$$DeleteItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$DeleteItemImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$DeleteItemImpl>
    implements _$$DeleteItemImplCopyWith<$Res> {
  __$$DeleteItemImplCopyWithImpl(
      _$DeleteItemImpl _value, $Res Function(_$DeleteItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DeleteItemImpl implements DeleteItem {
  const _$DeleteItemImpl({required this.id});

  @override
  final int id;

  @override
  String toString() {
    return 'InventoryEvent.deleteItem(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteItemImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteItemImplCopyWith<_$DeleteItemImpl> get copyWith =>
      __$$DeleteItemImplCopyWithImpl<_$DeleteItemImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return deleteItem(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return deleteItem?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (deleteItem != null) {
      return deleteItem(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return deleteItem(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return deleteItem?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (deleteItem != null) {
      return deleteItem(this);
    }
    return orElse();
  }
}

abstract class DeleteItem implements InventoryEvent {
  const factory DeleteItem({required final int id}) = _$DeleteItemImpl;

  int get id;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteItemImplCopyWith<_$DeleteItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchInventoryImplCopyWith<$Res> {
  factory _$$SearchInventoryImplCopyWith(_$SearchInventoryImpl value,
          $Res Function(_$SearchInventoryImpl) then) =
      __$$SearchInventoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$SearchInventoryImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$SearchInventoryImpl>
    implements _$$SearchInventoryImplCopyWith<$Res> {
  __$$SearchInventoryImplCopyWithImpl(
      _$SearchInventoryImpl _value, $Res Function(_$SearchInventoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
  }) {
    return _then(_$SearchInventoryImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SearchInventoryImpl implements SearchInventory {
  const _$SearchInventoryImpl({required this.query});

  @override
  final String query;

  @override
  String toString() {
    return 'InventoryEvent.searchInventory(query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchInventoryImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchInventoryImplCopyWith<_$SearchInventoryImpl> get copyWith =>
      __$$SearchInventoryImplCopyWithImpl<_$SearchInventoryImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return searchInventory(query);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return searchInventory?.call(query);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (searchInventory != null) {
      return searchInventory(query);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return searchInventory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return searchInventory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (searchInventory != null) {
      return searchInventory(this);
    }
    return orElse();
  }
}

abstract class SearchInventory implements InventoryEvent {
  const factory SearchInventory({required final String query}) =
      _$SearchInventoryImpl;

  String get query;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchInventoryImplCopyWith<_$SearchInventoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FilterByCategoryImplCopyWith<$Res> {
  factory _$$FilterByCategoryImplCopyWith(_$FilterByCategoryImpl value,
          $Res Function(_$FilterByCategoryImpl) then) =
      __$$FilterByCategoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String category});
}

/// @nodoc
class __$$FilterByCategoryImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$FilterByCategoryImpl>
    implements _$$FilterByCategoryImplCopyWith<$Res> {
  __$$FilterByCategoryImplCopyWithImpl(_$FilterByCategoryImpl _value,
      $Res Function(_$FilterByCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
  }) {
    return _then(_$FilterByCategoryImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FilterByCategoryImpl implements FilterByCategory {
  const _$FilterByCategoryImpl({required this.category});

  @override
  final String category;

  @override
  String toString() {
    return 'InventoryEvent.filterByCategory(category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterByCategoryImpl &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterByCategoryImplCopyWith<_$FilterByCategoryImpl> get copyWith =>
      __$$FilterByCategoryImplCopyWithImpl<_$FilterByCategoryImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return filterByCategory(category);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return filterByCategory?.call(category);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (filterByCategory != null) {
      return filterByCategory(category);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return filterByCategory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return filterByCategory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (filterByCategory != null) {
      return filterByCategory(this);
    }
    return orElse();
  }
}

abstract class FilterByCategory implements InventoryEvent {
  const factory FilterByCategory({required final String category}) =
      _$FilterByCategoryImpl;

  String get category;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterByCategoryImplCopyWith<_$FilterByCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResolveConflictKeepLocalImplCopyWith<$Res> {
  factory _$$ResolveConflictKeepLocalImplCopyWith(
          _$ResolveConflictKeepLocalImpl value,
          $Res Function(_$ResolveConflictKeepLocalImpl) then) =
      __$$ResolveConflictKeepLocalImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$ResolveConflictKeepLocalImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$ResolveConflictKeepLocalImpl>
    implements _$$ResolveConflictKeepLocalImplCopyWith<$Res> {
  __$$ResolveConflictKeepLocalImplCopyWithImpl(
      _$ResolveConflictKeepLocalImpl _value,
      $Res Function(_$ResolveConflictKeepLocalImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$ResolveConflictKeepLocalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ResolveConflictKeepLocalImpl implements ResolveConflictKeepLocal {
  const _$ResolveConflictKeepLocalImpl({required this.id});

  @override
  final int id;

  @override
  String toString() {
    return 'InventoryEvent.resolveConflictKeepLocal(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResolveConflictKeepLocalImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResolveConflictKeepLocalImplCopyWith<_$ResolveConflictKeepLocalImpl>
      get copyWith => __$$ResolveConflictKeepLocalImplCopyWithImpl<
          _$ResolveConflictKeepLocalImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return resolveConflictKeepLocal(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return resolveConflictKeepLocal?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (resolveConflictKeepLocal != null) {
      return resolveConflictKeepLocal(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return resolveConflictKeepLocal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return resolveConflictKeepLocal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (resolveConflictKeepLocal != null) {
      return resolveConflictKeepLocal(this);
    }
    return orElse();
  }
}

abstract class ResolveConflictKeepLocal implements InventoryEvent {
  const factory ResolveConflictKeepLocal({required final int id}) =
      _$ResolveConflictKeepLocalImpl;

  int get id;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResolveConflictKeepLocalImplCopyWith<_$ResolveConflictKeepLocalImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResolveConflictUseServerImplCopyWith<$Res> {
  factory _$$ResolveConflictUseServerImplCopyWith(
          _$ResolveConflictUseServerImpl value,
          $Res Function(_$ResolveConflictUseServerImpl) then) =
      __$$ResolveConflictUseServerImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$ResolveConflictUseServerImplCopyWithImpl<$Res>
    extends _$InventoryEventCopyWithImpl<$Res, _$ResolveConflictUseServerImpl>
    implements _$$ResolveConflictUseServerImplCopyWith<$Res> {
  __$$ResolveConflictUseServerImplCopyWithImpl(
      _$ResolveConflictUseServerImpl _value,
      $Res Function(_$ResolveConflictUseServerImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$ResolveConflictUseServerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ResolveConflictUseServerImpl implements ResolveConflictUseServer {
  const _$ResolveConflictUseServerImpl({required this.id});

  @override
  final int id;

  @override
  String toString() {
    return 'InventoryEvent.resolveConflictUseServer(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResolveConflictUseServerImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResolveConflictUseServerImplCopyWith<_$ResolveConflictUseServerImpl>
      get copyWith => __$$ResolveConflictUseServerImplCopyWithImpl<
          _$ResolveConflictUseServerImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadInventory,
    required TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        addItem,
    required TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)
        updateItem,
    required TResult Function(int id) deleteItem,
    required TResult Function(String query) searchInventory,
    required TResult Function(String category) filterByCategory,
    required TResult Function(int id) resolveConflictKeepLocal,
    required TResult Function(int id) resolveConflictUseServer,
  }) {
    return resolveConflictUseServer(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadInventory,
    TResult? Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult? Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult? Function(int id)? deleteItem,
    TResult? Function(String query)? searchInventory,
    TResult? Function(String category)? filterByCategory,
    TResult? Function(int id)? resolveConflictKeepLocal,
    TResult? Function(int id)? resolveConflictUseServer,
  }) {
    return resolveConflictUseServer?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadInventory,
    TResult Function(
            String itemName,
            String category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double quantity,
            double? reservedQuantity,
            String unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        addItem,
    TResult Function(
            int id,
            String? itemName,
            String? category,
            String? lotCode,
            String? sourceType,
            String? sourceRef,
            String? sourceLabel,
            double? quantity,
            double? reservedQuantity,
            String? unit,
            int? minStock,
            String? supplier,
            String? supplierId,
            double? unitPrice,
            double? totalValue,
            String? notes,
            DateTime? expiryDate,
            int? freshnessHours,
            DateTime? lastRestock)?
        updateItem,
    TResult Function(int id)? deleteItem,
    TResult Function(String query)? searchInventory,
    TResult Function(String category)? filterByCategory,
    TResult Function(int id)? resolveConflictKeepLocal,
    TResult Function(int id)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (resolveConflictUseServer != null) {
      return resolveConflictUseServer(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadInventory value) loadInventory,
    required TResult Function(AddItem value) addItem,
    required TResult Function(UpdateItem value) updateItem,
    required TResult Function(DeleteItem value) deleteItem,
    required TResult Function(SearchInventory value) searchInventory,
    required TResult Function(FilterByCategory value) filterByCategory,
    required TResult Function(ResolveConflictKeepLocal value)
        resolveConflictKeepLocal,
    required TResult Function(ResolveConflictUseServer value)
        resolveConflictUseServer,
  }) {
    return resolveConflictUseServer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadInventory value)? loadInventory,
    TResult? Function(AddItem value)? addItem,
    TResult? Function(UpdateItem value)? updateItem,
    TResult? Function(DeleteItem value)? deleteItem,
    TResult? Function(SearchInventory value)? searchInventory,
    TResult? Function(FilterByCategory value)? filterByCategory,
    TResult? Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult? Function(ResolveConflictUseServer value)? resolveConflictUseServer,
  }) {
    return resolveConflictUseServer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadInventory value)? loadInventory,
    TResult Function(AddItem value)? addItem,
    TResult Function(UpdateItem value)? updateItem,
    TResult Function(DeleteItem value)? deleteItem,
    TResult Function(SearchInventory value)? searchInventory,
    TResult Function(FilterByCategory value)? filterByCategory,
    TResult Function(ResolveConflictKeepLocal value)? resolveConflictKeepLocal,
    TResult Function(ResolveConflictUseServer value)? resolveConflictUseServer,
    required TResult orElse(),
  }) {
    if (resolveConflictUseServer != null) {
      return resolveConflictUseServer(this);
    }
    return orElse();
  }
}

abstract class ResolveConflictUseServer implements InventoryEvent {
  const factory ResolveConflictUseServer({required final int id}) =
      _$ResolveConflictUseServerImpl;

  int get id;

  /// Create a copy of InventoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResolveConflictUseServerImplCopyWith<_$ResolveConflictUseServerImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InventoryState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Loaded value) loaded,
    required TResult Function(Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Loaded value)? loaded,
    TResult? Function(Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Loaded value)? loaded,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryStateCopyWith<$Res> {
  factory $InventoryStateCopyWith(
          InventoryState value, $Res Function(InventoryState) then) =
      _$InventoryStateCopyWithImpl<$Res, InventoryState>;
}

/// @nodoc
class _$InventoryStateCopyWithImpl<$Res, $Val extends InventoryState>
    implements $InventoryStateCopyWith<$Res> {
  _$InventoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$InventoryStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'InventoryState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)
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
    TResult? Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Loaded value) loaded,
    required TResult Function(Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Loaded value)? loaded,
    TResult? Function(Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Loaded value)? loaded,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class Initial implements InventoryState {
  const factory Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$InventoryStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'InventoryState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)
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
    TResult? Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Loaded value) loaded,
    required TResult Function(Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Loaded value)? loaded,
    TResult? Function(Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Loaded value)? loaded,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class Loading implements InventoryState {
  const factory Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<InventoryItem> items, String? searchQuery, String? filterCategory});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$InventoryStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? searchQuery = freezed,
    Object? filterCategory = freezed,
  }) {
    return _then(_$LoadedImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InventoryItem>,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      filterCategory: freezed == filterCategory
          ? _value.filterCategory
          : filterCategory // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements Loaded {
  const _$LoadedImpl(
      {required final List<InventoryItem> items,
      this.searchQuery,
      this.filterCategory})
      : _items = items;

  final List<InventoryItem> _items;
  @override
  List<InventoryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? searchQuery;
  @override
  final String? filterCategory;

  @override
  String toString() {
    return 'InventoryState.loaded(items: $items, searchQuery: $searchQuery, filterCategory: $filterCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.filterCategory, filterCategory) ||
                other.filterCategory == filterCategory));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_items), searchQuery, filterCategory);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(items, searchQuery, filterCategory);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(items, searchQuery, filterCategory);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(items, searchQuery, filterCategory);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Loaded value) loaded,
    required TResult Function(Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Loaded value)? loaded,
    TResult? Function(Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Loaded value)? loaded,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class Loaded implements InventoryState {
  const factory Loaded(
      {required final List<InventoryItem> items,
      final String? searchQuery,
      final String? filterCategory}) = _$LoadedImpl;

  List<InventoryItem> get items;
  String? get searchQuery;
  String? get filterCategory;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$InventoryStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'InventoryState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)
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
    TResult? Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    TResult Function(List<InventoryItem> items, String? searchQuery,
            String? filterCategory)?
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
    required TResult Function(Initial value) initial,
    required TResult Function(Loading value) loading,
    required TResult Function(Loaded value) loaded,
    required TResult Function(Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loading value)? loading,
    TResult? Function(Loaded value)? loaded,
    TResult? Function(Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loading value)? loading,
    TResult Function(Loaded value)? loaded,
    TResult Function(Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error implements InventoryState {
  const factory Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of InventoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
