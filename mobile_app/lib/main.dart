import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/measure_form_screen.dart';

import 'package:animations/animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Fitable V2',
            locale: provider.locale,
            themeMode: provider.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('tr'), // Turkish
            ],
            debugShowCheckedModeBanner: false,
            // LIGHT THEME
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              primaryColor: const Color(0xFF2962FF),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF2962FF),
                secondary: Color(0xFF2962FF),
                surface: Colors.white,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF5F5F5),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                iconTheme: IconThemeData(color: Colors.black),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                labelStyle: TextStyle(color: Colors.grey[600]),
                hintStyle: TextStyle(color: Colors.grey[600]),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.5),
                ),
                prefixIconColor: const Color(0xFF2962FF),
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                elevation: 5,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                margin: EdgeInsets.all(8),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.white,
                elevation: 10,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: const Color(0xFF2962FF).withOpacity(0.5),
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                  TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                  TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                },
              ),
            ),
            // DARK THEME
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: const Color(0xFF2962FF),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF2962FF),
                secondary: Color(0xFF2962FF),
                surface: Color(0xFF1E1E1E),
                onPrimary: Colors.white,
                onSurface: Colors.white,
              ),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF252525), // LoginScreen input fill color
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintStyle: TextStyle(color: Colors.grey[600]),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // LoginScreen padding
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none, // LoginScreen default border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none, // LoginScreen enabled border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.5), // LoginScreen focused border width
                ),
                // Icons color can't be set globally for prefixIcon immediately without custom widgets, 
                // but we can set iconColor which might help default icons.
                prefixIconColor: const Color(0xFF2962FF), 
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E1E1E),
                elevation: 10,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                margin: EdgeInsets.all(8),
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                elevation: 10,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 20), // LoginScreen button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: const Color(0xFF2962FF).withOpacity(0.5), // LoginScreen shadow opacity
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                  TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                  TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
                },
              ),
            ),
        home: Consumer<AppProvider>(
              builder: (context, auth, _) {
                // Using a simple cross-fade for auth state change
                return PageTransitionSwitcher(
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      if (auth.isAuthenticated) {
                        if (!auth.hasMeasurements) {
                          return const MeasureFormScreen(isInitialSetup: true); // Force data entry
                        }
                        return const HomeScreen();
                      }
                      return const LoginScreen();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
    }
  }
