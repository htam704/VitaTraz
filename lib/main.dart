import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:fl_vitatraz_app/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitatraz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName:      (_) => const WelcomeScreen(),
        LoginScreen.routeName:        (_) => const LoginScreen(),
        HomeScreen.routeName:         (_) => const HomeScreen(),
        MedicationsScreen.routeName:  (_) => const MedicationsScreen(),
        RecordsScreen.routeName:      (_) => const RecordsScreen(),
        CreateRecordScreen.routeName: (_) => const CreateRecordScreen(),
        PatientsScreen.routeName:     (_) => const PatientsScreen(),
        ProfileScreen.routeName:      (_) => const ProfileScreen(),
        AddTodoScreen.routeName:      (_) => const AddTodoScreen(),
        EditProfileScreen.routeName:  (_) => const EditProfileScreen(),
        NotificationsScreen.routeName:(_) => const NotificationsScreen(),
        PrivacyScreen.routeName:      (_) => const PrivacyScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),

        PatientDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PatientDetailsScreen(data: args);
        },

        RecordDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return RecordDetailsScreen(data: args);
        },
      },
    );
  }
}
