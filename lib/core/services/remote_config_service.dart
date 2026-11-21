import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../constants/app_constants.dart';

/// Remote Config service for feature flags and dynamic config
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Set defaults
    await _setDefaults();

    // Fetch and activate
    await fetchAndActivate();

    _initialized = true;
  }

  Future<void> _setDefaults() async {
    await _remoteConfig.setDefaults({
      RemoteConfigKeys.chatModel: AppConstants.defaultChatModel,
      RemoteConfigKeys.cheapModel: AppConstants.defaultCheapModel,
      RemoteConfigKeys.enableQuizGeneration: true,
      RemoteConfigKeys.enableFlashcardGeneration: true,
      RemoteConfigKeys.enableStudyPlanner: true,
      RemoteConfigKeys.enableDoubtScanner: true,
      RemoteConfigKeys.dailyAIRequestLimit: AppConstants.dailyAIRequestLimit,
      RemoteConfigKeys.motivationalQuotes: [
        'Every expert was once a beginner.',
        'Small progress is still progress.',
        'Your future self will thank you.',
        'Consistency beats intensity.',
        'Learn something new every day.',
      ],
      RemoteConfigKeys.appMaintenanceMode: false,
      RemoteConfigKeys.maintenanceMessage:
          'App is under maintenance. Please try again later.',
    });
  }

  Future<bool> fetchAndActivate() async {
    try {
      final fetched = await _remoteConfig.fetchAndActivate();
      return fetched;
    } catch (e) {
      // Silently fail - use cached/default values
      return false;
    }
  }

  // Getters for config values
  String get chatModel => _remoteConfig.getString(RemoteConfigKeys.chatModel);
  String get cheapModel => _remoteConfig.getString(RemoteConfigKeys.cheapModel);
  bool get enableQuizGeneration =>
      _remoteConfig.getBool(RemoteConfigKeys.enableQuizGeneration);
  bool get enableFlashcardGeneration =>
      _remoteConfig.getBool(RemoteConfigKeys.enableFlashcardGeneration);
  bool get enableStudyPlanner =>
      _remoteConfig.getBool(RemoteConfigKeys.enableStudyPlanner);
  bool get enableDoubtScanner =>
      _remoteConfig.getBool(RemoteConfigKeys.enableDoubtScanner);
  int get dailyAIRequestLimit =>
      _remoteConfig.getInt(RemoteConfigKeys.dailyAIRequestLimit);
  List<String> get motivationalQuotes => [
        'Every expert was once a beginner.',
        'Small progress is still progress.',
        'Your future self will thank you.',
        'Consistency beats intensity.',
        'Learn something new every day.',
      ];
  bool get isMaintenanceMode =>
      _remoteConfig.getBool(RemoteConfigKeys.appMaintenanceMode);
  String get maintenanceMessage =>
      _remoteConfig.getString(RemoteConfigKeys.maintenanceMessage);

  // Stream for real-time updates (optional)
  Stream<RemoteConfigUpdate> get updates => _remoteConfig.onConfigUpdated;
}
