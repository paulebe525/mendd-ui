import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mendd_ui/mendd_ui.dart';

Widget app(MenddBrand b, Widget child) => MaterialApp(theme: menddTheme(b), home: Scaffold(body: Center(child: child)));

void main() {
  group('brand tokens (sampled from brand/ files)', () {
    test('exact values', () {
      expect(MenddColors.green, const Color(0xFF015F4E));
      expect(MenddColors.greenDark, const Color(0xFF015444));
      expect(MenddColors.orange, const Color(0xFFFE6802));
      expect(MenddColors.purple, const Color(0xFF540191));
      expect(MenddColors.purpleDark, const Color(0xFF43027D));
    });

    test('text contrast is AA (≥ 4.5:1) for every text/background pair we use', () {
      for (final (fg, bg, name) in [
        (Colors.white, MenddColors.green, 'white on green'),
        (Colors.white, MenddColors.greenDark, 'white on green dark'),
        (MenddColors.green, Colors.white, 'green on white'),
        (Colors.white, MenddColors.purple, 'white on purple'),
        (Colors.white, MenddColors.purpleDark, 'white on purple dark'),
        (MenddColors.purple, Colors.white, 'purple on white'),
        (MenddColors.ink, Colors.white, 'ink on white'),
        (MenddColors.muted, Colors.white, 'muted on white'),
        (MenddColors.danger, Colors.white, 'danger on white'),
        (Colors.white, MenddColors.testMode, 'white on test red'),
      ]) {
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
      }
    });

    test('orange is never used for text: it fails 4.5:1, and needs the outline for 3:1 non-text', () {
      expect(contrastRatio(MenddColors.orange, Colors.white), lessThan(3.0)); // 2.92: why stars get an outline
      expect(contrastRatio(MenddColors.accentOutline, Colors.white), greaterThanOrEqualTo(3.0));
    });

    test('theme primaries are the brand colours', () {
      expect(menddTheme(MenddBrand.customer).colorScheme.primary, MenddColors.green);
      expect(menddTheme(MenddBrand.partner).colorScheme.primary, MenddColors.purple);
    });

    test('type scale: body ≥ 16, small ≥ 14', () {
      final t = menddTheme(MenddBrand.customer).textTheme;
      for (final s in [t.bodyLarge, t.bodyMedium, t.titleSmall, t.labelLarge]) {
        expect(s!.fontSize, greaterThanOrEqualTo(MenddA11y.minBody));
      }
      for (final s in [t.bodySmall, t.labelMedium, t.labelSmall]) {
        expect(s!.fontSize, greaterThanOrEqualTo(MenddA11y.minSmall));
      }
    });
  });

  group('48 dp touch targets', () {
    for (final b in MenddBrand.values) {
      testWidgets('buttons and icon buttons are ≥ 48×48 ($b)', (t) async {
        await t.pumpWidget(app(b, Column(mainAxisSize: MainAxisSize.min, children: [
          FilledButton(onPressed: () {}, child: const Text('OK')),
          OutlinedButton(onPressed: () {}, child: const Text('No')),
          TextButton(onPressed: () {}, child: const Text('x')),
          IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        ])));
        for (final f in [find.byType(FilledButton), find.byType(OutlinedButton), find.byType(TextButton), find.byType(IconButton)]) {
          final size = t.getSize(f);
          expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
          expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
        }
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));
      });
    }

    testWidgets('rating input: 5 targets of ≥ 48 dp; tap sets the value', (t) async {
      int? picked;
      await t.pumpWidget(app(MenddBrand.customer, RatingStars(value: 0, onChanged: (v) => picked = v)));
      final targets = find.byType(InkResponse);
      expect(targets, findsNWidgets(5));
      expect(t.getSize(targets.first).height, greaterThanOrEqualTo(48));
      await t.tap(targets.at(3));
      expect(picked, 4);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    });
  });

  group('widgets', () {
    testWidgets('rating display is labelled in words, not colour alone', (t) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(app(MenddBrand.customer, const RatingStars(value: 4)));
      expect(find.bySemanticsLabel('4 of 5 stars'), findsOneWidget);
      h.dispose();
    });

    testWidgets('StateView: empty, error with action, success, loading', (t) async {
      await t.pumpWidget(app(MenddBrand.customer, StateView.error(title: 'Could not load', message: 'Check your internet.',
          action: FilledButton(onPressed: () {}, child: const Text('Try again')))));
      expect(find.text('Could not load'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await t.pumpWidget(app(MenddBrand.customer, const StateView.empty(title: 'No requests yet')));
      expect(find.text('No requests yet'), findsOneWidget);
      await t.pumpWidget(app(MenddBrand.customer, const StateView.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('BusyButton: spinner + disabled while busy, full width', (t) async {
      var taps = 0;
      await t.pumpWidget(app(MenddBrand.partner, BusyButton(busy: true, onPressed: () => taps++, label: 'Save', busyLabel: 'Saving…')));
      expect(find.text('Saving…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.tap(find.text('Saving…'), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('TestModeBanner: only when enabled', (t) async {
      await t.pumpWidget(MaterialApp(home: TestModeBanner(enabled: true, child: const Text('x'))));
      expect(find.textContaining('TEST MODE'), findsOneWidget);
      await t.pumpWidget(MaterialApp(home: TestModeBanner(enabled: false, child: const Text('x'))));
      expect(find.textContaining('TEST MODE'), findsNothing);
    });

    testWidgets('translated texts: set once, used by friendlyError, SaveRunner and BusyButton', (t) async {
      addTearDown(() => MenddFeedbackText.current = const MenddFeedbackText());
      MenddFeedbackText.current = const MenddFeedbackText(saving: 'சேமிக்கிறது…', offline: 'இணையம் இல்லை.');
      expect(friendlyError(_Coded('unavailable')), 'இணையம் இல்லை. (unavailable)');
      await t.pumpWidget(app(MenddBrand.customer, BusyButton(busy: true, onPressed: () {}, label: 'Save')));
      expect(find.text('சேமிக்கிறது…'), findsOneWidget);
    });

    testWidgets('BusyButton without busyLabel shows "Saving…" while busy', (t) async {
      await t.pumpWidget(app(MenddBrand.partner, BusyButton(busy: true, onPressed: () {}, label: 'Save')));
      expect(find.text('Saving…'), findsOneWidget);
    });

    test('friendlyError maps codes without depending on Firebase', () {
      expect(friendlyError(_Coded('permission-denied')), startsWith('The server refused'));
      expect(friendlyError(_Coded('unavailable')), contains('(unavailable)'));
      expect(friendlyError(ArgumentError('Pick a service')), 'Pick a service');
      expect(friendlyError(StateError('x')), startsWith('Something went wrong.'));
    });
  });
}

class _Coded implements Exception {
  _Coded(this.code);
  final String code;
}
