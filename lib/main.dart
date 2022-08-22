import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit/database/database_service.dart';
import 'package:transit/database/executor/executor.dart';
import 'package:transit/navigator_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<DatabaseService>(
      create: (context) => DatabaseService(getDatabaseExecutor()),
      dispose: (context, db) => db.close(),
      child: MaterialApp(
        title: 'BUS',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: NavigatorRoutes.routeHome,
        onGenerateRoute: NavigatorRoutes.onGenerateRoute,
      ),
    );
  }
}
