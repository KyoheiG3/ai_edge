import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelDownloadProgress', () {
    group('calculate', () {
      test('should calculate progress metrics correctly', () {
        // Given
        final startTime = DateTime.now().subtract(const Duration(seconds: 5));
        const downloadedBytes = 50;
        const totalBytes = 100;
        const sessionStartBytes = 0;

        // When
        final progress = ModelDownloadProgress.calculate(
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          startTime: startTime,
          sessionStartBytes: sessionStartBytes,
        );

        // Then
        expect(progress.progress, 0.5);
        expect(progress.downloadedBytes, downloadedBytes);
        expect(progress.totalBytes, totalBytes);
        expect(progress.bytesPerSecond, greaterThan(0));
        expect(progress.estimatedTimeRemaining.inSeconds, greaterThan(0));
      });

      group('when download is resumed', () {
        test('should calculate speed based on session bytes only', () {
          // Given
          final startTime = DateTime.now().subtract(const Duration(seconds: 2));
          const downloadedBytes = 80; // Total downloaded
          const totalBytes = 100;
          const sessionStartBytes = 50; // Already had 50 bytes

          // When
          final progress = ModelDownloadProgress.calculate(
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            startTime: startTime,
            sessionStartBytes: sessionStartBytes,
          );

          // Then
          // Speed should be based on (80-50)/2 = 15 bytes/sec
          expect(progress.bytesPerSecond, closeTo(15, 1));
        });
      });

      test('should handle zero total bytes', () {
        // Given
        final startTime = DateTime.now();
        const downloadedBytes = 0;
        const totalBytes = 0;
        const sessionStartBytes = 0;

        // When
        final progress = ModelDownloadProgress.calculate(
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          startTime: startTime,
          sessionStartBytes: sessionStartBytes,
        );

        // Then
        expect(progress.progress.isNaN || progress.progress == 0.0, true);
        expect(progress.downloadedBytes, 0);
        expect(progress.totalBytes, 0);
        expect(progress.bytesPerSecond, 0.0);
        expect(progress.estimatedTimeRemaining, Duration.zero);
      });

      test('should handle completed download', () {
        // Given
        final startTime = DateTime.now().subtract(const Duration(seconds: 10));
        const downloadedBytes = 1000;
        const totalBytes = 1000;
        const sessionStartBytes = 0;

        // When
        final progress = ModelDownloadProgress.calculate(
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          startTime: startTime,
          sessionStartBytes: sessionStartBytes,
        );

        // Then
        expect(progress.progress, 1.0);
        expect(progress.estimatedTimeRemaining, Duration.zero);
      });
    });

    group('formatting', () {
      test('should format all display values correctly', () {
        const progress = ModelDownloadProgress(
          progress: 0.5,
          downloadedBytes: 1536, // 1.5 KB
          totalBytes: 1048576, // 1 MB
          bytesPerSecond: 2097152, // 2 MB/s
          estimatedTimeRemaining: Duration(hours: 1, minutes: 23, seconds: 45),
        );

        expect(progress.downloadedSize, '1.5 KB');
        expect(progress.totalSize, '1.0 MB');
        expect(progress.speed, '2.0 MB/s');
        expect(progress.remainingTime, '1:23:45');
      });

      test('should format remaining time based on duration length', () {
        // Less than 1 minute - uses Ss format
        const veryShortDuration = ModelDownloadProgress(
          progress: 0.5,
          downloadedBytes: 500,
          totalBytes: 1000,
          bytesPerSecond: 10,
          estimatedTimeRemaining: Duration(seconds: 45),
        );
        expect(veryShortDuration.remainingTime, '45s');

        // Between 1 minute and 1 hour - uses M:SS format
        const shortDuration = ModelDownloadProgress(
          progress: 0.5,
          downloadedBytes: 500,
          totalBytes: 1000,
          bytesPerSecond: 10,
          estimatedTimeRemaining: Duration(minutes: 5, seconds: 30),
        );
        expect(shortDuration.remainingTime, '5:30');

        // More than 1 hour - uses H:MM:SS format
        const longDuration = ModelDownloadProgress(
          progress: 0.5,
          downloadedBytes: 500,
          totalBytes: 1000,
          bytesPerSecond: 10,
          estimatedTimeRemaining: Duration(hours: 1, minutes: 23, seconds: 45),
        );
        expect(longDuration.remainingTime, '1:23:45');
      });

      test('should format with custom pattern', () {
        const progress = ModelDownloadProgress(
          progress: 0.5,
          downloadedBytes: 500,
          totalBytes: 1000,
          bytesPerSecond: 10,
          estimatedTimeRemaining: Duration(hours: 1, minutes: 23, seconds: 45),
        );
        expect(
          progress.formatRemainingTime('H hours M minutes'),
          '1 hours 23 minutes',
        );
        expect(progress.formatRemainingTime('HH:MM:SS'), '01:23:45');
      });
    });

    group('edge cases', () {
      group('when bytes are small', () {
        test('should format as bytes', () {
          const progress = ModelDownloadProgress(
            progress: 0.1,
            downloadedBytes: 512,
            totalBytes: 5120,
            bytesPerSecond: 100,
            estimatedTimeRemaining: Duration(seconds: 45),
          );

          expect(progress.downloadedSize, '512 B');
          expect(progress.speed, '100 B/s');
        });
      });

      group('when bytes are in GB range', () {
        test('should format as GB', () {
          const progress = ModelDownloadProgress(
            progress: 0.5,
            downloadedBytes: 5368709120, // 5 GB
            totalBytes: 10737418240, // 10 GB
            bytesPerSecond: 10485760, // 10 MB/s
            estimatedTimeRemaining: Duration(minutes: 8, seconds: 30),
          );

          expect(progress.downloadedSize, '5.00 GB');
          expect(progress.totalSize, '10.00 GB');
          expect(progress.speed, '10.0 MB/s');
        });
      });

      group('when speed is zero', () {
        test('should handle division by zero for remaining time', () {
          const progress = ModelDownloadProgress(
            progress: 0.5,
            downloadedBytes: 500,
            totalBytes: 1000,
            bytesPerSecond: 0,
            estimatedTimeRemaining: Duration.zero,
          );

          expect(progress.speed, '0 B/s');
          expect(progress.estimatedTimeRemaining, Duration.zero);
        });
      });

      test('should format zero bytes correctly', () {
        const progress = ModelDownloadProgress(
          progress: 0,
          downloadedBytes: 0,
          totalBytes: 1000,
          bytesPerSecond: 0,
          estimatedTimeRemaining: Duration.zero,
        );

        expect(progress.downloadedSize, '0 B');
        expect(progress.speed, '0 B/s');
      });
    });
  });
}
