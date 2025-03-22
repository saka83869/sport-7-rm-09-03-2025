class DataResponse {
  static final DataResponse _instance = DataResponse._internal();

  factory DataResponse() {
    return _instance;
  }

  DataResponse._internal({
    this.isSuccess,
    this.versionCode,
    this.data = const [],
    this.policy,
    this.appToken,
    this.eventTokens,
    this.openBrowser,
    this.showBottom = "0",
    this.openBrowserUrl = const [],
  });

  String? isSuccess;
  int? versionCode;
  List<String> data;
  String? policy;
  String? appToken;
  List<EventToken>? eventTokens;
  String? openBrowser;
  String showBottom;
  List<String> openBrowserUrl;

  void updateFrom(DataResponse other) {
    isSuccess = other.isSuccess;
    versionCode = other.versionCode;
    data = List.from(other.data);
    policy = other.policy;
    appToken = other.appToken;
    eventTokens = other.eventTokens != null
        ? List.from(other.eventTokens!)
        : null;
    openBrowser = other.openBrowser;
    showBottom = other.showBottom;
    openBrowserUrl = other.openBrowserUrl;
  }

  static DataResponse fromJson(Map<String, dynamic> json) {
    final instance = DataResponse._internal(
      isSuccess: json['is_success'] as String?,
      versionCode: json['version_code'] as int?,
      data: List<String>.from(json['data'] ?? []),
      policy: json['policy'] as String?,
      appToken: json['app_token'] as String?,
      eventTokens: json['event_token'] != null
          ? List<EventToken>.from(json['event_token']
          .map((item) => EventToken.fromJson(item)))
          : null,
      openBrowser: json['open_browser'] as String?,
      showBottom: json['show_bottom'] as String? ?? "0",
      openBrowserUrl: List<String>.from(json['open_browser_url'] ?? []),
    );
    return instance;
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'version_code': versionCode,
      'data': data,
      'policy': policy,
      'app_token': appToken,
      'event_token': eventTokens != null
          ? eventTokens!.map((x) => x.toJson()).toList()
          : null,
      'open_browser': openBrowser,
      'show_bottom': showBottom,
      'open_browser_url': openBrowserUrl,
    };
  }

  void clear() {
    isSuccess = null;
    versionCode = null;
    data = [];
    policy = null;
    appToken = null;
    eventTokens = null;
    openBrowser = null;
    showBottom = "0";
    openBrowserUrl = [];
  }
}

class EventToken {
  String? eventName;
  String? token;

  EventToken({
    this.eventName,
    this.token,
  });

  factory EventToken.fromJson(Map<String, dynamic> json) {
    return EventToken(
      eventName: json['event_name'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'token': token,
    };
  }
}
