class LocalData {
  static Map<String, dynamic> getFarmSummary() {
    return {
      "crops": 8,
      "livestock": 12,
      "salesToday": 2450,
    };
  }

  static List<Map<String, String>> getMarketPrices() {
    return [
      {"item": "Maize", "price": "Ksh 4,200 / 90kg bag"},
      {"item": "Beans", "price": "Ksh 6,000 / 90kg bag"},
      {"item": "Tomatoes", "price": "Ksh 2,800 / 90kg bag"},
      {"item": "Cabbages", "price": "Ksh 1,200 / 90kg bag"}
    ];
  }
}