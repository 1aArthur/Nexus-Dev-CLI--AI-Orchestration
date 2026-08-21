import 'package:flutter/foundation.dart';

enum ThemeAssetKind { image, video }

@immutable
final class ThemeAssetCandidate {
  const ThemeAssetCandidate({
    required this.id,
    required this.localPath,
    required this.mimeType,
    required this.kind,
    this.duration,
    this.posterPath,
  });

  final String id;
  final String localPath;
  final String mimeType;
  final ThemeAssetKind kind;
  final Duration? duration;
  final String? posterPath;
}

@immutable
final class ThemeEditorSettings {
  const ThemeEditorSettings({
    this.focalX = 0.5,
    this.focalY = 0.5,
    this.cropZoom = 1,
    this.blurSigma = 0,
    this.dimming = 0.45,
    this.loop = true,
    this.parallax = false,
  });

  final double focalX;
  final double focalY;
  final double cropZoom;
  final double blurSigma;
  final double dimming;
  final bool loop;
  final bool parallax;

  ThemeEditorSettings copyWith({
    double? focalX,
    double? focalY,
    double? cropZoom,
    double? blurSigma,
    double? dimming,
    bool? loop,
    bool? parallax,
  }) {
    return ThemeEditorSettings(
      focalX: focalX ?? this.focalX,
      focalY: focalY ?? this.focalY,
      cropZoom: cropZoom ?? this.cropZoom,
      blurSigma: blurSigma ?? this.blurSigma,
      dimming: dimming ?? this.dimming,
      loop: loop ?? this.loop,
      parallax: parallax ?? this.parallax,
    );
  }
}

@immutable
final class ThemePresentation {
  const ThemePresentation({
    required this.assetPath,
    required this.shouldPlayVideo,
    required this.contrastScrimOpacity,
    required this.settings,
  });

  final String? assetPath;
  final bool shouldPlayVideo;
  final double contrastScrimOpacity;
  final ThemeEditorSettings settings;
}

abstract interface class ThemeActivationStore {
  Future<void> stage(ThemeAssetCandidate candidate);

  Future<void> commit(String candidateId);

  Future<void> rollbackTo(String? candidateId);
}

final class ThemeController extends ChangeNotifier {
  ThemeController({required this.store});

  static const maximumVideoDuration = Duration(seconds: 30);
  static const minimumContrastScrim = 0.4;
  static const _imageMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final ThemeActivationStore store;
  ThemeAssetCandidate? _selectedAsset;
  ThemeAssetCandidate? _activeAsset;
  ThemeEditorSettings _settings = const ThemeEditorSettings();
  String? _validationMessage;
  bool _syncEnabled = false;
  bool _reducedMotion = false;
  bool _batterySaver = false;
  bool _appForeground = true;
  bool _activating = false;

  ThemeAssetCandidate? get selectedAsset => _selectedAsset;
  ThemeAssetCandidate? get activeAsset => _activeAsset;
  ThemeEditorSettings get settings => _settings;
  String? get validationMessage => _validationMessage;
  bool get syncEnabled => _syncEnabled;
  bool get activating => _activating;

  ThemePresentation get presentation {
    final asset = _selectedAsset ?? _activeAsset;
    final staticFallback =
        asset?.kind == ThemeAssetKind.video &&
        (_reducedMotion || _batterySaver);
    final assetPath = staticFallback ? asset?.posterPath : asset?.localPath;
    return ThemePresentation(
      assetPath: assetPath,
      shouldPlayVideo:
          asset?.kind == ThemeAssetKind.video &&
          !staticFallback &&
          _appForeground,
      contrastScrimOpacity: _settings.dimming < minimumContrastScrim
          ? minimumContrastScrim
          : _settings.dimming,
      settings: _settings,
    );
  }

  Future<bool> selectThemeAsset(ThemeAssetCandidate candidate) async {
    final error = _validate(candidate);
    if (error != null) {
      _validationMessage = error;
      notifyListeners();
      return false;
    }
    _selectedAsset = candidate;
    _validationMessage = null;
    notifyListeners();
    return true;
  }

  void updateSettings(ThemeEditorSettings settings) {
    _settings = ThemeEditorSettings(
      focalX: settings.focalX.clamp(0, 1).toDouble(),
      focalY: settings.focalY.clamp(0, 1).toDouble(),
      cropZoom: settings.cropZoom.clamp(1, 3).toDouble(),
      blurSigma: settings.blurSigma.clamp(0, 24).toDouble(),
      dimming: settings.dimming.clamp(0, 0.85).toDouble(),
      loop: settings.loop,
      parallax: settings.parallax,
    );
    notifyListeners();
  }

  void updateEnvironment({
    bool? reducedMotion,
    bool? batterySaver,
    bool? appForeground,
  }) {
    _reducedMotion = reducedMotion ?? _reducedMotion;
    _batterySaver = batterySaver ?? _batterySaver;
    _appForeground = appForeground ?? _appForeground;
    notifyListeners();
  }

  void setSyncEnabled(bool enabled) {
    _syncEnabled = enabled;
    notifyListeners();
  }

  Future<bool> activateSelected() async {
    final candidate = _selectedAsset;
    if (candidate == null || _activating) return false;
    final previous = _activeAsset;
    _activating = true;
    notifyListeners();
    try {
      await store.stage(candidate);
      await store.commit(candidate.id);
      _activeAsset = candidate;
      _validationMessage = null;
      return true;
    } on Object {
      await store.rollbackTo(previous?.id);
      _activeAsset = previous;
      _validationMessage = 'Activation failed; the prior theme was restored.';
      return false;
    } finally {
      _activating = false;
      notifyListeners();
    }
  }

  String? _validate(ThemeAssetCandidate candidate) {
    if (candidate.id.trim().isEmpty || candidate.localPath.trim().isEmpty) {
      return 'A local theme asset is required.';
    }
    final uri = Uri.tryParse(candidate.localPath);
    if (uri == null || uri.hasScheme) {
      return 'Theme assets must remain local unless sync is explicitly enabled.';
    }
    if (candidate.kind == ThemeAssetKind.image) {
      if (!_imageMimeTypes.contains(candidate.mimeType)) {
        return 'Only JPEG, PNG, and WebP images are supported.';
      }
      return null;
    }
    if (candidate.mimeType != 'video/mp4') {
      return 'Only muted MP4 video themes are supported.';
    }
    final duration = candidate.duration;
    if (duration == null || duration <= Duration.zero) {
      return 'A verified video duration is required.';
    }
    if (duration > maximumVideoDuration) {
      return 'Video themes must be 30 seconds or shorter.';
    }
    if (candidate.posterPath?.trim().isEmpty ?? true) {
      return 'A poster frame is required for reduced motion.';
    }
    return null;
  }
}
