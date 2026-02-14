class OverviewSummaryEntity {
  final int totalCrops;
  final int totalAnimals;
  final double balance;
  final int pendingTasks;
  final int lowStockItems;

  const OverviewSummaryEntity({
    required this.totalCrops,
    required this.totalAnimals,
    required this.balance,
    required this.pendingTasks,
    required this.lowStockItems,
  });
}
