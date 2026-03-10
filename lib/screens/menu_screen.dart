import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../game_state.dart';
import '../widgets/retro_text.dart';
import 'game_screen.dart';
import 'awards_screen.dart';

class MenuScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final GameState state;
  const MenuScreen({super.key, required this.prefs, required this.state});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _audioPlayer = AudioPlayer();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _playTitle();
  }

  void _playTitle() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.play(AssetSource('sounds/title_song.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onSubmit(String value) {
    final cmd = value.trim().toLowerCase();
    _controller.clear();
    _focusNode.requestFocus();

    if (cmd.startsWith(' ')) {
      setState(() => _message = 'You started the sentence with a space... try again');
      return;
    }

    switch (cmd) {
      case 'play':
      case 'start':
        _audioPlayer.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(prefs: widget.prefs, state: widget.state),
          ),
        );
      case 'awards':
        _audioPlayer.stop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AwardsScreen(state: widget.state),
          ),
        );
      case 'menu':
        setState(() => _message = "You're already at the menu.");
      case '"menu"':
      case '"play"':
      case '"awards"':
        setState(() => _message = "You're an idiot.");
      case 'credits':
        setState(() => _message =
            'Don\'t Shit Your Pants\nOriginal game by Cagey Bee / Cellar Door Games (2009)\nAndroid port — faithful recreation');
      case 'delete':
        _deleteSave();
        _audioPlayer.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(prefs: widget.prefs, state: widget.state),
          ),
        );
      case 'shit':
      case 'shit pants':
      case 'shit your pants':
        _audioPlayer.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
                prefs: widget.prefs, state: widget.state, immediateShit: true),
          ),
        );
      default:
        if (cmd.isEmpty) return;
        setState(() => _message = '$cmd is not a proper command.');
    }
  }

  void _deleteSave() {
    final s = widget.state;
    s.gotAward1 = s.gotAward2 = s.gotAward3 = s.gotAward31 = false;
    s.gotAward5 = s.gotAward6 = s.gotAward61 = s.gotAward62 = false;
    s.gotAward7 = s.gotCrown = false;
    for (final k in s.toJson().keys) {
      widget.prefs.setBool(k, false);
    }
    setState(() => _message = 'Save deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Original game menu artwork — crown version when Shit King earned
                  AspectRatio(
                    aspectRatio: 640 / 400,
                    child: Image.asset(
                      widget.state.gotCrown
                          ? 'assets/scenes/menu_crown.png'
                          : 'assets/scenes/menu.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                  ),

                  if (widget.state.gotCrown) ...[
                    const SizedBox(height: 4),
                    const RetroText('♛  SHIT KING  ♛',
                        fontSize: 14,
                        color: RetroColors.textYellow,
                        align: TextAlign.center),
                  ],

                  const SizedBox(height: 12),

                  // Input row
                  RetroBorder(
                    borderColor: RetroColors.cursor,
                    child: Row(
                      children: [
                        const RetroText('> ', color: RetroColors.cursor, fontSize: 16),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            style: const TextStyle(
                              fontFamily: 'Uni05',
                              fontSize: 16,
                              color: RetroColors.textMain,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            cursorColor: RetroColors.cursor,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _onSubmit,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\n')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Response area
                  if (_message.isNotEmpty)
                    RetroBorder(
                      borderColor: RetroColors.border,
                      child: RetroText(
                        _message,
                        fontSize: 13,
                        color: RetroColors.textMain,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
