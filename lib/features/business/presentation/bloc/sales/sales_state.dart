part of 'sales_bloc.dart';

@freezed
class SalesState with _$SalesState {
  const factory SalesState.initial() = SalesInitial;
  const factory SalesState.loading() = SalesLoading;
  const factory SalesState.loaded({required List<SaleEntity> sales}) = SalesLoaded;
  const factory SalesState.error({required String message}) = SalesError;
}
