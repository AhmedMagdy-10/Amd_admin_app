import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/home/home_page.dart';
import 'feature/requests/data/repositories/requests_repository.dart';
import 'feature/requests/logic/requests_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start the single Firestore listener for the entire app lifetime
  RequestsRepository.instance.init();

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

        home: const HomePage(),
      ),
    );
  }
}
