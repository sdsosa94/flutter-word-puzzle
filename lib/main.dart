import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.light,
          ),
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              'Hello, World!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    ),
  );
}
