import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/sale_entity.dart';
import '../../../application/sales_usecases.dart';

part 'sales_event.dart';
part 'sales_state.dart';
part 'sales_bloc.freezed.dart';

@injectable
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSales _getSales;
  final AddSale _addSale;
  final UpdateSale _updateSale;
  final DeleteSale _deleteSale;
  final Logger _logger = Logger();

  SalesBloc(
    this._getSales,
    this._addSale,
    this._updateSale,
    this._deleteSale,
  ) : super(const SalesState.initial()) {
    on<LoadSales>(_onLoadSales);
    on<AddSaleEvent>(_onAddSale);
    on<UpdateSaleEvent>(_onUpdateSale);
    on<DeleteSaleEvent>(_onDeleteSale);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SalesState> emit) async {
    emit(const SalesState.loading());
    try {
      final sales = await _getSales.execute();
      emit(SalesState.loaded(sales: sales));
    } catch (e) {
      _logger.e('Failed to load sales', error: e);
      emit(const SalesState.error(message: 'Failed to load sales'));
    }
  }

  Future<void> _onAddSale(AddSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await _addSale.execute(event.sale);
      add(const SalesEvent.loadSales());
    } catch (e) {
      _logger.e('Failed to add sale', error: e);
      emit(const SalesState.error(message: 'Failed to add sale'));
    }
  }

  Future<void> _onUpdateSale(UpdateSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await _updateSale.execute(event.sale);
      add(const SalesEvent.loadSales());
    } catch (e) {
      _logger.e('Failed to update sale', error: e);
      emit(const SalesState.error(message: 'Failed to update sale'));
    }
  }

  Future<void> _onDeleteSale(DeleteSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await _deleteSale.execute(event.id);
      add(const SalesEvent.loadSales());
    } catch (e) {
      _logger.e('Failed to delete sale', error: e);
      emit(const SalesState.error(message: 'Failed to delete sale'));
    }
  }
}
