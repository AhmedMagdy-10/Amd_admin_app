import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/requests/data/repositories/requests_repository.dart';
import 'feature/requests/logic/requests_cubit.dart';
import 'feature/splash/presentation/views/splash_view.dart';
import 'firebase_options.dart';

import 'core/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start the single Firestore listener for the entire app lifetime
  RequestsRepository.instance.init();

  // Initialize background & foreground FCM handlers and request permissions
  try {
    await FirebaseMessagingService().initialize();
  } catch (e) {
    print('Error initializing Firebase Messaging: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestsCubit>(
      // One cubit for the whole app — shared across all screens
      create: (_) => RequestsCubit()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Amd Admin',
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },

        home: const SplashView(),
      ),
    );
  }
}
