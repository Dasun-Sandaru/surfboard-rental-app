import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

import 'app/bindings/initial_binding.dart';
import 'app/controllers/theme_controller.dart';
import 'app/routes/app_pages.dart';
import 'utils/storage/app_storage.dart';
import 'utils/theme/app_material_theme.dart';
import 'utils/translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'Supabase URL or Anon Key not found in .env file. Make sure you have a .env file with SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  Get.put(ThemeController(), permanent: true);

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => ScreenUtilInit(
    //     designSize: const Size(360.0, 770.0),
    //     minTextAdapt: true,
    //     splitScreenMode: true,
    //     builder: (context, child) => MyApp(),
    //   ),
    // ),
    ScreenUtilInit(
      designSize: const Size(360.0, 770.0),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      log(
        'device width: ${MediaQuery.of(context).size.width} height: ${MediaQuery.of(context).size.height}',
      );
    } catch (e) {
      debugPrint('Error logging device info: $e');
    }
    final box = AppLocalStorage();
    String? lang = box.readData('lang');
    Locale initialLocale = lang != null ? Locale(lang) : const Locale('en');
    // Use MaterialTheme for app theme
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeController.to.themeMode.value,
      useInheritedMediaQuery: true,
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'GB'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      translations: AppTranslations(),
    );
  }
}
