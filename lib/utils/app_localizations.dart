import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
            context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _en = {
    'marketplace':    'Marketplace',
    'chat':           'Messages',
    'tracking':       'Tracking',
    'profile':        'Profile',
    'home':           'Home',
    'search':         'Search listings...',
    'post_listing':   'Post listing',
    'browse':         'Browse',
    'my_orders':      'My Orders',
    'messages':       'Messages',
    'add_to_cart':    'Add to Cart',
    'view_cart':      'View Cart',
    'place_order':    'Place Order',
    'contact_seller': 'Contact Seller',
    'sign_out':       'Sign out',
    'app_theme':      'App theme',
    'language':       'Language',
    'edit_profile':   'Edit profile',
    'notifications':  'Notifications',
    'privacy':        'Privacy & Security',
    'help':           'Help & Support',
    'terms':          'Terms & Conditions',
    'about':          'About MTC',
    'no_listings':    'No listings found',
    'cart_empty':     'Cart is empty',
    'order_placed':   'Order Placed!',
    'good_morning':   'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening':   'Good evening',
    'recent_activity':'Recent activity',
    'quick_actions':  'Quick actions',
    'secondhand':     'Secondhand',
    'sell_used':      'Sell used items',
  };

  static const _hi = {
    'marketplace':    'बाज़ार',
    'chat':           'संदेश',
    'tracking':       'ट्रैकिंग',
    'profile':        'प्रोफ़ाइल',
    'home':           'होम',
    'search':         'लिस्टिंग खोजें...',
    'post_listing':   'लिस्टिंग पोस्ट करें',
    'browse':         'ब्राउज़ करें',
    'my_orders':      'मेरे ऑर्डर',
    'messages':       'संदेश',
    'add_to_cart':    'कार्ट में जोड़ें',
    'view_cart':      'कार्ट देखें',
    'place_order':    'ऑर्डर दें',
    'contact_seller': 'विक्रेता से संपर्क करें',
    'sign_out':       'साइन आउट',
    'app_theme':      'थीम',
    'language':       'भाषा',
    'edit_profile':   'प्रोफ़ाइल संपादित करें',
    'notifications':  'सूचनाएं',
    'privacy':        'गोपनीयता',
    'help':           'सहायता',
    'terms':          'नियम और शर्तें',
    'about':          'MTC के बारे में',
    'no_listings':    'कोई लिस्टिंग नहीं',
    'cart_empty':     'कार्ट खाली है',
    'order_placed':   'ऑर्डर दिया गया!',
    'good_morning':   'शुभ प्रभात',
    'good_afternoon': 'नमस्ते',
    'good_evening':   'शुभ संध्या',
    'recent_activity':'हाल की गतिविधि',
    'quick_actions':  'त्वरित क्रियाएं',
    'secondhand':     'सेकेंडहैंड',
    'sell_used':      'पुरानी चीज़ें बेचें',
  };

  static const _ta = {
    'marketplace':    'சந்தை',
    'chat':           'செய்திகள்',
    'tracking':       'கண்காணிப்பு',
    'profile':        'சுயவிவரம்',
    'home':           'முகப்பு',
    'search':         'தேடுக...',
    'post_listing':   'பட்டியல் இடு',
    'browse':         'உலாவு',
    'my_orders':      'என் ஆர்டர்கள்',
    'messages':       'செய்திகள்',
    'add_to_cart':    'கார்ட்டில் சேர்',
    'view_cart':      'கார்ட் பார்',
    'place_order':    'ஆர்டர் கொடு',
    'contact_seller': 'விற்பவரை தொடர்பு கொள்',
    'sign_out':       'வெளியேறு',
    'app_theme':      'தீம்',
    'language':       'மொழி',
    'edit_profile':   'சுயவிவரம் திருத்து',
    'notifications':  'அறிவிப்புகள்',
    'privacy':        'தனியுரிமை',
    'help':           'உதவி',
    'terms':          'விதிமுறைகள்',
    'about':          'MTC பற்றி',
    'no_listings':    'பட்டியல் இல்லை',
    'cart_empty':     'கார்ட் காலி',
    'order_placed':   'ஆர்டர் கொடுக்கப்பட்டது!',
    'good_morning':   'காலை வணக்கம்',
    'good_afternoon': 'மதிய வணக்கம்',
    'good_evening':   'மாலை வணக்கம்',
    'recent_activity':'சமீபத்திய செயல்பாடு',
    'quick_actions':  'விரைவு செயல்கள்',
    'secondhand':     'பயன்படுத்தியவை',
    'sell_used':      'பழைய பொருட்கள் விற்க',
  };

  static const _ar = {
    'marketplace':    'السوق',
    'chat':           'الرسائل',
    'tracking':       'التتبع',
    'profile':        'الملف',
    'home':           'الرئيسية',
    'search':         'ابحث...',
    'post_listing':   'نشر إعلان',
    'browse':         'تصفح',
    'my_orders':      'طلباتي',
    'messages':       'الرسائل',
    'add_to_cart':    'أضف للسلة',
    'view_cart':      'عرض السلة',
    'place_order':    'تقديم الطلب',
    'contact_seller': 'تواصل مع البائع',
    'sign_out':       'تسجيل الخروج',
    'app_theme':      'المظهر',
    'language':       'اللغة',
    'edit_profile':   'تعديل الملف',
    'notifications':  'الإشعارات',
    'privacy':        'الخصوصية',
    'help':           'المساعدة',
    'terms':          'الشروط',
    'about':          'حول MTC',
    'no_listings':    'لا توجد قوائم',
    'cart_empty':     'السلة فارغة',
    'order_placed':   'تم الطلب!',
    'good_morning':   'صباح الخير',
    'good_afternoon': 'مساء الخير',
    'good_evening':   'مساء النور',
    'recent_activity':'النشاط الأخير',
    'quick_actions':  'الإجراءات السريعة',
    'secondhand':     'مستعمل',
    'sell_used':      'بيع المستعمل',
  };

  static const _fr = {
    'marketplace':    'Marché',
    'chat':           'Messages',
    'tracking':       'Suivi',
    'profile':        'Profil',
    'home':           'Accueil',
    'search':         'Rechercher...',
    'post_listing':   'Publier',
    'browse':         'Parcourir',
    'my_orders':      'Mes commandes',
    'messages':       'Messages',
    'add_to_cart':    'Ajouter au panier',
    'view_cart':      'Voir le panier',
    'place_order':    'Commander',
    'contact_seller': 'Contacter le vendeur',
    'sign_out':       'Déconnexion',
    'app_theme':      'Thème',
    'language':       'Langue',
    'edit_profile':   'Modifier le profil',
    'notifications':  'Notifications',
    'privacy':        'Confidentialité',
    'help':           'Aide',
    'terms':          'Conditions',
    'about':          'À propos',
    'no_listings':    'Aucune annonce',
    'cart_empty':     'Panier vide',
    'order_placed':   'Commande passée!',
    'good_morning':   'Bonjour',
    'good_afternoon': 'Bon après-midi',
    'good_evening':   'Bonsoir',
    'recent_activity':'Activité récente',
    'quick_actions':  'Actions rapides',
    'secondhand':     'Occasion',
    'sell_used':      'Vendre d\'occasion',
  };

  String t(String key) {
    final lang = locale.languageCode;
    final map = lang == 'hi' ? _hi
              : lang == 'ta' ? _ta
              : lang == 'ar' ? _ar
              : lang == 'fr' ? _fr
              : _en;
    return map[key] ?? _en[key] ?? key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'ta', 'ar', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}