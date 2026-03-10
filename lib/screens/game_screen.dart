import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../game_state.dart';
import '../game_engine.dart';
import '../widgets/retro_text.dart';
import '../widgets/award_popup.dart';
import '../widgets/scene_view.dart';
import 'end_screen.dart';
import 'menu_screen.dart';

class GameScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final GameState state;
  final bool immediateShit;

  const GameScreen({
    super.key,
    required this.prefs,
    required this.state,
    this.immediateShit = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameEngine _engine;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _audioPlayer = AudioPlayer();

  // Timer state
  int _secondsLeft = 40;
  Timer? _countdownTimer;
  Timer? _pillCheckTimer;
  int? _pillEatenSecond;   // game-second when pills were eaten

  // Display
  String _response = 'You really need to take a shit...';
  String? _awardMessage;
  bool _timedOut = false;
  bool _urgencyMsg1Shown = false;
  bool _urgencyMsg2Shown = false;

  // History of commands + responses
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    widget.state.resetRound();
    _engine = GameEngine(widget.state);

    if (widget.immediateShit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAward7());
    } else {
      _startTimer();
    }
  }

  void _triggerAward7() {
    _saveAward7();
    _goToEnd(
      won: false,
      scene: 'Award7',
      message:
          "The game hasn't started yet but you just couldn't help yourself.  You just shit your pants.  Game over.",
    );
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);

      // Urgency messages — trigger at exactly 20 and 5 seconds remaining (original logic)
      if (_secondsLeft == 20 && !_urgencyMsg1Shown && !widget.state.doneFarting) {
        _urgencyMsg1Shown = true;
        setState(() => _response =
            "You're running out of time.  You need to find a way to reduce the pressure in your gut.");
      }
      if (_secondsLeft == 5 && !_urgencyMsg2Shown && !widget.state.doneFarting) {
        _urgencyMsg2Shown = true;
        setState(() =>
            _response = "OMG IT'S PEEKING ITS HEAD!  DO SOMETHING ABOUT THE GAS BUILD UP!");
      }

      if (_secondsLeft <= 0) {
        _countdownTimer?.cancel();
        _pillCheckTimer?.cancel();
        _timedOut = true;

        if (widget.state.pillsEaten) {
          // Pills were eaten but didn't work in time — Award62 (Uh oh)
          _saveAward62();
          _goToEnd(
              won: false,
              scene: 'Award62',
              message: "Uh oh!  The pills didn't work in time!  You shit your pants!  Game over!");
        } else if (widget.state.pantsOff) {
          // Timer ran out, pants off — Award61
          _saveAward61();
          _goToEnd(
              won: true,
              scene: 'Award61',
              message:
                  "You couldn't hold it anymore, you had to shit!  Good thing your pants were off.  Congratulations!");
        } else {
          // Award8 — slow typer lose
          _saveAward8();
          _goToEnd(
              won: false,
              scene: 'Award8',
              message:
                  "You couldn't hold it anymore, you just shit your pants!  Game over!");
        }
      }
    });

    // Pill check every 100ms — fires 45 seconds after pills were eaten
    _pillCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (widget.state.pillsEaten && _pillEatenSecond != null) {
        final secondsSincePill = (40 - _secondsLeft) - _pillEatenSecond!;
        if (secondsSincePill >= 45) {
          _pillCheckTimer?.cancel();
          _countdownTimer?.cancel();
          _saveAward6();
          _goToEnd(
              won: true,
              scene: 'Award6',
              message: "The pills worked!  You didn't shit your pants.  Congratulations!");
        }
      }
    });
  }

  void _onSubmit(String value) {
    if (_timedOut) return;
    final text = value.trim();
    _controller.clear();
    _focusNode.requestFocus();
    if (text.isEmpty) return;

    final result = _engine.process(text);

    setState(() {
      _history.add({'cmd': text, 'resp': result.text});
      _response = result.text;
      _awardMessage = null;
    });

    if (result.fartBonus) {
      // Fart lightly gives ~60 extra seconds (original pauses timer and adds time)
      setState(() {
        _secondsLeft += 60;
        _urgencyMsg1Shown = false;
        _urgencyMsg2Shown = false;
      });
    }

    if (widget.state.pillsEaten && _pillEatenSecond == null) {
      _pillEatenSecond = 40 - _secondsLeft;
    }

    if (result.outcome == Outcome.gotoScene) {
      _countdownTimer?.cancel();
      _pillCheckTimer?.cancel();
      if (result.scene == 'Menu Frame 2') {
        _audioPlayer.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MenuScreen(prefs: widget.prefs, state: widget.state),
          ),
        );
      } else {
        _handleScene(result.scene!, result.awardName);
      }
    }

    _scrollToBottom();
  }

  void _handleScene(String scene, String? award) {
    final won = _isWin(scene);
    _grantAward(scene);
    _goToEnd(won: won, scene: scene, message: award ?? '');
  }

  bool _isWin(String scene) {
    return ['Award1', 'Award2', 'Award3-1-1', 'Award3-2-1', 'Award3-5-1',
            'Award5', 'Award6', 'Award61']
        .contains(scene);
  }

  void _grantAward(String scene) {
    bool isNew = false;
    switch (scene) {
      case 'Award1':
        if (!widget.state.gotAward1) { widget.state.gotAward1 = true; _persist(); isNew = true; }
      case 'Award2':
        if (!widget.state.gotAward2) { widget.state.gotAward2 = true; _persist(); isNew = true; }
      case 'Award3':
      case 'Award3-1':
      case 'Award3-2':
      case 'Award3-4':
      case 'Award3-5':
        if (!widget.state.gotAward3) { widget.state.gotAward3 = true; _persist(); isNew = true; }
      case 'Award3-1-1':
      case 'Award3-2-1':
      case 'Award3-5-1':
        if (!widget.state.gotAward3) { widget.state.gotAward3 = true; _persist(); isNew = true; }
      case 'Award4':
        if (!widget.state.gotAward31) { widget.state.gotAward31 = true; _persist(); isNew = true; }
      case 'Award5':
        if (!widget.state.gotAward5) { widget.state.gotAward5 = true; _persist(); isNew = true; }
    }
    if (isNew) _playAwardSound();
    _checkCrown();
  }

  void _saveAward6()  { if (!widget.state.gotAward6)  { widget.state.gotAward6  = true; _persist(); _playAwardSound(); } _checkCrown(); }
  void _saveAward61() { if (!widget.state.gotAward61) { widget.state.gotAward61 = true; _persist(); _playAwardSound(); } _checkCrown(); }
  void _saveAward62() { if (!widget.state.gotAward62) { widget.state.gotAward62 = true; _persist(); _playAwardSound(); } _checkCrown(); }
  void _saveAward7()  { if (!widget.state.gotAward7)  { widget.state.gotAward7  = true; _persist(); _playAwardSound(); } _checkCrown(); }
  void _saveAward8()  { if (!widget.state.gotAward62) { widget.state.gotAward62 = true; _persist(); _playAwardSound(); } _checkCrown(); }

  void _playAwardSound() {
    _audioPlayer.play(AssetSource('sounds/award_sound.mp3'));
  }

  void _checkCrown() {
    if (widget.state.allAwardsUnlocked && !widget.state.gotCrown) {
      widget.state.gotCrown = true;
      _persist();
    }
  }

  void _persist() {
    final data = widget.state.toJson();
    for (final e in data.entries) {
      widget.prefs.setBool(e.key, e.value as bool);
    }
  }

  void _goToEnd({required bool won, required String scene, required String message}) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EndScreen(
          won: won,
          scene: scene,
          message: message,
          prefs: widget.prefs,
          state: widget.state,
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_secondsLeft <= 5) return RetroColors.textRed;
    if (_secondsLeft <= 15) return RetroColors.textYellow;
    return RetroColors.textGreen;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pillCheckTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scene image — shows the pink man + room state
                  AspectRatio(
                    aspectRatio: 640 / 400,
                    child: SceneView(state: widget.state),
                  ),

                  const SizedBox(height: 6),

                  // Timer bar
                  RetroBorder(
                    borderColor: _timerColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.state.pillsEaten)
                          const RetroText('💊 pills active',
                              fontSize: 10, color: RetroColors.textYellow),
                        const Spacer(),
                        RetroText('Timer: $_timerText',
                            fontSize: 13, color: _timerColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Response box
                  Expanded(
                    child: RetroBorder(
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          RetroText(_response,
                              fontSize: 14, color: RetroColors.textGreen),
                          const SizedBox(height: 8),
                          ..._history.reversed.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RetroText('> ${e['cmd']}',
                                        fontSize: 12,
                                        color: RetroColors.cursor),
                                    if (e['resp']!.isNotEmpty)
                                      RetroText(e['resp']!,
                                          fontSize: 12,
                                          color: RetroColors.textDim),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                  // Award popup
                  if (_awardMessage != null)
                    AwardPopup(message: _awardMessage!),

                  const SizedBox(height: 6),

                  // Input row
                  RetroBorder(
                    borderColor: RetroColors.cursor,
                    child: Row(
                      children: [
                        const RetroText('> ',
                            color: RetroColors.cursor, fontSize: 16),
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
                              FilteringTextInputFormatter.deny(RegExp(r'\n')),
                            ],
                          ),
                        ),
                      ],
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
