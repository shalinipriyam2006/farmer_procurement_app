enum AppLanguage { english, tamil }

class AppTranslations {
  static final Map<String, Map<AppLanguage, String>> _values = {
    // General / Navigation
    'app_title': {
      AppLanguage.english: 'Farmer Procurement',
      AppLanguage.tamil: 'உழவர் கொள்முதல்',
    },
    'app_subtitle': {
      AppLanguage.english: 'Direct Purchase Centre Portal',
      AppLanguage.tamil: 'நேரடி நெல் கொள்முதல் நிலைய போர்டல்',
    },
    'home': {AppLanguage.english: 'Home', AppLanguage.tamil: 'முகப்பு'},
    'token': {AppLanguage.english: 'Token', AppLanguage.tamil: 'டோக்கன்'},
    'queue': {AppLanguage.english: 'Queue', AppLanguage.tamil: 'வரிசை'},
    'status': {AppLanguage.english: 'Status', AppLanguage.tamil: 'நிலை'},
    'profile': {AppLanguage.english: 'Profile', AppLanguage.tamil: 'சுயவிவரம்'},
    'officer_mode': {
      AppLanguage.english: 'Officer Mode',
      AppLanguage.tamil: 'அதிகாரி பயன்முறை',
    },
    'officer_dashboard': {
      AppLanguage.english: 'Officer Control Dashboard',
      AppLanguage.tamil: 'அதிகாரி கட்டுப்பாட்டு பலகை',
    },
    'switch_to_farmer': {
      AppLanguage.english: 'Switch to Farmer View',
      AppLanguage.tamil: 'விவசாயி பார்வைக்கு மாறவும்',
    },

    // Auth
    'farmer_login': {
      AppLanguage.english: 'Farmer Login',
      AppLanguage.tamil: 'விவசாயி உள்நுழைவு',
    },
    'enter_mobile': {
      AppLanguage.english: 'Enter Mobile Number',
      AppLanguage.tamil: 'கைபேசி எண்ணை உள்ளிடவும்',
    },
    'mobile_hint': {
      AppLanguage.english: '10-digit mobile number',
      AppLanguage.tamil: '10 இலக்க கைபேசி எண்',
    },
    'send_otp': {
      AppLanguage.english: 'Get OTP',
      AppLanguage.tamil: 'OTP பெறுக',
    },
    'enter_otp': {
      AppLanguage.english: 'Enter OTP',
      AppLanguage.tamil: 'OTP குறியீட்டை உள்ளிடவும்',
    },
    'verify_login': {
      AppLanguage.english: 'Verify & Login',
      AppLanguage.tamil: 'சரிபார்த்து உள்நுழைக',
    },
    'use_demo_account': {
      AppLanguage.english: 'Use Demo Farmer Account',
      AppLanguage.tamil: 'மாதிரி கணக்கை பயன்படுத்தவும்',
    },
    'new_farmer_register': {
      AppLanguage.english: 'New Farmer? Register Here',
      AppLanguage.tamil: 'புதிய விவசாயியா? பதிவு செய்க',
    },
    'farmer_registration': {
      AppLanguage.english: 'Farmer Registration',
      AppLanguage.tamil: 'விவசாயி புதிய பதிவு',
    },
    'full_name': {
      AppLanguage.english: 'Full Name',
      AppLanguage.tamil: 'முழு பெயர்',
    },
    'farmer_id': {
      AppLanguage.english: 'Farmer ID (Govt/Kisan ID)',
      AppLanguage.tamil: 'விவசாயி அடையாள எண் (உழவர் அட்டை)',
    },
    'village': {
      AppLanguage.english: 'Village / Town',
      AppLanguage.tamil: 'கிராமம் / ஊர்',
    },
    'district': {
      AppLanguage.english: 'District',
      AppLanguage.tamil: 'மாவட்டம்',
    },
    'pref_centre': {
      AppLanguage.english: 'Preferred Procurement Centre',
      AppLanguage.tamil: 'விருப்பமான கொள்முதல் நிலையம்',
    },
    'register_now': {
      AppLanguage.english: 'Complete Registration',
      AppLanguage.tamil: 'பதிவை முடிக்கவும்',
    },

    // Dashboard
    'welcome_farmer': {
      AppLanguage.english: 'Welcome,',
      AppLanguage.tamil: 'வணக்கம்,',
    },
    'today_schedule': {
      AppLanguage.english: "Today's Procurement Schedule",
      AppLanguage.tamil: 'இன்றைய கொள்முதல் அட்டவணை',
    },
    'selected_centre': {
      AppLanguage.english: 'Procurement Centre',
      AppLanguage.tamil: 'கொள்முதல் நிலையம்',
    },
    'active_token': {
      AppLanguage.english: 'Your Active Token',
      AppLanguage.tamil: 'உங்கள் டோக்கன்',
    },
    'no_active_token': {
      AppLanguage.english: 'No active token booked yet',
      AppLanguage.tamil: 'செயலில் டோக்கன் எதுவும் இல்லை',
    },
    'book_token_now': {
      AppLanguage.english: 'Book Digital Token',
      AppLanguage.tamil: 'டோக்கன் முன்பதிவு செய்க',
    },
    'current_queue_pos': {
      AppLanguage.english: 'Your Queue Position',
      AppLanguage.tamil: 'உங்கள் வரிசை எண்',
    },
    'farmers_ahead': {
      AppLanguage.english: 'Farmers Ahead',
      AppLanguage.tamil: 'முன்னால் உள்ளவர்கள்',
    },
    'est_waiting_time': {
      AppLanguage.english: 'Estimated Waiting Time',
      AppLanguage.tamil: 'தோராயமான காத்திருப்பு நேரம்',
    },
    'procurement_status': {
      AppLanguage.english: 'Procurement Status',
      AppLanguage.tamil: 'கொள்முதல் நிலை',
    },
    'view_timeline': {
      AppLanguage.english: 'View Live Timeline',
      AppLanguage.tamil: 'முழு நிலையை பார்க்க',
    },
    'quick_actions': {
      AppLanguage.english: 'Quick Actions',
      AppLanguage.tamil: 'விரைவு சேவைகள்',
    },
    'view_centres': {
      AppLanguage.english: 'All Centres',
      AppLanguage.tamil: 'அனைத்து நிலையங்கள்',
    },
    'view_payment': {
      AppLanguage.english: 'Payment Slip',
      AppLanguage.tamil: 'பணம் விவரம்',
    },
    'help_support': {
      AppLanguage.english: 'Toll-free Help: 1800-425-2441',
      AppLanguage.tamil: 'கட்டணமில்லா உதவி: 1800-425-2441',
    },

    // Token Generation
    'book_digital_token': {
      AppLanguage.english: 'Generate Digital Token',
      AppLanguage.tamil: 'டிஜிட்டல் டோக்கன் உருவாக்குக',
    },
    'step_centre': {
      AppLanguage.english: '1. Select Procurement Centre',
      AppLanguage.tamil: '1. கொள்முதல் நிலையத்தை தேர்ந்தெடுக்கவும்',
    },
    'step_date': {
      AppLanguage.english: '2. Select Available Date',
      AppLanguage.tamil: '2. வருகை தரும் தேதியை தேர்ந்தெடுக்கவும்',
    },
    'step_slot': {
      AppLanguage.english: '3. Select Time Slot',
      AppLanguage.tamil: '3. நேரத்தை தேர்ந்தெடுக்கவும்',
    },
    'step_crop': {
      AppLanguage.english: '4. Crop & Quantity (Quintals / Bags)',
      AppLanguage.tamil: '4. பயிர் & அளவு (குவிண்டால் / மூட்டைகள்)',
    },
    'generate_token_btn': {
      AppLanguage.english: 'Generate My Token',
      AppLanguage.tamil: 'எனக்கான டோக்கனை உருவாக்கு',
    },
    'token_generated_success': {
      AppLanguage.english: 'Token Generated Successfully!',
      AppLanguage.tamil: 'டோக்கன் வெற்றிகரமாக உருவாக்கப்பட்டது!',
    },
    'token_number': {
      AppLanguage.english: 'Token Number',
      AppLanguage.tamil: 'டோக்கன் எண்',
    },
    'slot_time': {
      AppLanguage.english: 'Time Slot',
      AppLanguage.tamil: 'நேர இடைவெளி',
    },
    'date': {AppLanguage.english: 'Date', AppLanguage.tamil: 'தேதி'},

    // Live Queue
    'live_queue_system': {
      AppLanguage.english: 'Live Queue Tracking',
      AppLanguage.tamil: 'நேரலை வரிசை கண்காணிப்பு',
    },
    'serving_now': {
      AppLanguage.english: 'Currently Serving Token',
      AppLanguage.tamil: 'தற்போது நடைபெறும் டோக்கன்',
    },
    'your_turn_approaching': {
      AppLanguage.english:
          'Your turn is approaching! Please remain near the entry gate.',
      AppLanguage.tamil:
          'உங்கள் முறை விரைவில் வரவுள்ளது! நுழைவு வாயில் அருகே இருக்கவும்.',
    },
    'your_turn_now': {
      AppLanguage.english:
          'It is your turn! Please proceed to the weighing scale.',
      AppLanguage.tamil:
          'உங்கள் முறை வந்துவிட்டது! எடை போடும் இடத்திற்கு செல்லவும்.',
    },
    'queue_status': {
      AppLanguage.english: 'Queue Speed / Status',
      AppLanguage.tamil: 'வரிசை வேகம் / நிலை',
    },
    'queue_normal': {
      AppLanguage.english: 'Moving Smoothly (Approx 12 mins per farmer)',
      AppLanguage.tamil: 'சீரான வேகம் (ஒருவருக்கு சுமார் 12 நிமிடங்கள்)',
    },

    // 8 Stages
    'stage_1': {
      AppLanguage.english: 'Token Generated',
      AppLanguage.tamil: 'டோக்கன் பெறப்பட்டது',
    },
    'stage_2': {
      AppLanguage.english: 'Waiting in Yard',
      AppLanguage.tamil: 'யார்டில் காத்திருப்பு',
    },
    'stage_3': {
      AppLanguage.english: 'Called for Entry',
      AppLanguage.tamil: 'அழைக்கப்பட்டது',
    },
    'stage_4': {
      AppLanguage.english: 'Weighing',
      AppLanguage.tamil: 'எடை போடுதல்',
    },
    'stage_5': {
      AppLanguage.english: 'Quality Check',
      AppLanguage.tamil: 'தர பரிசோதனை',
    },
    'stage_6': {
      AppLanguage.english: 'Accepted',
      AppLanguage.tamil: 'ஏற்றுக்கொள்ளப்பட்டது',
    },
    'stage_7': {
      AppLanguage.english: 'Payment Processing',
      AppLanguage.tamil: 'பணம் செயலாக்கத்தில்',
    },
    'stage_8': {
      AppLanguage.english: 'Payment Completed',
      AppLanguage.tamil: 'பணம் வரவு வைக்கப்பட்டது',
    },

    // Payments
    'payment_summary': {
      AppLanguage.english: 'Procurement Payment Receipt',
      AppLanguage.tamil: 'கொள்முதல் பண ரசீது',
    },
    'procured_quantity': {
      AppLanguage.english: 'Total Quantity Procured',
      AppLanguage.tamil: 'கொள்முதல் செய்யப்பட்ட அளவு',
    },
    'msp_rate': {
      AppLanguage.english: 'Govt MSP Rate (Per Quintal)',
      AppLanguage.tamil: 'அரசு ஆதரவு விலை (குவிண்டாலுக்கு)',
    },
    'total_amount': {
      AppLanguage.english: 'Total Amount',
      AppLanguage.tamil: 'மொத்த தொகை',
    },
    'deductions': {
      AppLanguage.english: 'Moisture/Handling Deductions',
      AppLanguage.tamil: 'ஈரப்பதம்/கையாளுதல் கழிவு',
    },
    'net_amount': {
      AppLanguage.english: 'Net Payout to Bank',
      AppLanguage.tamil: 'வங்கிக்கு வரவு வைக்கப்படும் நிகர தொகை',
    },
    'payment_date': {
      AppLanguage.english: 'Payment Date',
      AppLanguage.tamil: 'பணம் செலுத்திய தேதி',
    },
    'bank_ref': {
      AppLanguage.english: 'PFMS / Bank Ref No',
      AppLanguage.tamil: 'வங்கி பரிவர்த்தனை எண்',
    },
    'bank_account': {
      AppLanguage.english: 'Credited Bank Account',
      AppLanguage.tamil: 'வரவு கணக்கு',
    },
    'status_paid': {
      AppLanguage.english: 'Transferred via DBT',
      AppLanguage.tamil: 'நேரடி மானியமாக அனுப்பப்பட்டது',
    },
    'status_pending': {
      AppLanguage.english: 'Processing with Bank Treasury',
      AppLanguage.tamil: 'வங்கி செயலாக்கத்தில் உள்ளது',
    },

    // Notifications
    'notifications': {
      AppLanguage.english: 'Notifications',
      AppLanguage.tamil: 'அறிவிப்புகள்',
    },
    'no_notifications': {
      AppLanguage.english: 'No new notifications',
      AppLanguage.tamil: 'புதிய அறிவிப்புகள் எதுவும் இல்லை',
    },

    // Centres
    'procurement_centres': {
      AppLanguage.english: 'Procurement Centres',
      AppLanguage.tamil: 'கொள்முதல் நிலையங்கள்',
    },
    'working_hours': {
      AppLanguage.english: 'Working Hours',
      AppLanguage.tamil: 'வேலை நேரம்',
    },
    'daily_target': {
      AppLanguage.english: 'Daily Capacity',
      AppLanguage.tamil: 'தினசரி கொள்ளளவு',
    },
    'current_load': {
      AppLanguage.english: 'Active Tokens Today',
      AppLanguage.tamil: 'இன்றைய டோக்கன்கள்',
    },
    'logout': {AppLanguage.english: 'Logout', AppLanguage.tamil: 'வெளியேறு'},

    // Language Selector
    'language_settings': {
      AppLanguage.english: 'Language Preference',
      AppLanguage.tamil: 'மொழி தேர்வு (Language)',
    },
    'select_language_desc': {
      AppLanguage.english: 'Choose your preferred interface language',
      AppLanguage.tamil: 'உங்களுக்கு வசதியான மொழியை தேர்ந்தெடுக்கவும்',
    },
    'lang_english_sub': {
      AppLanguage.english: 'English (Standard)',
      AppLanguage.tamil: 'ஆங்கிலம் (English)',
    },
    'lang_tamil_sub': {
      AppLanguage.english: 'தமிழ் (Agrarian Tamil)',
      AppLanguage.tamil: 'தமிழ் (எளிய உழவர் தமிழ்)',
    },
  };

  static String text(String key, AppLanguage language) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[language] ?? entry[AppLanguage.english] ?? key;
  }
}
