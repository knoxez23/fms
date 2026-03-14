import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../application/inventory_usecases.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';
part 'inventory_bloc.freezed.dart';

@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventory _getInventory;
  final AddInventoryItem _addInventoryItem;
  final UpdateInventoryItem _updateInventoryItem;
  final DeleteInventoryItem _deleteInventoryItem;
  final ResolveInventoryConflictKeepLocal _resolveConflictKeepLocal;
  final ResolveInventoryConflictUseServer _resolveConflictUseServer;
  final Logger _logger = Logger();

  List<InventoryItem> _allItems = [];

  InventoryBloc(
    this._getInventory,
    this._addInventoryItem,
    this._updateInventoryItem,
    this._deleteInventoryItem,
    this._resolveConflictKeepLocal,
    this._resolveConflictUseServer,
  ) : super(const InventoryState.initial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddItem>(_onAddItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<SearchInventory>(_onSearchInventory);
    on<FilterByCategory>(_onFilterByCategory);
    on<ResolveConflictKeepLocal>(_onResolveConflictKeepLocal);
    on<ResolveConflictUseServer>(_onResolveConflictUseServer);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryState.loading());

    try {
      _allItems = await _getInventory.execute();
      emit(InventoryState.loaded(items: _allItems));
      _logger.i('Inventory loaded: ${_allItems.length} items');
    } catch (e) {
      _logger.e('Failed to load inventory', error: e);
      emit(const InventoryState.error(message: 'Failed to load inventory'));
    }
  }

  Future<void> _onAddItem(
    AddItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final item = InventoryItem(
        itemName: event.itemName,
        category: event.category,
        lotCode: event.lotCode,
        sourceType: event.sourceType,
        sourceRef: event.sourceRef,
        sourceLabel: event.sourceLabel,
        quantity: event.quantity,
        reservedQuantity: event.reservedQuantity ?? 0,
        unit: event.unit,
        minStock: event.minStock ?? 0,
        supplier: event.supplier,
        supplierId: event.supplierId,
        unitPrice: event.unitPrice,
        totalValue: event.totalValue,
        expiryDate: event.expiryDate,
        freshnessHours: event.freshnessHours,
        lastRestock: event.lastRestock,
        isSynced: false,
      );
      await _addInventoryItem.execute(item);

      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item added: ${event.itemName}');
    } catch (e) {
      _logger.e('Failed to add inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to add item'));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final current = _allItems.firstWhere(
        (item) => item.id == event.id.toString(),
        orElse: () => InventoryItem(
          id: event.id.toString(),
          itemName: event.itemName ?? '',
          category: event.category ?? '',
          lotCode: event.lotCode,
          sourceType: event.sourceType,
          sourceRef: event.sourceRef,
          sourceLabel: event.sourceLabel,
          quantity: event.quantity ?? 0,
          reservedQuantity: event.reservedQuantity ?? 0,
          unit: event.unit ?? '',
          minStock: event.minStock ?? 0,
        ),
      );

      final updated = InventoryItem(
        // Keep valuation consistent whenever quantity or unit price changes.
        // If caller explicitly provided totalValue, prefer it.
        // Otherwise recalculate from effective quantity * effective unit price.
        id: current.id,
        itemName: event.itemName ?? current.itemName,
        category: event.category ?? current.category,
        lotCode: event.lotCode ?? current.lotCode,
        sourceType: event.sourceType ?? current.sourceType,
        sourceRef: event.sourceRef ?? current.sourceRef,
        sourceLabel: event.sourceLabel ?? current.sourceLabel,
        quantity: event.quantity ?? current.quantity,
        reservedQuantity: event.reservedQuantity ?? current.reservedQuantity,
        unit: event.unit ?? current.unit,
        minStock: event.minStock ?? current.minStock,
        supplier: event.supplier ?? current.supplier,
        supplierId: event.supplierId ?? current.supplierId,
        unitPrice: event.unitPrice ?? current.unitPrice,
        totalValue: event.totalValue ??
            ((event.unitPrice ?? current.unitPrice) != null
                ? (event.quantity ?? current.quantity) *
                    ((event.unitPrice ?? current.unitPrice)!)
                : current.totalValue),
        expiryDate: event.expiryDate ?? current.expiryDate,
        freshnessHours: event.freshnessHours ?? current.freshnessHours,
        lastRestock: event.lastRestock ?? current.lastRestock,
        isSynced: false,
        hasConflict: current.hasConflict,
      );

      await _updateInventoryItem.execute(updated);

      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item updated: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to update inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to update item'));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _deleteInventoryItem.execute(event.id.toString());

      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item deleted: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to delete inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to delete item'));
    }
  }

  Future<void> _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryState> emit,
  ) async {
    final query = event.query.toLowerCase();

    final filtered = _allItems.where((item) {
      return item.itemName.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          (item.supplier?.toLowerCase().contains(query) ?? false);
    }).toList();

    emit(InventoryState.loaded(
      items: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<InventoryState> emit,
  ) async {
    final filtered = _allItems.where((item) {
      return item.category == event.category;
    }).toList();

    emit(InventoryState.loaded(
      items: filtered,
      filterCategory: event.category,
    ));
  }

  Future<void> _onResolveConflictKeepLocal(
    ResolveConflictKeepLocal event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _resolveConflictKeepLocal.execute(event.id.toString());
      add(const InventoryEvent.loadInventory());
      _logger
          .i('Inventory conflict resolved with local version: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to resolve conflict (keep local)', error: e);
      emit(const InventoryState.error(message: 'Failed to resolve conflict'));
    }
  }

  Future<void> _onResolveConflictUseServer(
    ResolveConflictUseServer event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _resolveConflictUseServer.execute(event.id.toString());
      add(const InventoryEvent.loadInventory());
      _logger
          .i('Inventory conflict resolved with server version: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to resolve conflict (use server)', error: e);
      emit(const InventoryState.error(message: 'Failed to resolve conflict'));
    }
  }
}
