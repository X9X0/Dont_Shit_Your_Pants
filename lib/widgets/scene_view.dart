import 'package:flutter/material.dart';
import '../game_state.dart';

/// Displays the correct pre-rendered scene frame based on current game state,
/// exactly matching the original Flash game's room/character artwork.
class SceneView extends StatelessWidget {
  final GameState state;

  const SceneView({super.key, required this.state});

  String get _assetPath {
    final crown = state.gotCrown;

    if (state.sittingOnToilet) {
      if (crown) {
        return state.pantsOff
            ? 'assets/scenes/toilet_sitting_pants_off_crown.png'
            : 'assets/scenes/toilet_sitting_pants_on_crown.png';
      } else {
        return state.pantsOff
            ? 'assets/scenes/toilet_sitting_pants_off.png'
            : 'assets/scenes/toilet_sitting_pants_on.png';
      }
    }

    if (state.doorOpen) {
      if (crown) {
        return state.pantsOff
            ? 'assets/scenes/room_door_open_pants_off_crown.png'
            : 'assets/scenes/room_door_open_pants_on_crown.png';
      } else {
        return state.pantsOff
            ? 'assets/scenes/room_door_open_pants_off.png'
            : 'assets/scenes/room_door_open_pants_on.png';
      }
    }

    // door closed
    if (crown) {
      return state.pantsOff
          ? 'assets/scenes/room_door_closed_pants_off_crown.png'
          : 'assets/scenes/room_door_closed_pants_on_crown.png';
    } else {
      return state.pantsOff
          ? 'assets/scenes/room_door_closed_pants_off.png'
          : 'assets/scenes/room_door_closed_pants_on.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // keep the pixel-art crisp
    );
  }
}
