/// Direct port of StringParser.as
/// Scans typed input for keyword categories, returns them
/// space-joined in order of appearance (preserving original parse logic).
class ParsedWord {
  final String word;
  final int index;
  const ParsedWord(this.word, this.index);
}

class StringParser {
  static const _wordShit = [
    ' shit ', ' crap ', ' dump ', ' plop ', ' poo ', ' poop ',
    ' defecate ', ' expel ', ' expunge ', ' loaf ', ' log ', ' shat ',
  ];
  static const _wordToilet = [
    ' toilet ', ' loo ', ' lavatory ', ' latrine ', ' outhouse ',
    ' can ', ' throne ', ' john ',
  ];
  static const _wordRemove = [
    ' remove ', ' drop ', ' shed ', ' discard ', ' rid ', ' unload ',
    ' withdraw ', ' off ',
  ];
  static const _wordPants = [
    ' pants ', ' jeans ', ' bloomers ', ' sweats ', ' boxers ',
    ' knickers ', ' underwear ', ' briefs ', ' slacks ', ' trousers ',
    ' pantaloons ', ' underpants ', ' shorts ', ' denim ', ' britches ',
    ' drawers ',
  ];
  static const _wordOn = [' on ', ' wear ', ' dress ', ' equip '];
  static const _wordFart = [' fart ', ' flatulate '];
  static const _wordLightly = [
    ' lightly ', ' easy ', ' gently ', ' light ', ' slowly ', ' slow ',
    ' soft ', ' softly ', ' little ', ' small ', ' tiny ', ' micro ',
  ];
  static const _wordTake = [' take '];
  static const _wordOpen = [' open ', ' unlock ', ' push '];
  static const _wordBreak = [
    ' break ', ' attack ', ' damage ', ' hit ', ' punch ', ' kick ',
    ' headbutt ', ' smash ', ' bash ', ' crash ',
  ];
  static const _wordLook = [
    ' check ', ' search ', ' look ', ' dig ', ' examine ', ' see ',
    ' inspect ',
  ];
  static const _wordPocket = [' pocket ', ' pockets '];
  static const _wordClose = [' close ', ' shut ', ' slam '];
  static const _wordDoor = [' door ', ' entrance ', ' entranceway '];
  static const _wordSit = [' sit '];
  static const _wordStand = [' stand '];
  static const _wordFloor = [' floor ', ' ground ', ' carpet '];
  static const _wordRoom = [
    ' around ', ' room ', ' area ', ' space ', ' place ',
    ' surroundings ', ' environment ', ' location ', ' setting ',
  ];
  static const _wordWashroom = [' washroom ', ' bathroom ', ' restroom '];
  static const _wordPills = [' pills ', ' drugs ', ' medicine ', ' pill '];
  static const _wordEat = [' eat ', ' consume ', ' use '];
  static const _wordPull = [' pull ', ' yank '];
  static const _wordDont = [" don't ", ' do not ', ' dont '];
  static const _wordDie = [' die ', ' kill ', ' suicide ', ' seppuku '];
  static const _wordSelf = [' yourself ', ' self '];
  static const _wordQuit = [' quit ', ' menu '];
  static const _wordUp = [' up ', ' off '];
  static const _wordShirt = [' shirt '];
  static const _wordClothes = [' clothes '];
  static const _wordHair = [' hair ', ' head '];
  static const _wordMove = [' move ', ' go ', ' walk ', ' enter '];
  static const _wordShoes = [' shoes ', ' feet ', ' sandals ', ' toes ', ' slippers '];

  bool _oneWord = false;
  bool get oneWord => _oneWord;

  String parse(String input) {
    final holder = ' ${input.toLowerCase().replaceAll('\r', '')} ';
    _oneWord = !input.contains(' ');

    final words = <ParsedWord>[];

    void scan(List<String> variants, String tag) {
      for (final v in variants) {
        final idx = holder.indexOf(v);
        if (idx != -1) words.add(ParsedWord(tag, idx));
      }
    }

    scan(_wordShit, 'shit');
    scan(_wordToilet, 'toilet');
    scan(_wordRemove, 'remove');
    scan(_wordPants, 'pants');
    scan(_wordOn, 'on');
    scan(_wordFart, 'fart');
    scan(_wordLightly, 'lightly');
    scan(_wordTake, 'take');
    scan(_wordOpen, 'open');
    scan(_wordBreak, 'break');
    scan(_wordLook, 'look');
    scan(_wordPocket, 'pocket');
    scan(_wordClose, 'close');
    scan(_wordDoor, 'door');
    scan(_wordSit, 'sit');
    scan(_wordStand, 'stand');
    scan(_wordFloor, 'floor');
    scan(_wordRoom, 'room');
    scan(_wordWashroom, 'washroom');
    scan(_wordPills, 'pills');
    scan(_wordEat, 'eat');
    scan(_wordPull, 'pull');
    scan(_wordDont, "don't");
    scan(_wordDie, 'die');
    scan(_wordSelf, 'yourself');
    scan(_wordQuit, 'quit');
    scan(_wordUp, 'up');
    scan(_wordShirt, 'shirt');
    scan(_wordClothes, 'clothes');
    scan(_wordHair, 'hair');
    scan(_wordMove, 'move');
    scan(_wordShoes, 'shoes');

    words.sort((a, b) => a.index.compareTo(b.index));
    return words.map((w) => ' ${w.word}').join('');
  }
}
