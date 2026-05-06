import 'package:skeletonizer/skeletonizer.dart';

import '../../theme/theme.dart';

ShimmerEffect appShimmerEffect(AppColorsTheme colors) => ShimmerEffect(
      baseColor: colors.olive.withValues(alpha: 0.10),
      highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
    );
