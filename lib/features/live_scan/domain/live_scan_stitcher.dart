import 'dart:math' as math;

class LiveScanObservation {
  const LiveScanObservation({
    required this.frame,
    required this.capturedAt,
    required this.text,
    required this.roi,
    this.confidence,
  });

  final int frame;
  final DateTime capturedAt;
  final String text;

  /// Normalized left, top, width and height, retained for provenance.
  final List<double> roi;
  final double? confidence;
}

class LiveScanGap {
  const LiveScanGap({required this.afterFrame, required this.beforeFrame});
  final int afterFrame;
  final int beforeFrame;
}

class LiveScanResult {
  const LiveScanResult({
    required this.text,
    required this.observations,
    required this.gaps,
    required this.duplicateFrameCount,
  });

  final String text;
  final List<LiveScanObservation> observations;
  final List<LiveScanGap> gaps;
  final int duplicateFrameCount;
  bool get needsReview =>
      gaps.isNotEmpty ||
      observations.any((o) => o.confidence == null || o.confidence! < .65);
}

/// Conservative text overlap reconstruction. Input order is irrelevant; source
/// observations are always kept, including frames whose text was deduplicated.
class LiveScanStitcher {
  LiveScanStitcher({this.minimumOverlap = 2, this.minimumSimilarity = .72});

  final int minimumOverlap;
  final double minimumSimilarity;
  final List<LiveScanObservation> _observations = [];

  void add(LiveScanObservation observation) {
    if (observation.text.trim().isEmpty || observation.roi.length != 4) return;
    _observations.add(observation);
  }

  LiveScanResult build() {
    final ordered = [..._observations]
      ..sort((a, b) {
        final byTime = a.capturedAt.compareTo(b.capturedAt);
        return byTime == 0 ? a.frame.compareTo(b.frame) : byTime;
      });
    final unique = <LiveScanObservation>[];
    var duplicateFrames = 0;
    for (final current in ordered) {
      if (unique.any(
        (previous) =>
            _sameCapture(previous.text, current.text) &&
            (identical(previous, unique.last) ||
                _normalizedLength(current.text) >= 64),
      )) {
        duplicateFrames++;
      } else {
        unique.add(current);
      }
    }

    final merged = <String>[];
    final gaps = <LiveScanGap>[];
    LiveScanObservation? previous;
    for (final observation in unique) {
      final incoming = _tokens(observation.text);
      if (incoming.isEmpty) continue;
      if (merged.isEmpty) {
        merged.addAll(incoming);
        previous = observation;
        continue;
      }
      final overlap = _bestOverlap(merged, incoming);
      if (overlap.count >= minimumOverlap &&
          overlap.score >= minimumSimilarity) {
        merged.addAll(incoming.skip(overlap.count));
      } else {
        // Preserve all text rather than guessing a merge; signal that continuity
        // cannot be verified, even if the segments may in fact be adjacent.
        gaps.add(
          LiveScanGap(
            afterFrame: previous?.frame ?? observation.frame,
            beforeFrame: observation.frame,
          ),
        );
        merged.addAll(incoming);
      }
      previous = observation;
    }
    return LiveScanResult(
      text: merged.join(' '),
      observations: List.unmodifiable(ordered),
      gaps: List.unmodifiable(gaps),
      duplicateFrameCount: duplicateFrames,
    );
  }

  static List<String> _tokens(String text) => text
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ')
      .where((token) => token.isNotEmpty)
      .toList();

  bool _sameCapture(String previous, String current) {
    final left = _normalizeCapture(previous);
    final right = _normalizeCapture(current);
    if (left == right) return true;
    if (left.length < 64 || right.length < 64) return false;
    final similarity =
        1 - _levenshtein(left, right) / math.max(left.length, right.length);
    return similarity >= .92;
  }

  int _normalizedLength(String text) => _normalizeCapture(text).length;

  String _normalizeCapture(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  ({int count, double score}) _bestOverlap(
    List<String> left,
    List<String> right,
  ) {
    final max = math.min(left.length, right.length);
    // Prefer exact token alignment. A shorter exact overlap is safer than a
    // longer fuzzy candidate that might discard a repeated word/clause.
    for (var count = max; count >= 1; count--) {
      var exact = true;
      for (var i = 0; i < count; i++) {
        if (_similar(left[left.length - count + i], right[i]) != 1) {
          exact = false;
          break;
        }
      }
      if (exact && count >= minimumOverlap) {
        return (count: count, score: 1);
      }
    }
    for (var count = max; count >= minimumOverlap; count--) {
      var matches = 0;
      for (var i = 0; i < count; i++) {
        if (_similar(left[left.length - count + i], right[i]) >=
            minimumSimilarity) {
          matches++;
        }
      }
      final score = matches / count;
      if (score >= math.max(minimumSimilarity, .85)) {
        return (count: count, score: score);
      }
    }
    return (count: 0, score: 0);
  }

  double _similar(String a, String b) {
    final left = a.toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{N}]', unicode: true),
      '',
    );
    final right = b.toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{N}]', unicode: true),
      '',
    );
    if (left == right) return 1;
    if (left.isEmpty || right.isEmpty) return 0;
    return 1 - _levenshtein(left, right) / math.max(left.length, right.length);
  }

  int _levenshtein(String a, String b) {
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0)..[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        current[j + 1] = math.min(
          math.min(current[j] + 1, previous[j + 1] + 1),
          previous[j] + (a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1),
        );
      }
      previous = current;
    }
    return previous.last;
  }
}
