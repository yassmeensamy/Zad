// State B of the Date & Ember home — the joined-team summary card ("Companions
// of Sabr", level/rank chip, stacked member avatars and weekly XP). Split out
// from temp.dart as a part file so it can share the screen's private palette
// (`_C`), font roles (`_F`), the `_GlassCard` shell and the `_goldDisc`
// gradient without exposing or duplicating them.
part of 'temp.dart';

class TempTeamCard extends StatelessWidget {
  const TempTeamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      // Amber glow from the top-left corner.
      extraGradient: const RadialGradient(
        center: Alignment(-1, -1),
        radius: 1.2,
        colors: [Color(0x29E1A560), Color(0x00E1A560)],
        stops: [0.0, 0.55],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Team crest disc with Arabic "ص".
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: _goldDisc,
                  boxShadow: const [
                    BoxShadow(color: Color(0x73E1A560), spreadRadius: 1.5),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ص',
                  style: TextStyle(
                    fontFamily: _F.arabic,
                    fontSize: 22,
                    color: _C.ink,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL 6 · DAʿWAH',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8.5 * 0.26,
                        color: _C.amber,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Companions of Sabr',
                      style: TextStyle(
                        fontFamily: _F.serif,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        height: 1.05,
                        color: _C.ivory,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Rank chip.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0x24C9512B),
                  border: Border.all(color: const Color(0x52E07A48)),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#14',
                      style: TextStyle(
                        fontFamily: _F.serif,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        height: 1,
                        color: _C.emberLight,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'RANK',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 7.5 * 0.18,
                        color: _C.txtMute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _C.hairline),
          const SizedBox(height: 13),
          Row(
            children: [
              // Stacked member avatars + overflow.
              // 3 avatars at 19px offsets + the "+9" chip at 3*19, each 28 wide
              // → total 3*19 + 28 = 85px. The Stack holds only Positioned
              // children, so it needs an explicit width.
              SizedBox(
                width: 85,
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _memberAvatar(0, 'Y',
                        const [Color(0xFFF1C57A), Color(0xFFA6622A)], _C.ink),
                    _memberAvatar(1, 'A',
                        const [Color(0xFFA6B584), Color(0xFF42502E)],
                        const Color(0xFF1A2010)),
                    _memberAvatar(2, 'F',
                        const [Color(0xFFE8A877), Color(0xFF7A2E15)],
                        const Color(0xFF2A1206)),
                    Positioned(
                      left: 3 * 19.0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x14F4ECD8),
                          border: Border.all(color: _C.surface, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+9',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _C.ivory,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text.rich(
                TextSpan(
                  text: 'You\'re ',
                  style: TextStyle(fontSize: 10.5, color: _C.txtMute),
                  children: [
                    TextSpan(
                      text: '+340 XP',
                      style: TextStyle(
                        fontFamily: _F.mono,
                        color: _C.olive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' this week'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberAvatar(int index, String letter, List<Color> colors, Color ink) {
    return Positioned(
      left: index * 19.0,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.36, -0.44),
            radius: 0.9,
            colors: colors,
          ),
          border: Border.all(color: _C.surface, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: _F.serif,
            fontSize: 11,
            color: ink,
          ),
        ),
      ),
    );
  }
}
