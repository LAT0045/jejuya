import 'package:jejuya/app/layers/data/sources/local/ls_key_predefined.dart';
import 'package:jejuya/app/layers/data/sources/local/model/notification/notification.dart';
import 'package:jejuya/app/layers/data/sources/local/model/user/user.dart';
import 'package:jejuya/core/arch/data/network/base_api_service.dart';
import 'package:jejuya/core/reactive/obs_setting.dart';

/// API service for the application.
abstract class AppApiService extends BaseApiService {
  /// Login endpoint.
  Future<User> login();

  /// Notifications endpoint.
  Future<List<Notification>> fetchNotifications({
    String? cursor,
  });

  /// remove Notifications endpoint.
  Future<int> removeNotifications({
    int? id,
  });

  Future<Notification> fetchNotificationDetail(num? notificationId);
}

/// Implementation of the [AppApiService] class.
class AppApiServiceImpl extends AppApiService {
  @override
  // String get baseUrl => '${AppConfig.apiHost}/api/';
  String get baseUrl => 'https://jsonplaceholder.typicode.com/';

  @override
  Map<String, String> get headers {
    final authToken =
        ObsSetting<User?>(key: LSKeyPredefinedExt.user, initValue: null)
            .value
            ?.token;
    final header = <String, String>{};

    if (authToken != null) {
      header['Authorization'] = 'Bearer $authToken';
    }
    return header;
  }

  @override
  Future<User> login() async {
    return performPost(
      'v1/login/',
      {},
      decoder: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<Notification>> fetchNotifications({
    String? cursor,
  }) {
    return performGet(
      'posts',
      query: {if (cursor != null) 'cursor': cursor},
      decoder: (data) => (data as List)
          .map((notification) => Notification.fromJson(
                notification as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  Future<int> removeNotifications({int? id}) {
    return performDelete(
      'posts/$id',
      decoder: (data) => id!,
    );
  }

  Future<Notification> fetchNotificationDetail(num? notificationId) {
    return performGet(
      'posts/$notificationId',
      decoder: (data) => Notification.fromJson(data as Map<String, dynamic>),
    );
  }
}
