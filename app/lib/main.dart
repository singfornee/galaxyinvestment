import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/repositories/library_repository.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local, offline storage. Opened once here and injected into Riverpod so the
  // rest of the app can treat the box as a ready dependency.
  await Hive.initFlutter();
  final libraryBox = await Hive.openBox(LibraryRepository.boxName);

  runApp(
    ProviderScope(
      overrides: [
        libraryBoxProvider.overrideWithValue(libraryBox),
      ],
      child: const CurioApp(),
    ),
  );
}
