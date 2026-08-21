import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/themes/application/theme_controller.dart';

void main() {
  group('theme media policy', () {
    test('accepts local images and MP4 videos up to thirty seconds', () async {
      final controller = ThemeController(store: _RecordingThemeStore());

      expect(
        await controller.selectThemeAsset(
          const ThemeAssetCandidate(
            id: 'image-theme',
            localPath: '/themes/aurora.webp',
            mimeType: 'image/webp',
            kind: ThemeAssetKind.image,
          ),
        ),
        isTrue,
      );
      expect(
        await controller.selectThemeAsset(
          const ThemeAssetCandidate(
            id: 'video-theme',
            localPath: '/themes/space.mp4',
            mimeType: 'video/mp4',
            kind: ThemeAssetKind.video,
            duration: Duration(seconds: 30),
            posterPath: '/themes/space-poster.webp',
          ),
        ),
        isTrue,
      );
      expect(controller.syncEnabled, isFalse);
    });

    test('rejects videos over thirty seconds and non-MP4 video', () async {
      final controller = ThemeController(store: _RecordingThemeStore());

      expect(
        await controller.selectThemeAsset(
          const ThemeAssetCandidate(
            id: 'long-video',
            localPath: '/themes/long.mp4',
            mimeType: 'video/mp4',
            kind: ThemeAssetKind.video,
            duration: Duration(milliseconds: 30001),
            posterPath: '/themes/long-poster.webp',
          ),
        ),
        isFalse,
      );
      expect(controller.validationMessage, contains('30 seconds'));

      expect(
        await controller.selectThemeAsset(
          const ThemeAssetCandidate(
            id: 'quicktime-video',
            localPath: '/themes/clip.mov',
            mimeType: 'video/quicktime',
            kind: ThemeAssetKind.video,
            duration: Duration(seconds: 10),
            posterPath: '/themes/clip-poster.webp',
          ),
        ),
        isFalse,
      );
    });

    test('uses poster fallback and pauses playback when required', () async {
      final controller = ThemeController(store: _RecordingThemeStore());
      await controller.selectThemeAsset(
        const ThemeAssetCandidate(
          id: 'motion-theme',
          localPath: '/themes/motion.mp4',
          mimeType: 'video/mp4',
          kind: ThemeAssetKind.video,
          duration: Duration(seconds: 12),
          posterPath: '/themes/motion-poster.webp',
        ),
      );

      controller.updateEnvironment(reducedMotion: true);
      expect(controller.presentation.assetPath, endsWith('motion-poster.webp'));
      expect(controller.presentation.shouldPlayVideo, isFalse);

      controller.updateEnvironment(reducedMotion: false, appForeground: false);
      expect(controller.presentation.shouldPlayVideo, isFalse);

      controller.updateEnvironment(appForeground: true, batterySaver: true);
      expect(controller.presentation.assetPath, endsWith('motion-poster.webp'));
      expect(controller.presentation.shouldPlayVideo, isFalse);

      controller.updateSettings(controller.settings.copyWith(dimming: 0.05));
      expect(
        controller.presentation.contrastScrimOpacity,
        greaterThanOrEqualTo(0.4),
      );
    });

    test(
      'activation failure rolls back to the previous active theme',
      () async {
        final store = _RecordingThemeStore();
        final controller = ThemeController(store: store);
        const original = ThemeAssetCandidate(
          id: 'original',
          localPath: '/themes/original.webp',
          mimeType: 'image/webp',
          kind: ThemeAssetKind.image,
        );
        const replacement = ThemeAssetCandidate(
          id: 'replacement',
          localPath: '/themes/replacement.webp',
          mimeType: 'image/webp',
          kind: ThemeAssetKind.image,
        );

        await controller.selectThemeAsset(original);
        expect(await controller.activateSelected(), isTrue);
        store.failNextCommit = true;
        await controller.selectThemeAsset(replacement);

        expect(await controller.activateSelected(), isFalse);
        expect(controller.activeAsset?.id, 'original');
        expect(store.rollbackIds, <String?>['original']);
      },
    );
  });
}

final class _RecordingThemeStore implements ThemeActivationStore {
  bool failNextCommit = false;
  final List<String> stagedIds = <String>[];
  final List<String> committedIds = <String>[];
  final List<String?> rollbackIds = <String?>[];

  @override
  Future<void> stage(ThemeAssetCandidate candidate) async {
    stagedIds.add(candidate.id);
  }

  @override
  Future<void> commit(String candidateId) async {
    if (failNextCommit) {
      failNextCommit = false;
      throw StateError('simulated activation failure');
    }
    committedIds.add(candidateId);
  }

  @override
  Future<void> rollbackTo(String? candidateId) async {
    rollbackIds.add(candidateId);
  }
}
