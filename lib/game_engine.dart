// Direct port of MainTimeline.as ReadUserInput logic.
// Returns a GameResult describing what happened after a command.
import 'string_parser.dart';
import 'game_state.dart';

enum Outcome {
  response,   // just display text, no scene change
  gotoScene,  // jump to an end-scene / award screen
}

class GameResult {
  final Outcome outcome;
  final String text;        // response text shown in DynamicResponseBox
  final String? scene;      // scene label if outcome == gotoScene
  final String? awardName;  // award name to show in popup (optional)
  final bool fartBonus;     // true when fart lightly gives a time extension

  const GameResult.response(this.text, {this.fartBonus = false})
      : outcome = Outcome.response,
        scene = null,
        awardName = null;

  const GameResult.scene(String s, {String? award})
      : outcome = Outcome.gotoScene,
        text = '',
        scene = s,
        awardName = award,
        fartBonus = false;
}

class GameEngine {
  final StringParser _parser = StringParser();
  final GameState state;

  GameEngine(this.state);

  GameResult process(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const GameResult.response('');

    if (trimmed.startsWith(' ')) {
      return const GameResult.response('You started the sentence with a space... try again.');
    }
    if (trimmed.endsWith(' ')) {
      return const GameResult.response('Your sentence ended with a space... try again.');
    }

    final fs = _parser.parse(trimmed);
    final oneWord = _parser.oneWord;

    // ── pants off ──────────────────────────────────────────────────────────
    if (_m(fs, ['pants remove', 'remove pants', 'remove up pants']) &&
        !state.pantsOff && !state.sittingOnToilet) {
      state.pantsOff = true;
      return const GameResult.response('You remove your pants.');
    }
    if (_m(fs, ['pants remove', 'remove pants', 'remove up pants']) &&
        state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.response('Your pants are already off.');
    }
    if (_m(fs, ['pants remove', 'remove pants', 'remove up pants']) &&
        state.sittingOnToilet) {
      return const GameResult.response('Get off the toilet first.');
    }

    // ── pants on ───────────────────────────────────────────────────────────
    if (_m(fs, ['pants on', 'on pants']) && state.pantsOff && !state.sittingOnToilet) {
      state.pantsOff = false;
      return const GameResult.response("You don't know why, but you put your pants back on.");
    }
    if (_m(fs, ['pants on', 'on pants']) && !state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.response('Your pants are already on.');
    }
    if (_m(fs, ['pants on', 'on pants']) && state.sittingOnToilet) {
      return const GameResult.response('Get off the toilet first.');
    }

    // ── door ───────────────────────────────────────────────────────────────
    if (fs.contains('open door') && !state.doorOpen) {
      return const GameResult.response("You try PUSHING the door open but it won't budge.");
    }
    if (_m(fs, ['pull door', 'open door']) && state.doorOpen) {
      return const GameResult.response('The door is already open.');
    }
    if (fs.contains('pull door') && !state.doorOpen && !state.sittingOnToilet) {
      state.doorOpen = true;
      return const GameResult.response('Oh, right...');
    }
    if (fs.contains('close door') && state.doorOpen && !state.sittingOnToilet) {
      state.doorOpen = false;
      return const GameResult.response('You close the door.  But you still need to take a shit.');
    }
    if (fs.contains('close door') && !state.doorOpen) {
      return const GameResult.response('The door is already closed.');
    }
    if (fs.contains('close door') && state.sittingOnToilet) {
      return const GameResult.response("You're sitting on the can.  You can't reach the door.");
    }

    // ── fart lightly ───────────────────────────────────────────────────────
    if (_m(fs, ['fart lightly', 'lightly fart']) && !state.doneFarting) {
      state.doneFarting = true;
      return const GameResult.response('You farted lightly.  Relief!', fartBonus: true);
    }
    if (_m(fs, ['fart lightly', 'lightly fart']) && state.doneFarting && !state.fartingAgain) {
      state.fartingAgain = true;
      return const GameResult.response("You farted already.  Another one will stain your pants.");
    }
    if (_m(fs, ['fart lightly', 'lightly fart']) && state.fartingAgain) {
      return const GameResult.scene('Award3',
          award: "You farted too hard and shit your pants! Maybe next time you shouldn't push it so hard.");
    }

    // ── sit toilet ─────────────────────────────────────────────────────────
    if (_m(fs, ['sit toilet', 'toilet sit', 'sit on toilet', 'move toilet', 'move washroom']) &&
        !state.sittingOnToilet && state.doorOpen) {
      state.sittingOnToilet = true;
      return const GameResult.response('You sit on the toilet.');
    }
    if (_m(fs, ['sit toilet', 'toilet sit', 'sit on toilet', 'move toilet', 'move washroom']) &&
        state.sittingOnToilet) {
      return const GameResult.response("You're already sitting on the toilet.");
    }
    if (_m(fs, ['sit toilet', 'toilet sit', 'sit on toilet']) && !state.doorOpen) {
      return const GameResult.response(
          'You quietly try to sit on the toilet with the door closed but your efforts are in vain.');
    }

    // ── stand / up ─────────────────────────────────────────────────────────
    if ((fs.contains(' stand') || fs.contains(' up')) && state.sittingOnToilet) {
      state.sittingOnToilet = false;
      return const GameResult.response('You stand up.');
    }
    if (fs.contains(' stand') && !state.sittingOnToilet) {
      return const GameResult.response('You stand up even more than before.');
    }

    // ── look ───────────────────────────────────────────────────────────────
    if ((oneWord && fs.contains(' look') || fs.contains('look room')) && !state.doorOpen) {
      return const GameResult.response(
          "You're in a room with a door. You're wearing a shirt and pants.  You have no hair.");
    }
    if ((oneWord && fs.contains(' look') || fs.contains('look room')) && state.doorOpen) {
      return const GameResult.response(
          "You're in a room with a door that leads to a washroom. You're wearing a shirt and pants.  You have no hair.");
    }
    if (fs.contains('look washroom') && state.doorOpen) {
      return const GameResult.response('It looks like a washroom.');
    }
    if (fs.contains('look washroom') && !state.doorOpen) {
      return const GameResult.response("You can't see into the other room.  The door's closed.");
    }
    if (fs.contains('look door')) {
      return const GameResult.response("It's a door.");
    }
    if (fs.contains('look toilet') && !state.doorOpen) {
      return const GameResult.response('What toilet?');
    }
    if (fs.contains('look toilet') && state.doorOpen) {
      return const GameResult.response("Don't just look at the toilet, the clock is ticking!  Do something!");
    }
    if (_m(fs, ['look pocket', 'look pants']) && !state.pillsEaten) {
      return const GameResult.response(
          'You check your pockets.  You find some pills for stomach relief.  It says they take 45 seconds to start working.');
    }
    if (_m(fs, ['look pocket', 'look pants']) && state.pillsEaten) {
      return const GameResult.response('Your pockets are empty.');
    }
    if (fs.contains('look shirt')) {
      return const GameResult.response("Upon closer inspection, you realize you're wearing your shirt backwards.");
    }
    if (fs.contains('look clothes')) {
      return const GameResult.response('You should be more specific.');
    }
    if (fs.contains('look pills') && !state.pillsEaten) {
      return const GameResult.response(
          "They're pills to relieve stomach problems.  It says they take 45 seconds to start working.");
    }
    if (fs.contains('look hair')) {
      return const GameResult.response('You shed a single tear.');
    }
    if (fs.contains('look shoes')) {
      return const GameResult.response('You have feet.');
    }

    // ── pills ──────────────────────────────────────────────────────────────
    if (_m(fs, ['look pills', 'eat pills', 'take pills']) && state.pillsEaten) {
      return const GameResult.response('You already ate the pills.');
    }
    if (_m(fs, ['eat pills', 'take pills']) && !state.pillsEaten) {
      state.pillsEaten = true;
      return const GameResult.response("You eat the pills.  Hopefully they'll start working in time.");
    }

    // ── shit outcomes ──────────────────────────────────────────────────────

    // Win: shit on floor (pants off, not on toilet)
    if ((_m1(fs, 'shit', oneWord) || fs.contains('shit yourself') || fs.contains('take shit')) &&
        state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.scene('Award1',
          award: "You just shit on the floor!  Congratulations!");
    }
    if (fs.contains('shit on floor') && state.pantsOff) {
      return const GameResult.scene('Award1',
          award: "You just shit on the floor!  Congratulations!");
    }

    // Win: shit in toilet (sitting, pants off)
    if ((_m1(fs, 'shit', oneWord) || _m1(fs, 'fart', oneWord) ||
            fs.contains('shit yourself') || fs.contains('shit toilet') || fs.contains('take shit')) &&
        state.pantsOff && state.sittingOnToilet) {
      return const GameResult.scene('Award2',
          award: "You just shit in the toilet!  Congratulations!");
    }
    if (fs.contains('shit toilet') && state.pantsOff && !state.sittingOnToilet && state.doorOpen) {
      return const GameResult.scene('Award2',
          award: "You just shit in the toilet!  Congratulations!");
    }

    // Lose variants
    if (fs.contains('shit toilet') && !state.sittingOnToilet && !state.pantsOff && state.doorOpen) {
      return const GameResult.scene('Award3-1',
          award: "You forgot to take your pants off!  You just shit your pants!  Game over!");
    }
    if (fs.contains('shit toilet') && state.sittingOnToilet && !state.pantsOff) {
      return const GameResult.scene('Award3-1',
          award: "You forgot to take your pants off!  You just shit your pants!  Game over!");
    }
    if ((_m1(fs, 'shit', oneWord) || fs.contains('take shit') || fs.contains('shit yourself')) &&
        !state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.scene('Award3',
          award: "You just shit your pants!  Game over!");
    }
    if ((_m1(fs, 'shit', oneWord) || _m1(fs, 'fart', oneWord) ||
            fs.contains('take shit') || fs.contains('shit yourself')) &&
        !state.pantsOff && state.sittingOnToilet) {
      return const GameResult.scene('Award3-1',
          award: "You forgot to take your pants off!  You just shit your pants!  Game over!");
    }
    if (fs.contains("don't shit") && !state.pantsOff) {
      return const GameResult.scene('Award3-2',
          award: "You shit your pants anyway!  Game over!");
    }
    if (fs.contains("don't shit") && state.pantsOff) {
      return const GameResult.scene('Award3-1-1',
          award: "You shit anyway, but all is forgiven because your pants are off.  Congratulations!");
    }
    if (fs.contains('shit pants')) {
      return const GameResult.scene('Award3',
          award: "You just shit your pants!  Game over!");
    }
    if (fs.contains('shit toilet') && !state.doorOpen) {
      return const GameResult.response('What toilet?');
    }

    // ── break ──────────────────────────────────────────────────────────────
    if (fs.contains(' break') && !state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.scene('Award3-4',
          award: "The exertion causes you to shit your pants!  Game over!");
    }
    if (fs.contains(' break') && state.pantsOff && !state.sittingOnToilet) {
      return const GameResult.scene('Award3-2-1',
          award: "The exertion causes you to shit, but your pants are off anyway.  Close call!  Congratulations!");
    }
    if (fs.contains(' break') && state.sittingOnToilet) {
      return const GameResult.response("Why not concentrate on taking a shit instead?");
    }

    // ── die ────────────────────────────────────────────────────────────────
    if (fs.contains(' die') && !state.pantsOff) {
      return const GameResult.scene('Award4',
          award: "Your vision fades and you hear a soft 'pbffffff' as you shit your pants.  Game over.");
    }
    if (fs.contains(' die') && state.pantsOff) {
      return const GameResult.scene('Award5',
          award: "Your vision fades and you hear a soft 'pbffffff' as you shit, but your pants are off.\nSo... congratulations?");
    }

    // ── bare fart ──────────────────────────────────────────────────────────
    if (_m1(fs, 'fart', oneWord) && !state.sittingOnToilet && !state.pantsOff) {
      return const GameResult.scene('Award3-5',
          award: "You farted too hard and shit your pants!  Game over!");
    }
    if (_m1(fs, 'fart', oneWord) && !state.sittingOnToilet && state.pantsOff) {
      return const GameResult.scene('Award3-5-1',
          award: "You farted too hard but your pants are off so you shit the floor!  Still, you shouldn't push it so hard.");
    }

    // ── quit ───────────────────────────────────────────────────────────────
    if (oneWord && fs.contains(' quit')) {
      return const GameResult.scene('Menu Frame 2');
    }

    // ── unrecognised ───────────────────────────────────────────────────────
    return GameResult.response('${trimmed.replaceAll('\r', '')} is not a proper command.');
  }

  // helpers
  bool _m(String fs, List<String> patterns) =>
      patterns.any((p) => fs.contains(p));

  bool _m1(String fs, String token, bool oneWord) =>
      oneWord && fs.contains(' $token');
}
