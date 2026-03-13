import '../../../weather/domain/entities/weather_entities.dart';

enum OperationalInsightSeverity { critical, warning, info }

enum OperationalInsightAction { farm, tasks, inventory, business }

class OperationalInsight {
  final String id;
  final String title;
  final String description;
  final OperationalInsightSeverity severity;
  final OperationalInsightAction action;
  final String actionLabel;

  const OperationalInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.action,
    required this.actionLabel,
  });
}

class DashboardData {
  final Map<String, dynamic> summary;
  final WeatherSnapshot? weatherSnapshot;
  final List<OperationalInsight> insights;

  const DashboardData({
    required this.summary,
    required this.weatherSnapshot,
    this.insights = const [],
  });
}
