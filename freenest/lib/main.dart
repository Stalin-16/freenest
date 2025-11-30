import 'package:flutter/material.dart';
import 'package:freenest/routes/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chennai FreeLancers',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfffebd55),
          secondary: const Color(0xff545454),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfffebd55),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: "/splash",
      routes: routes,
    );
  }
}
