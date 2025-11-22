class TipData {
  static final _tips = [
    "Apply mulch to retain soil moisture during dry spells.",
    "Rotate crops to maintain soil fertility and reduce pests.",
    "Collect rainwater for irrigation during the dry season.",
    "Use compost instead of chemical fertilizers to enrich soil.",
    "Inspect your livestock daily for signs of illness.",
    "Early planting ensures better yields for most crops.",
    "Always store grains in airtight containers to prevent pests.",
  ];

  static String getTipOfTheDay() {
    final day = DateTime.now().day;
    return _tips[day % _tips.length];
  }
}
