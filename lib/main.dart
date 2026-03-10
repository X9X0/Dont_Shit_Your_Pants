import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final state = GameState();

  // Load saved award flags
  final keys = state.toJson().keys.toList();
  final saved = {for (var k in keys) k: prefs.getBool(k) ?? false};
  state.fromJson(saved);

  // Strip a prematurely-granted crown if not all awards are actually earned
  if (state.gotCrown && !state.allAwardsUnlocked) {
    state.gotCrown = false;
    prefs.setBool('aCrown', false);
  }

  runApp(DSYPApp(prefs: prefs, state: state));
}

class DSYPApp extends StatelessWidget {
  final SharedPreferences prefs;
  final GameState state;
  const DSYPApp({super.key, required this.prefs, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Don't Shit Your Pants",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: MenuScreen(prefs: prefs, state: state),
    );
  }
}
