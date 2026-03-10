import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../game_state.dart';
import '../widgets/retro_text.dart';
import 'awards_screen.dart';

// Maps each scene label to its pre-rendered end-screen frame asset.
const _sceneImages = {
  'Award1':     'assets/scenes/end_award1.png',
  'Award2':     'assets/scenes/end_award2.png',
  'Award3':     'assets/scenes/end_award3.png',
  'Award3-1':   'assets/scenes/end_award3_1.png',
  'Award3-2':   'assets/scenes/end_award3_2.png',
  'Award3-1-1': 'assets/scenes/end_award3_1_1.png',
  'Award3-2-1': 'assets/scenes/end_award3_2_1.png',
  'Award3-4':   'assets/scenes/end_award3_4.png',
  'Award3-5':   'assets/scenes/end_award3_5.png',
  'Award3-5-1': 'assets/scenes/end_award3_5_1.png',
  'Award4':     'assets/scenes/end_award4.png',
  'Award5':     'assets/scenes/end_award5.png',
  'Award6':     'assets/scenes/end_award6.png',
  'Award61':    'assets/scenes/end_award61.png',
  'Award62':    'assets/scenes/end_award62.png',
  'Award7':     'assets/scenes/end_award7.png',
  'Award8':     'assets/scenes/end_award8.png',
};

class EndScreen extends StatefulWidget {
  final bool won;
  final String scene;
  final String message;
  final SharedPreferences prefs;
  final GameState state;

  const EndScreen({
    super.key,
    required this.won,
    required this.scene,
    required this.message,
    required this.prefs,
    required this.state,
  });

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  final _audioPlayer = AudioPlayer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _playMusic();
    _focusNode.requestFocus();
  }

  void _playMusic() async {
    final asset = widget.won ? 'sounds/win_song.mp3' : 'sounds/lose_song.mp3';
    await _audioPlayer.play(AssetSource(asset));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continue() {
    _audioPlayer.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AwardsScreen(state: widget.state, fromGame: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _sceneImages[widget.scene];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (_, event) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              _continue();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: _continue,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Original game end-screen artwork
                    if (imagePath != null)
                      AspectRatio(
                        aspectRatio: 640 / 400,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),

                    if (widget.state.gotCrown) ...[
                      const SizedBox(height: 12),
                      const RetroText(
                        '♛  YOU ARE THE SHIT KING  ♛',
                        fontSize: 16,
                        color: RetroColors.textYellow,
                        align: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
