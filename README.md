# Don't Shit Your Pants — Android Port

A faithful Android port of the classic 2009 Flash game by Cagey Bee / Cellar Door Games, built with Flutter.

## About

Don't Shit Your Pants is a text-adventure game where you have 40 seconds to figure out how not to shit your pants. Type commands to interact with your environment, find creative solutions, and unlock all 9 awards to become the Shit King.

This port was built by decompiling the original `.swf` file with JPEXS Free Flash Decompiler, analysing the original ActionScript 3 source, and recreating the game logic faithfully in Flutter/Dart. All original artwork, audio, and game logic are preserved.

## Features

- All original game commands and outcomes
- All 9 awards + the Shit King crown
- Original pixel-art scenes rendered at native resolution
- Original soundtrack (title, win, lose, award sounds)
- 40-second countdown timer with urgency messages
- Fart lightly — buys you extra time
- Pills mechanic — eat them early, wait 45 seconds, win
- Persistent save data via SharedPreferences
- 640×400 pixel-art aspect ratio preserved on all screen sizes

## How to Play

Type commands at the prompt and press Enter. The game is a text adventure — experiment with verbs and nouns.

**Useful starting commands:**
- `look` — examine your surroundings
- `look pocket` — check what you're carrying
- `pull door` — try the door
- `fart lightly` — relief... for now

**Menu commands:**
- `play` / `start` — begin the game
- `awards` — view your award collection
- `credits` — game credits
- `delete` — wipe your save data

## Awards

| # | Award | How to get |
|---|-------|-----------|
| 1 | Mr. Efficient | Complete the game with maximum efficiency |
| 2 | Thinking (and shitting) inside the box | Shit in the toilet properly |
| 3 | Shitting 101 | Shit your pants |
| 4 | So close and yet so far... | Die trying |
| 5 | Sep-poo-ku | Die with pants off |
| 6 | Holding off the inevitable | Let the pills work |
| 7 | The inevitable... | Timer runs out with pants off |
| 8 | Shitting at the starting gun | Shit before the game starts |
| 9 | Slow typer | Let the timer run out |
| ♛ | Shit King | Unlock all other awards |

## Building

Requirements:
- Flutter SDK 3.24+
- Android SDK with `platforms;android-35` and `build-tools;35.0.0`

```bash
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Credits

**Original game:** Don't Shit Your Pants (2009) by Cagey Bee / Cellar Door Games
**Original release:** https://www.newgrounds.com/portal/view/540127
**Android port:** Faithful recreation — all assets and logic from the original Flash release

## Version

v0.5 — initial public release
