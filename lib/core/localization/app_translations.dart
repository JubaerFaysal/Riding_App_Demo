import 'package:get/get.dart';

import 'app_texts.dart';



class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {
        /// -------------> English (US) <-------------
        'en_US': {
          AppText.signIn: 'Sign in',
          AppText.signUp: 'Sign Up',
          AppText.welcomeBack: 'Welcome back!',
          AppText.helloGreeting: 'Hello John',
          AppText.whereHeadedToday: 'Where are we headed today?',
          AppText.searchHint: 'Search for ride, delivery, rental',
          AppText.announcement: 'Announcement',
          AppText.bannerText: 'Book a chauffeur today and get a free upgrade',
          AppText.services: 'Services',
          AppText.hireDriver: 'Hire a driver',
          AppText.rentCar: 'Rent a car',
          AppText.bookFreight: 'Book freight service',
          AppText.hireArtisan: 'Hire an artisan',
          AppText.courierServices: 'Courier services',
          AppText.recentActivity: 'Recent activity',
          AppText.rideArriving: 'Your ride is arriving in 5 minutes',
          AppText.carRentalEnds: 'Your car rental ends tomorrow',
          AppText.track: 'Track',
          AppText.extend: 'Extend',
        },

        /// -------------> Bangla (BD) <-------------
        'en_BD': {
          AppText.signIn: 'সাইন ইন করুন',
          AppText.signUp: 'সাইন আপ করুন',
          AppText.welcomeBack: 'আবার স্বাগতম!',
          AppText.helloGreeting: 'হ্যালো জন',
          AppText.whereHeadedToday: 'আজ আমরা কোথায় যাচ্ছি?',
          AppText.searchHint: 'রাইড, ডেলিভারি, ভাড়া খুঁজুন',
          AppText.announcement: 'ঘোষণা',
          AppText.bannerText: 'আজই একজন শোফার বুক করুন এবং বিনামূল্যে আপগ্রেড পান',
          AppText.services: 'সেবাসমূহ',
          AppText.hireDriver: 'ড্রাইভার নিয়োগ করুন',
          AppText.rentCar: 'গাড়ি ভাড়া করুন',
          AppText.bookFreight: 'পণ্য পরিবহন সেবা বুক করুন',
          AppText.hireArtisan: 'কারিগর নিয়োগ করুন',
          AppText.courierServices: 'কুরিয়ার সেবা',
          AppText.recentActivity: 'সম্প্রতি কার্যকলাপ',
          AppText.rideArriving: 'আপনার রাইড ৫ মিনিটে পৌঁছাবে',
          AppText.carRentalEnds: 'আপনার গাড়ি ভাড়া আগামীকাল শেষ হবে',
          AppText.track: 'ট্র্যাক করুন',
          AppText.extend: 'বৃদ্ধি করুন',
        }
      };
}