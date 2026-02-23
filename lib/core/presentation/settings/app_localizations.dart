import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Pamoja Twalima',
      'drawer_profile': 'Profile',
      'drawer_settings': 'Settings',
      'drawer_help': 'Help & Support',
      'drawer_about': 'About',
      'drawer_dark_mode': 'Dark Mode',
      'drawer_logout': 'Logout',
      'theme_dark_enabled': 'Dark mode enabled.',
      'theme_light_enabled': 'Light mode enabled.',
      'theme_system_enabled': 'Theme follows device setting.',
      'profile_title': 'Profile & Settings',
      'preferences': 'Preferences',
      'data_sync': 'Data & Sync',
      'about_section': 'About',
      'language_english': 'Language: English',
      'language_swahili': 'Language: Kiswahili',
      'theme': 'Theme',
      'sync_now': 'Sync Now',
      'manage_offline': 'Manage Offline Content',
      'audit_trail': 'Audit Trail',
      'privacy_terms': 'Privacy & Terms',
      'about_app': 'About Pamoja Twalima',
      'home_today': 'Today',
      'home_farm_snapshot': 'Farm Snapshot',
      'home_financial': 'Financial Overview',
      'home_alerts': 'Critical Alerts',
      'home_quick_actions': 'Quick Actions',
      'critical_alerts': 'Critical Alerts',
      'no_critical_alerts': 'No Critical Alerts',
      'everything_good': 'Everything looks good right now',
      'low_stock_alert': 'Low Stock Alert',
      'pending_tasks_alert': 'Pending Tasks',
      'financial_summary': 'Financial Summary',
      'view_all': 'View All',
      'todays_sales': "Today's Sales",
      'this_month': 'This Month',
      'production_value_today': "Today's Production Value",
      'quick_add_record': 'Add Record',
      'quick_sell': 'Sell',
      'quick_purchase': 'Purchase',
      'quick_tasks': 'Tasks',
      'notifications': 'Notifications',
      'close': 'Close',
      'no_new_notifications': 'No new notifications',
      'all_modules_healthy': 'All farm modules are in a healthy state.',
      'farm_management': 'Farm Management',
      'farm_overview': 'Overview',
      'farm_crops': 'Crops',
      'farm_animals': 'Animals',
      'farm_tasks': 'Tasks',
      'inventory': 'Inventory',
      'syncing_from_server': 'Syncing from server...',
      'sync_failed': 'Sync failed',
      'local_version_kept': 'Local version kept. Sync queued.',
      'server_version_applied': 'Server version applied.',
      'synced_items_from_server': 'Synced items from server',
      'sales': 'Sales',
      'performance': 'Performance',
      'total_revenue': 'Total Revenue',
      'pending': 'Pending',
      'transactions': 'Transactions',
      'paid': 'Paid',
      'average_order_value': 'Average order value',
    },
    'sw': {
      'app_name': 'Pamoja Twalima',
      'drawer_profile': 'Wasifu',
      'drawer_settings': 'Mipangilio',
      'drawer_help': 'Msaada',
      'drawer_about': 'Kuhusu',
      'drawer_dark_mode': 'Mandhari ya Giza',
      'drawer_logout': 'Toka',
      'theme_dark_enabled': 'Mandhari ya giza imewashwa.',
      'theme_light_enabled': 'Mandhari ya mwanga imewashwa.',
      'theme_system_enabled': 'Mandhari inafuata kifaa.',
      'profile_title': 'Wasifu na Mipangilio',
      'preferences': 'Mapendeleo',
      'data_sync': 'Data na Usawazishaji',
      'about_section': 'Kuhusu',
      'language_english': 'Lugha: Kiingereza',
      'language_swahili': 'Lugha: Kiswahili',
      'theme': 'Mandhari',
      'sync_now': 'Sawazisha Sasa',
      'manage_offline': 'Dhibiti Data Nje ya Mtandao',
      'audit_trail': 'Historia ya Mabadiliko',
      'privacy_terms': 'Faragha na Masharti',
      'about_app': 'Kuhusu Pamoja Twalima',
      'home_today': 'Leo',
      'home_farm_snapshot': 'Muhtasari wa Shamba',
      'home_financial': 'Muhtasari wa Fedha',
      'home_alerts': 'Tahadhari Muhimu',
      'home_quick_actions': 'Vitendo vya Haraka',
      'critical_alerts': 'Tahadhari Muhimu',
      'no_critical_alerts': 'Hakuna Tahadhari Muhimu',
      'everything_good': 'Kila kitu kiko sawa kwa sasa',
      'low_stock_alert': 'Tahadhari ya Hisa Chini',
      'pending_tasks_alert': 'Kazi Zinazosubiri',
      'financial_summary': 'Muhtasari wa Fedha',
      'view_all': 'Tazama Zote',
      'todays_sales': 'Mauzo ya Leo',
      'this_month': 'Mwezi Huu',
      'production_value_today': 'Thamani ya Uzalishaji wa Leo',
      'quick_add_record': 'Ongeza Rekodi',
      'quick_sell': 'Uza',
      'quick_purchase': 'Nunua',
      'quick_tasks': 'Kazi',
      'notifications': 'Arifa',
      'close': 'Funga',
      'no_new_notifications': 'Hakuna arifa mpya',
      'all_modules_healthy': 'Mifumo yote iko katika hali nzuri.',
      'farm_management': 'Usimamizi wa Shamba',
      'farm_overview': 'Muhtasari',
      'farm_crops': 'Mazao',
      'farm_animals': 'Wanyama',
      'farm_tasks': 'Kazi',
      'inventory': 'Hesabu',
      'syncing_from_server': 'Inasawazisha kutoka kwa seva...',
      'sync_failed': 'Usawazishaji umeshindikana',
      'local_version_kept': 'Toleo la ndani limehifadhiwa. Usawazishaji umewekwa.',
      'server_version_applied': 'Toleo la seva limetumika.',
      'synced_items_from_server': 'Vipengee vimesawazishwa kutoka seva',
      'sales': 'Mauzo',
      'performance': 'Utendaji',
      'total_revenue': 'Mapato Yote',
      'pending': 'Inasubiri',
      'transactions': 'Miamala',
      'paid': 'Imelipwa',
      'average_order_value': 'Wastani wa thamani ya oda',
    },
  };

  String tr(String key) {
    final languageCode = locale.languageCode;
    final localizedMap = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return localizedMap[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
