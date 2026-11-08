import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/live_scan/domain/live_scan_stitcher.dart';

LiveScanObservation observation(int frame, String text, int minute) =>
    LiveScanObservation(
      frame: frame,
      capturedAt: DateTime.utc(2026, 1, 1, 0, minute),
      text: text,
      roi: const [.1, .2, .8, .6],
      confidence: .9,
    );

void main() {
  test('joins suffix/prefix overlap and preserves every observation', () {
    final stitcher = LiveScanStitcher();
    stitcher.add(observation(1, 'Terms apply to all users', 0));
    stitcher.add(observation(2, 'to all users unless stated otherwise', 1));

    final result = stitcher.build();
    expect(result.text, 'Terms apply to all users unless stated otherwise');
    expect(result.gaps, isEmpty);
    expect(result.observations, hasLength(2));
    expect(result.observations.first.roi, const [.1, .2, .8, .6]);
  });

  test('reorders observations by timestamp before stitching', () {
    final stitcher = LiveScanStitcher();
    stitcher.add(observation(2, 'to all users unless stated otherwise', 1));
    stitcher.add(observation(1, 'Terms apply to all users', 0));
    final result = stitcher.build();
    expect(result.observations.map((o) => o.frame), [1, 2]);
    expect(result.text, 'Terms apply to all users unless stated otherwise');
  });

  test('duplicate frame text is deduplicated but source is retained', () {
    final stitcher = LiveScanStitcher();
    stitcher.add(observation(1, 'Terms apply to all users', 0));
    stitcher.add(observation(2, 'Terms   apply to all users', 1));
    final result = stitcher.build();
    expect(result.text, 'Terms apply to all users');
    expect(result.duplicateFrameCount, 1);
    expect(result.observations, hasLength(2));
  });

  test('no overlap is retained and produces an explicit uncertainty gap', () {
    final stitcher = LiveScanStitcher();
    stitcher.add(observation(1, 'Your account information is private', 0));
    stitcher.add(observation(2, 'We retain records for legal compliance', 1));
    final result = stitcher.build();
    expect(
      result.text,
      'Your account information is private We retain records for legal compliance',
    );
    expect(result.gaps, hasLength(1));
    expect(result.gaps.single.beforeFrame, 2);
  });

  test(
    'identical clause in a later distinct segment is not silently erased',
    () {
      final stitcher = LiveScanStitcher(minimumOverlap: 3);
      stitcher.add(observation(1, 'Privacy rights are important', 0));
      stitcher.add(observation(2, 'Sharing data needs consent', 1));
      stitcher.add(observation(3, 'Privacy rights are important', 2));
      final result = stitcher.build();
      expect(
        result.text,
        'Privacy rights are important Sharing data needs consent Privacy rights are important',
      );
      expect(result.duplicateFrameCount, 0);
      expect(result.gaps, hasLength(2));
    },
  );

  test('rescanning an already captured paragraph does not append it twice', () {
    const paragraph =
        'We collect account details to provide the service and protect your account. '
        'We retain this information only for the period required by applicable law.';
    final stitcher = LiveScanStitcher();
    stitcher.add(observation(1, paragraph, 0));
    stitcher.add(
      observation(2, 'Scroll to the next section of the policy.', 1),
    );
    stitcher.add(
      observation(3, paragraph.replaceFirst('protect', 'pr0tect'), 2),
    );

    final result = stitcher.build();
    expect(result.text, '$paragraph Scroll to the next section of the policy.');
    expect(result.duplicateFrameCount, 1);
    expect(result.observations, hasLength(3));
  });
}
