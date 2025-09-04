class DownloadProgress {
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double bytesPerSecond;
  final Duration estimatedTimeRemaining;

  const DownloadProgress({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.bytesPerSecond,
    required this.estimatedTimeRemaining,
  });

  String get downloadedSize => _formatBytes(downloadedBytes);
  String get totalSize => _formatBytes(totalBytes);
  String get speed => '${_formatBytes(bytesPerSecond.round())}/s';

  String get remainingTime {
    if (estimatedTimeRemaining.inSeconds < 60) {
      return '${estimatedTimeRemaining.inSeconds}s';
    } else if (estimatedTimeRemaining.inMinutes < 60) {
      return '${estimatedTimeRemaining.inMinutes}m ${estimatedTimeRemaining.inSeconds % 60}s';
    } else {
      final hours = estimatedTimeRemaining.inHours;
      final minutes = estimatedTimeRemaining.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
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
