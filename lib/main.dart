import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanevents/auth_widget.dart';
import 'package:vanevents/auth_widget_builder.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firebase_auth_service.dart';
import 'package:vanevents/services/firestore_database.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(
        authServiceBuilder: (_) => FirebaseAuthService(),
        databaseBuilder: (_, uid) => FirestoreDatabase(uid: uid),
        prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirebaseAuthService Function(BuildContext context) authServiceBuilder;
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  MyApp({Key key, this.authServiceBuilder, this.databaseBuilder, this.prefs})
      : super(key: key);

  final ColorScheme colorScheme = ColorScheme(
      primary: const Color(0xFF5D1049),
      primaryVariant: const Color(0xFF5D1049),
      secondary: const Color(0xFFEFBFF5),
      secondaryVariant: const Color(0xFF1CDEC9),
      background: const Color(0xFF451B6F),
      surface: const Color(0xFFFFFFFF),
      onBackground: const Color(0xFF000000),
      error: const Color(0xFF5733FF),
      onError: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF5D1049),
      brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: authServiceBuilder,
        ),
      ],
      child: AuthWidgetBuilder(
          databaseBuilder: databaseBuilder,
          builder:
              (BuildContext context, AsyncSnapshot<FirebaseUser> userSnapshot) {
            return Material(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    colorScheme: colorScheme,
                    primaryColor: colorScheme.primary,
                    accentColor: colorScheme.secondary,
                    backgroundColor: colorScheme.background,
                    textTheme: TextTheme(
                      display1: GoogleFonts.raleway(
                        fontSize: 25.0,
                        color: colorScheme.onSurface,
                      ),
                      display2: GoogleFonts.raleway(
                        fontSize: 28.0,
                        color: colorScheme.onSurface,
                      ),
                      display3: GoogleFonts.raleway(
                        fontSize: 61.0,
                        color: colorScheme.onPrimary,
                      ),
                      display4: GoogleFonts.raleway(
                        fontSize: 98.0,
                        color: colorScheme.onPrimary,
                      ),
                      caption: GoogleFonts.sourceCodePro(
                        fontSize: 11.0,
                        color: colorScheme.onPrimary,
                      ),
                      headline: GoogleFonts.raleway(
                        fontSize: 35.0,
                        color: colorScheme.onPrimary,
                      ),
                      subhead: GoogleFonts.sourceCodePro(
                        fontSize: 16.0,
                        color: colorScheme.onPrimary,
                      ),
                      overline: GoogleFonts.sourceCodePro(
                        fontSize: 11.0,
                        color: colorScheme.onPrimary,
                      ),
                      body2: GoogleFonts.sourceCodePro(
                        fontSize: 17.0,
                        color: colorScheme.onPrimary,
                      ),
                      subtitle: GoogleFonts.sourceCodePro(
                        fontSize: 14.0,
                        color: colorScheme.onPrimary,
                      ),
                      body1: GoogleFonts.sourceCodePro(
                        fontSize: 15.0,
                        color: colorScheme.onPrimary,
                      ),
                      title: GoogleFonts.sourceCodePro(
                        fontSize: 16.0,
                        color: colorScheme.onPrimary,
                      ),
                      button: GoogleFonts.sourceCodePro(
                        fontSize: 15.0,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    buttonTheme: ButtonThemeData(
                        textTheme: ButtonTextTheme.primary,
                        splashColor: colorScheme.primary,
                        colorScheme: colorScheme,
                        buttonColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                        foregroundColor: colorScheme.secondary),
                    inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    cardTheme: CardTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    dividerColor: colorScheme.secondary),
                home: AuthWidget(
                    userSnapshot: userSnapshot,
                    seenOnboarding: prefs.getBool('seen') ?? false),
                onGenerateRoute: Router.onGenerateRoute,
//                    prefs.getBool('seen') ?? false),
              ),
            );
          }),
    );
  }
}