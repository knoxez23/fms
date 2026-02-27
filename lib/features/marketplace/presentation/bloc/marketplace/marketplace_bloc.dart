import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../application/marketplace_usecases.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';
part 'marketplace_bloc.freezed.dart';

@injectable
class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final Logger _logger = Logger();

  MarketplaceBloc(
    this._getProducts,
    this._addProduct,
    this._updateProduct,
    this._deleteProduct,
  ) : super(const MarketplaceState.initial()) {
    on<LoadMarketplace>(_onLoad);
    on<AddMarketplaceProduct>(_onAdd);
    on<UpdateMarketplaceProduct>(_onUpdate);
    on<DeleteMarketplaceProduct>(_onDelete);
  }

  Future<void> _onLoad(
    LoadMarketplace event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceState.loading());
    try {
      final products = await _getProducts.execute();
      emit(MarketplaceState.loaded(products: products));
    } catch (e) {
      _logger.e('Failed to load marketplace products', error: e);
      emit(const MarketplaceState.error(message: 'error_marketplace_load'));
    }
  }

  Future<void> _onAdd(
    AddMarketplaceProduct event,
    Emitter<MarketplaceState> emit,
  ) async {
    try {
      await _addProduct.execute(event.product);
      add(const MarketplaceEvent.load());
    } catch (e) {
      _logger.e('error_marketplace_add', error: e);
      emit(const MarketplaceState.error(message: 'error_marketplace_add'));
    }
  }

  Future<void> _onUpdate(
    UpdateMarketplaceProduct event,
    Emitter<MarketplaceState> emit,
  ) async {
    try {
      await _updateProduct.execute(event.product);
      add(const MarketplaceEvent.load());
    } catch (e) {
      _logger.e('error_marketplace_update', error: e);
      emit(const MarketplaceState.error(message: 'error_marketplace_update'));
    }
  }

  Future<void> _onDelete(
    DeleteMarketplaceProduct event,
    Emitter<MarketplaceState> emit,
  ) async {
    try {
      await _deleteProduct.execute(event.id);
      add(const MarketplaceEvent.load());
    } catch (e) {
      _logger.e('error_marketplace_delete', error: e);
      emit(const MarketplaceState.error(message: 'error_marketplace_delete'));
    }
  }
}
