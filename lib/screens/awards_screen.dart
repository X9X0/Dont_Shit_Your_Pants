import 'package:flutter/material.dart';
import '../game_state.dart';
import '../widgets/retro_text.dart';
import 'menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AwardsScreen extends StatelessWidget {
  final GameState state;
  final bool fromGame;
  const AwardsScreen({super.key, required this.state, this.fromGame = false});

  @override
  Widget build(BuildContext context) {
    final awards = [
      _Award('Award 1: Mr. Efficient',
          state.gotAward1,
          'Complete the game with maximum efficiency.'),
      _Award('Award 2: Thinking (and shitting) inside the box',
          state.gotAward2,
          'Shit in the toilet properly.'),
      _Award('Award 3: Shitting 101',
          state.gotAward3,
          'Shit your pants.'),
      _Award('Award 4: So close and yet so far...',
          state.gotAward31,
          'Almost made it... but died trying.'),
      _Award('Award 5: Sep-poo-ku',
          state.gotAward5,
          'Die with pants off.'),
      _Award('Award 6: Holding off the inevitable',
          state.gotAward6,
          'Use the pills to hold it in for 45 seconds.'),
      _Award('Award 7: The inevitable...',
          state.gotAward61,
          'Timer ran out with pants off.'),
      _Award('Award 8: Shitting at the starting gun',
          state.gotAward7,
          'Shit your pants before the game even starts.'),
      _Award('Award 9: Slow typer',
          state.gotAward62,
          'Let the timer run out with pants on.'),
      _Award('Final Award: You are the Shit King!',
          state.gotCrown,
          'Unlock all other awards.'),
    ];

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
                  RetroBorder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const RetroText('PANTS SHITTING ACHIEVEMENTS',
                            fontSize: 14,
                            color: RetroColors.textYellow,
                            mono: false),
                        if (state.gotCrown)
                          const RetroText('♛',
                              fontSize: 20,
                              color: RetroColors.textYellow),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: awards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _AwardTile(award: awards[i]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RetroColors.panelBg,
                      foregroundColor: RetroColors.textMain,
                      side: const BorderSide(color: RetroColors.border),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MenuScreen(prefs: prefs, state: state),
                          ),
                          (_) => false,
                        );
                      }
                    },
                    child: const RetroText('RETURN TO MENU',
                        fontSize: 14, color: RetroColors.textMain),
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

class _Award {
  final String name;
  final bool unlocked;
  final String hint;
  const _Award(this.name, this.unlocked, this.hint);
}

class _AwardTile extends StatelessWidget {
  final _Award award;
  const _AwardTile({required this.award});

  @override
  Widget build(BuildContext context) {
    return RetroBorder(
      borderColor: award.unlocked ? RetroColors.textYellow : RetroColors.textDim,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            award.unlocked ? '★' : '?',
            style: TextStyle(
              fontSize: 18,
              color: award.unlocked
                  ? RetroColors.textYellow
                  : RetroColors.textDim,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RetroText(
                  award.unlocked ? award.name : '?????',
                  fontSize: 12,
                  color: award.unlocked
                      ? RetroColors.textYellow
                      : RetroColors.textDim,
                ),
                if (award.unlocked)
                  RetroText(award.hint,
                      fontSize: 10, color: RetroColors.textDim),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
