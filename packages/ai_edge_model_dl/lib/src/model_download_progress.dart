/// Progress information for model downloads
class ModelDownloadProgress {
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double bytesPerSecond;
  final Duration estimatedTimeRemaining;

  const ModelDownloadProgress({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.bytesPerSecond,
    required this.estimatedTimeRemaining,
  });

  factory ModelDownloadProgress.calculate({
    required int downloadedBytes,
    required int totalBytes,
    required DateTime startTime,
    required int sessionStartBytes,
  }) {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(startTime).inMilliseconds / 1000.0;
    // Calculate speed based on bytes downloaded in this session only
    final sessionBytes = downloadedBytes - sessionStartBytes;
    final currentSpeed = elapsedSeconds > 0 ? sessionBytes / elapsedSeconds : 0;
    final remainingBytes = totalBytes - downloadedBytes;
    final estimatedSeconds = currentSpeed > 0
        ? (remainingBytes / currentSpeed).round()
        : 0;

    return ModelDownloadProgress(
      progress: downloadedBytes / totalBytes,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      bytesPerSecond: currentSpeed.toDouble(),
      estimatedTimeRemaining: Duration(seconds: estimatedSeconds),
    );
  }

  String get downloadedSize => _formatBytes(downloadedBytes);
  String get totalSize => _formatBytes(totalBytes);
  String get speed => '${_formatBytes(bytesPerSecond.round())}/s';

  /// Default formatted remaining time (e.g., "1:23:45")
  String get remainingTime {
    if (estimatedTimeRemaining.inHours > 0) {
      return formatRemainingTime('H:MM:SS');
    } else if (estimatedTimeRemaining.inMinutes > 0) {
      return formatRemainingTime('M:SS');
    } else {
      return formatRemainingTime('Ss');
    }
  }

  /// Format remaining time with custom pattern
  /// Patterns:
  /// - HH: Hours with leading zero (01, 12, 25)
  /// - H: Hours without leading zero (1, 12, 25)
  /// - MM: Minutes with leading zero (00-59)
  /// - M: Minutes without leading zero (0-59)
  /// - mm: Total minutes (can be > 59)
  /// - SS: Seconds with leading zero (00-59)
  /// - S: Seconds without leading zero (0-59)
  /// - ss: Total seconds (can be > 59)
  ///
  /// Examples:
  /// - "HH:MM:SS" -> "01:23:45"
  /// - "H hours M minutes" -> "1 hours 23 minutes"
  /// - "mm:SS" -> "83:45" (total minutes)
  String formatRemainingTime(String pattern) {
    final duration = estimatedTimeRemaining;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final totalMinutes = duration.inMinutes;
    final totalSeconds = duration.inSeconds;

    return pattern
        .replaceAll('HH', hours.toString().padLeft(2, '0'))
        .replaceAll('H', hours.toString())
        .replaceAll('mm', totalMinutes.toString())
        .replaceAll('MM', minutes.toString().padLeft(2, '0'))
        .replaceAll('M', minutes.toString())
        .replaceAll('ss', totalSeconds.toString())
        .replaceAll('SS', seconds.toString().padLeft(2, '0'))
        .replaceAll('S', seconds.toString());
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
