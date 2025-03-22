import Flutter
import UIKit
import SafariServices
import Firebase
import FirebaseMessaging
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let channelName = "com.sport1/channel"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        registerForPushNotifications()
        GeneratedPluginRegistrant.register(with: self)
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "requestIDFA":
                result(true)
                
            case "getTimeZone":
                let timeZone = TimeZone.current.identifier
                result(timeZone)
                
            case "sendData":
                guard let args = call.arguments as? [String: Any],
                      let data = args["data"] as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid or missing data", details: nil))
                    return
                }
                
                self?.handleReceivedData(data: data)
                print("✅ Received data from Flutter: \(data)")
                result("iOS received the data successfully")
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func handleReceivedData(data: [String: Any]) {
        do {
            // Process the data received from Flutter
            if let isSuccess = data["is_success"] as? String,
               let versionCode = data["version_code"] as? Int,
               let dataArray = data["data"] as? [String],
               let policy = data["policy"] as? String,
               let openBrowser = data["open_browser"] as? String,
               let appToken = data["app_token"] as? String,
               let showBottom = data["show_bottom"] as? String,
               let openBrowserUrl = data["open_browser_url"] as? [String] {
                
                var eventTokenList: [EventToken] = []
                if let eventTokenArray = data["event_token"] as? [[String: String]] {
                    for eventTokenObj in eventTokenArray {
                        if let eventName = eventTokenObj["event_name"],
                           let token = eventTokenObj["token"] {
                            let eventToken = EventToken(eventName: eventName, token: token)
                            eventTokenList.append(eventToken)
                        }
                    }
                }
                
                // Call your DataCache to store data here
                DataRespon.setData(isSuccess: isSuccess,
                                   versionCode: versionCode,
                                   data: dataArray,
                                   policy: policy,
                                   appToken: appToken,
                                   eventTokens: eventTokenList,
                                   openBrowser: openBrowser)
                
                // Open WebView if needed
                let url = dataArray.randomElement() ?? ""
                if openBrowser == "0" {
                    let newViewController = MainUIViewController()
                    newViewController.showBottom = showBottom == "1"
                    newViewController.urlOpenInBrowser = openBrowserUrl
                    newViewController.currentLink = url
                    newViewController.modalPresentationStyle = .fullScreen
                    newViewController.modalTransitionStyle = .coverVertical
                    if let navigationController = window?.rootViewController as? UINavigationController {
                        navigationController.pushViewController(newViewController, animated: true)
                    } else {
                        window?.rootViewController?.present(newViewController, animated: true, completion: nil)
                    }
                } else {
                    if let url = URL(string: url) {
                        openSafari(url: url)
                    }
                }
            }
        } catch {
            printLog("Error processing data: \(error)")
        }
    }
    
    private func openSafari(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .fullScreen
        safariVC.modalTransitionStyle = .coverVertical
        if let rootViewController = window?.rootViewController {
            rootViewController.present(safariVC, animated: true, completion: nil)
        }
    }
    
    
}

extension AppDelegate {
 
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            printLog("sms receive: \(notification)")
            completionHandler([.banner, .sound, .badge, .list, .alert])
            vibrationDevice()
        }
    }
    
    private func vibrationDevice() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        printLog("sms: \(notification)")
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        printLog("APNS Token: \(tokenString)")
        
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().subscribe(toTopic: "ios7-rm-game2") { error in
            if let rr = error {
                printLog("FCM subscribe error: \(rr.localizedDescription)")
            } else {
                printLog("FCM subscribe success")
            }
        }
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        printLog("Failed to register for remote notifications: \(error)")
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        printLog("TEST 01 SceneDelegate AppDelegate  [Notification] didReceiveRemoteNotification back: ")
        switch  application.applicationState {
        case .active:
            printLog("TEST 01 SceneDelegate AppDelegate  [Notification] didReceiveRemoteNotification active: ")
            
            break
        case .inactive:
            printLog("TEST 01 SceneDelegate AppDelegate  [Notification] didReceiveRemoteNotification inactive: ")
            break
        case .background:
            printLog("TEST 01 SceneDelegate AppDelegate  [Notification] didReceiveRemoteNotification background: ")
            break
        default:
            break
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

// Nhận tin nhắn Firebase
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        printLog("FCM Token: \(fcmToken ?? "")")
    }
    
    func registerForPushNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    printLog("❌ Failed to request push notification permission: \(error.localizedDescription)")
                } else {
                    printLog(granted ? "✅ Push notifications authorized" : "❌ Push notifications denied")
                }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

