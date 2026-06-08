// State A of the Date & Ember home — the "Walk the path together" join card
// shown before the user belongs to a team. Split out from temp.dart as a part
// file so it can share the screen's private palette (`_C`), font roles (`_F`),
// glass-card shell (`_GlassCard`) and button styles (`_PrimaryButton` /
// `_GhostButton`) without exposing or duplicating them.
part of 'temp.dart';

class TempJoinTeamCard extends StatelessWidget {
  const TempJoinTeamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        children: [
          // Crest — halo + glass disc holding a companions glyph.
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x52F1C57A), Color(0x00F1C57A)],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1AF4ECD8), Color(0x08F4ECD8)],
                    ),
                    border: Border.all(color: const Color(0x80E1A560), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.groups_outlined,
                      size: 28, color: _C.amberLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Walk the path together.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _F.serif,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontSize: 21,
              height: 1.05,
              color: _C.ivory,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'Join a circle of companions to study, recite, and rise '
              'together — or start your own.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: _C.txtMute, height: 1.5),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  label: 'Create',
                  trailingIcon: Icons.add_rounded,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _GhostButton(label: 'Join with code', onTap: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
