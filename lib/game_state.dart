/// All mutable game-play state, mirroring the boolean flags in MainTimeline.as
class GameState {
  bool pantsOff = false;
  bool doorOpen = false;
  bool pillsEaten = false;
  bool sittingOnToilet = false;
  bool doneFarting = false;
  bool fartingAgain = false;

  // Award flags (persisted)
  bool gotAward1 = false;   // Mr. Efficient
  bool gotAward2 = false;   // Thinking (and shitting) inside the box
  bool gotAward3 = false;   // Shitting 101
  bool gotAward31 = false;  // So close and yet so far...
  bool gotAward5 = false;   // Sep-poo-ku
  bool gotAward6 = false;   // Holding off the inevitable
  bool gotAward61 = false;  // The inevitable (pants off)
  bool gotAward62 = false;  // Uh oh / pill fail
  bool gotAward7 = false;   // Shitting at the starting gun
  bool gotAward8 = false;   // Slow typer
  bool gotCrown = false;    // Shit King (all awards)

  void resetRound() {
    pantsOff = false;
    doorOpen = false;
    pillsEaten = false;
    sittingOnToilet = false;
    doneFarting = false;
    fartingAgain = false;
  }

  Map<String, dynamic> toJson() => {
    'a1': gotAward1,
    'a2': gotAward2,
    'a3': gotAward3,
    'a31': gotAward31,
    'a5': gotAward5,
    'a6': gotAward6,
    'a61': gotAward61,
    'a62': gotAward62,
    'a7': gotAward7,
    'a8': gotAward8,
    'aCrown': gotCrown,
  };

  void fromJson(Map<String, dynamic> d) {
    gotAward1  = d['a1']    as bool? ?? false;
    gotAward2  = d['a2']    as bool? ?? false;
    gotAward3  = d['a3']    as bool? ?? false;
    gotAward31 = d['a31']   as bool? ?? false;
    gotAward5  = d['a5']    as bool? ?? false;
    gotAward6  = d['a6']    as bool? ?? false;
    gotAward61 = d['a61']   as bool? ?? false;
    gotAward62 = d['a62']   as bool? ?? false;
    gotAward7  = d['a7']    as bool? ?? false;
    gotAward8  = d['a8']    as bool? ?? false;
    gotCrown   = d['aCrown'] as bool? ?? false;
  }

  bool get allAwardsUnlocked =>
      gotAward1 && gotAward2 && gotAward3 && gotAward31 &&
      gotAward5 && gotAward6 && gotAward61 && gotAward62 && gotAward7;
}
