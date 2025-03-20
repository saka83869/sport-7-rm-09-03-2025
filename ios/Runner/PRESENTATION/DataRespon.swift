
import Foundation

class DataRespon {
    // Variables to store the data sent from Flutter
    static var isSuccess: String?
    static var versionCode: Int?
    static var data: [String] = []
    static var policy: String?
    static var appToken: String?
    static var eventTokens: [EventToken] = []
    static var openBrowser: String?
    static var externalDeviceId: String?

    // Method to set the data
    static func setData(
        isSuccess: String?,
        versionCode: Int?,
        data: [String] = [],
        policy: String?,
        appToken: String?,
        eventTokens: [EventToken] = [],
        openBrowser: String?
    ) {
        self.isSuccess = isSuccess
        self.versionCode = versionCode
        self.data = data
        self.policy = policy
        self.appToken = appToken
        self.eventTokens = eventTokens
        self.openBrowser = openBrowser
    }

    // Method to get the data as a dictionary (if needed)
    static func getData() -> [String: Any?] {
        return [
            "is_success": isSuccess,
            "version_code": versionCode,
            "data": data,
            "policy": policy,
            "app_token": appToken,
            "event_token": eventTokens,
            "open_browser": openBrowser
        ]
    }
}

// EventToken data structure
struct EventToken {
    var eventName: String?
    var token: String?
}
