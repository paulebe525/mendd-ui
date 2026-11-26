import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// The Mendd theme for one app. Standard Material widgets (buttons, inputs,
/// cards, chips, navigation) pick up the brand colour, the type scale with
/// body ≥ 16 and small text ≥ 14, and 48 dp minimum touch targets.
ThemeData menddTheme(MenddBrand brand) {
  final primary = MenddColors.primary(brand);
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    onPrimary: Colors.white,
    error: MenddColors.danger,
    onError: Colors.white,
    surface: MenddColors.surface,
    onSurface: MenddColors.ink,
    onSurfaceVariant: MenddColors.muted,
    outlineVariant: MenddColors.line,
  );

  final base = Typography.material2021(platform: TargetPlatform.android).black;
  TextStyle? size(TextStyle? s, double px, [FontWeight? w]) =>
      s?.copyWith(fontSize: px, fontWeight: w ?? s.fontWeight, color: MenddColors.ink);
  final text = base.copyWith(
    displaySmall: size(base.displaySmall, 32, FontWeight.w700),
    headlineMedium: size(base.headlineMedium, 28, FontWeight.w700),
    headlineSmall: size(base.headlineSmall, 24, FontWeight.w700),
    titleLarge: size(base.titleLarge, 20, FontWeight.w600),
    titleMedium: size(base.titleMedium, 18, FontWeight.w600),
    titleSmall: size(base.titleSmall, 16, FontWeight.w600),
    bodyLarge: size(base.bodyLarge, 16),
    bodyMedium: size(base.bodyMedium, 16),
    bodySmall: size(base.bodySmall, 14)?.copyWith(color: MenddColors.muted),
    labelLarge: size(base.labelLarge, 16, FontWeight.w600),
    labelMedium: size(base.labelMedium, 14, FontWeight.w600),
    labelSmall: size(base.labelSmall, 14, FontWeight.w500),
  );

  const minSize = Size(MenddA11y.minTouch, MenddA11y.minTouch);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(MenddRadius.sm));
  const pad = EdgeInsets.symmetric(horizontal: MenddSpace.lg, vertical: MenddSpace.md);
  final label = text.labelLarge;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: text,
    scaffoldBackgroundColor: MenddColors.surface,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: MenddColors.surface,
      foregroundColor: MenddColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: text.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: minSize, shape: shape, padding: pad, textStyle: label),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: shape,
        padding: pad,
        textStyle: label,
        side: BorderSide(color: primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minSize, shape: shape, padding: pad, textStyle: label),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: minSize, shape: shape, padding: pad, textStyle: label),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: minSize)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(MenddRadius.sm)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MenddRadius.sm),
        borderSide: const BorderSide(color: MenddColors.muted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MenddRadius.sm),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: MenddSpace.md, vertical: MenddSpace.md),
      labelStyle: text.bodyLarge?.copyWith(color: MenddColors.muted),
      floatingLabelStyle: text.bodyMedium?.copyWith(color: primary),
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: MenddColors.danger),
      helperMaxLines: 3,
      errorMaxLines: 3,
    ),
    cardTheme: CardThemeData(
      color: MenddColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: MenddSpace.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MenddRadius.md),
        side: const BorderSide(color: MenddColors.line),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: text.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: MenddSpace.sm, vertical: MenddSpace.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MenddRadius.sm)),
    ),
    listTileTheme: ListTileThemeData(
      minTileHeight: 56,
      titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: text.bodyMedium?.copyWith(color: MenddColors.muted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MenddColors.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
    ),
    dividerTheme: const DividerThemeData(color: MenddColors.line, space: MenddSpace.xxl),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white)),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
  );
}
