/// A timed bar segment for overlap layout within a single day.
class TimedBarSegment {
  const TimedBarSegment({
    required this.id,
    required this.startMin,
    required this.endMin,
  });

  final String id;

  /// Minutes from local midnight, inclusive start.
  final int startMin;

  /// Minutes from local midnight, exclusive end.
  final int endMin;
}

/// Column placement for one bar within an overlap cluster.
class OverlapPlacement {
  const OverlapPlacement({required this.column, required this.columns});

  /// Zero-based column index within the overlap cluster.
  final int column;

  /// Total columns required by the cluster this bar belongs to.
  final int columns;
}

/// Greedy side-by-side layout for timed bars that overlap on the same day.
///
/// Bars are grouped into transitive-overlap clusters. Within each cluster each
/// bar is assigned the first free column; [OverlapPlacement.columns] is the
/// maximum column count in that cluster.
class DayOverlapLayout {
  const DayOverlapLayout._();

  /// Returns a map from bar [TimedBarSegment.id] to its [OverlapPlacement].
  static Map<String, OverlapPlacement> assign(List<TimedBarSegment> bars) {
    if (bars.isEmpty) return {};

    final sorted = List<TimedBarSegment>.from(bars)
      ..sort((a, b) {
        final cmp = a.startMin.compareTo(b.startMin);
        if (cmp != 0) return cmp;
        return a.endMin.compareTo(b.endMin);
      });

    final placements = <String, OverlapPlacement>{};
    var cluster = <TimedBarSegment>[];

    void flushCluster() {
      if (cluster.isEmpty) return;
      final clusterPlacements = _assignCluster(cluster);
      placements.addAll(clusterPlacements);
      cluster = [];
    }

    var clusterEnd = -1;
    for (final bar in sorted) {
      if (cluster.isEmpty || bar.startMin < clusterEnd) {
        cluster.add(bar);
        if (bar.endMin > clusterEnd) clusterEnd = bar.endMin;
      } else {
        flushCluster();
        cluster = [bar];
        clusterEnd = bar.endMin;
      }
    }
    flushCluster();

    return placements;
  }

  static Map<String, OverlapPlacement> _assignCluster(
    List<TimedBarSegment> cluster,
  ) {
    final laneEnds = <int>[];
    final columnById = <String, int>{};

    for (final bar in cluster) {
      var column = laneEnds.indexWhere((end) => bar.startMin >= end);
      if (column == -1) {
        column = laneEnds.length;
        laneEnds.add(bar.endMin);
      } else {
        laneEnds[column] = bar.endMin;
      }
      columnById[bar.id] = column;
    }

    final columns = laneEnds.length;
    return {
      for (final entry in columnById.entries)
        entry.key: OverlapPlacement(column: entry.value, columns: columns),
    };
  }
}
