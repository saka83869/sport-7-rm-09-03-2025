import Flutter
import UIKit
import SafariServices

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let channelName = "com.sport1/channel"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
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
