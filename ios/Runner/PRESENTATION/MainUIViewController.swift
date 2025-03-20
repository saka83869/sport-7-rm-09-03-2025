//
//  MainUIViewController.swift
//  Runner
//
//  Created by DEV APP on 20/3/25.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import Combine
import SystemConfiguration

class MainUIViewController: UIViewController {
    
    private var webView: WKWebView!
    private var isIpad = false  // Track device ipad
    private var isDetail = false
    private var isLandscapes = false
    private var currentHost = ""
    private var documentController: UIDocumentInteractionController?
    private let sharedProcessPool = WKProcessPool()
    private var toolbar: UIToolbar!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var reloadButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private var toolbarBottomConstraint: NSLayoutConstraint!
    
    private let appLinks: [String: String] = [
        "fb:": "https://apps.apple.com/us/app/facebook/id284882215",
        "whatsapp:": "https://apps.apple.com/us/app/whatsapp-messenger/id310633997",
        "tiktok:": "https://apps.apple.com/us/app/tiktok/id835599320",
        "tg:": "https://apps.apple.com/us/app/telegram-messenger/id686449807",
        "instagram:": "https://apps.apple.com/us/app/instagram/id389801252",
        "momo:": "https://apps.apple.com/vn/app/momo/id918751511",
    ]
    private let openInSafari = ["https://youtube.com", "https://facebook.com", "https://tiktok.com", "https://telegram.me", "https://t.me"]
    private let fileExtensions = [".apk", ".mobileconfig", ".pdf", ".docx", ".zip", ".exe", ".jpg", ".jpeg", ".png", ".xls", ".xlsx", ".rar"]
    private var useAdjust = false
    var currentLink = ""
    var showBottom = true
    var urlOpenInBrowser: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbarItems()
        addWebviewDetail()
        printLog("viewWillTransition")
        view.backgroundColor = .black
        setUrlWebview()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        printLog("viewWillTransition")
        coordinator.animate(alongsideTransition: { _ in
        }, completion: { _ in
            self.executeWithCatch({
                let isPortrait = UIDevice.current.orientation.isPortrait
                self.handleRotation()
                if isPortrait {
                    if self.showBottom {
                        self.showToolbar()
                    }
                } else {
                    if !self.isIpad {
                        printLog("orientationDidChange isLandscape !isIpad")
                        self.hideToolbar()
                    }
                }
            }, key: "viewWillTransition")
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        printLog("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        printLog("viewDidDisappear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        printLog("viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        printLog("viewWillDisappear")
    }
    
    private func handleRotation() {
        if UIDevice.current.orientation.isLandscape {
            printLog("Landscape")
            isLandscapes = true
        } else if UIDevice.current.orientation.isPortrait {
            printLog("Portrait")
            isLandscapes = false
        }
    }
    
    private func setupToolbarItems() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        toolbar.isHidden = true
        view.addSubview(toolbar)
        
        let toolbarHeightConstraint = toolbar.heightAnchor.constraint(equalToConstant: 55)
        
        NSLayoutConstraint.activate([
            toolbarBottomConstraint,
            toolbarHeightConstraint,
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let backImage = resizeImage(named: "goleft", width: 40, height: 40)?.withRenderingMode(.alwaysOriginal)
        let forwardImage = resizeImage(named: "goright", width: 40, height: 40)?.withRenderingMode(.alwaysOriginal)
        let reloadImage = resizeImage(named: "refresh", width: 40, height: 40)?.withRenderingMode(.alwaysOriginal)
        let stopImage = resizeImage(named: "home", width:40, height: 40)?.withRenderingMode(.alwaysOriginal)
        
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(image: forwardImage, style: .plain, target: self, action: #selector(goForward))
        reloadButton = UIBarButtonItem(image: reloadImage, style: .plain, target: self, action: #selector(reload))
        stopButton = UIBarButtonItem(image: stopImage, style: .plain, target: self, action: #selector(home))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.barTintColor = .black
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            isIpad = true
            toolbar.items = [flexibleSpace,flexibleSpace, stopButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, flexibleSpace]
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            toolbar.items = [flexibleSpace, stopButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace]
        }
    }
    
    private func hideToolbar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            printLog("hideToolbar : 01")
            self.toolbarBottomConstraint.constant = self.toolbar.frame.height
        }
    }
    
    private func showToolbar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            printLog("showToolbar : 01")
            self.toolbarBottomConstraint.constant = 0
        }
    }
    
    @objc func goBack() {
        printLog("goBack")
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @objc func goForward() {
        printLog("goForward")
        if self.webView.canGoForward {
            self.webView.goBack()
        }
    }
    
    @objc func home() {
        printLog("home")
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            setUrlWebview()
        }
    }
    
    @objc func reload() {
        printLog("reload")
        self.webView.reload()
    }

    
    private func setUrlWebview() {
        if let url = URL(string: currentLink), UIApplication.shared.canOpenURL(url) {
            loadWeb(url: url)
        } else {
            printLog("❌ URL không hợp lệ hoặc không thể mở: \(currentLink)")
        }
    }
    
    private func loadWeb(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 120)
        
        DispatchQueue.main.async {
            self.webView.load(request)
            self.currentLink = url.absoluteString
            self.currentHost = url.host ?? ""
            printLog("Loading with default User-Agent and displaying content.")
        }
        
    }
    
    private func addWebviewDetail() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "blobHandler")
        contentController.add(self, name: "event")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsPictureInPictureMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .all
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.userContentController = contentController
        webConfiguration.processPool = sharedProcessPool
        
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.backgroundColor = .black
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        if showBottom {
            showToolbar()
            toolbar.isHidden = false
        } else {
            hideToolbar()
            toolbar.isHidden = true
        }
    }
}

extension MainUIViewController :  WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        printLog("📱 start webview")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        printLog("📱 end webview")
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        executeWithCatch({
            printLog("createWebViewWith window")
            printLog(navigationAction.request.url?.absoluteString ?? "")
            if navigationAction.targetFrame == nil {
                self.webView.load(navigationAction.request)
            }
            
        }, key: "createWebViewWith") { error in
            printLog("Handling error locally: \(error)")
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        executeWithCatch({
            guard let url = navigationAction.request.url else {
                printLog("Handling url locally: \(navigationAction.request.url?.absoluteString)")
                decisionHandler(.allow)
                return
            }
            let urlString = url.absoluteString
            printLog("Handling url locally: \(urlString)")
            
            self.isDetail = !self.isMobileURL(urlString)
            
            let fileExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp", "ico", "dib", "jfif",
                                  "heic", "heif", "svg", "eps"]
            
            if urlOpenInBrowser.contains(where: { urlString.contains($0) }) {
                openSafariBrowser(url: urlString)
                decisionHandler(.cancel)
                return
            }
            
            for (scheme, appStoreLink) in appLinks {
                if urlString.hasPrefix(scheme) {
                    openAppOrStore(appURL: url, storeURL: appStoreLink)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            if openInSafari.contains(where: { urlString.hasPrefix($0) }) {
                self.openSafariBrowser(url: urlString)
                decisionHandler(.cancel)
                return
            }
            
            if self.fileExtensions.contains(where: { urlString.contains($0) }) {
                openSafariBrowser(url: urlString)
                decisionHandler(.cancel)
                return
            }
            
            if fileExtensions.contains(url.pathExtension.lowercased()) {
                downloadImage(from: url)
                decisionHandler(.cancel) // Cancel the navigation action and handle the download instead
                return
            }
            
            if url.scheme == "kwai" {
                printLog("kwai URL: \(urlString)")
                if let contentURLString = extractQueryString(from: urlString) {
                    let finalURLString = "https://www.kwai.com/?" + contentURLString
                    printLog("Final URL: \(finalURLString)")
                    if let finalURL = URL(string: finalURLString) {
                        openSafariBrowser(url: finalURLString)
                    }
                }
                
                decisionHandler(.cancel)
                return
            }
            
            
            if url.scheme == "itms-services" {
                openSafariBrowser(url: urlString)
                decisionHandler(.cancel)
                return
            }
            if  url.absoluteString.contains("data:image/") {
                saveImg(urlString: url.absoluteString)
                decisionHandler(.cancel)
                return
            }
            
            if urlString.hasPrefix("blob:") {
                printLog("Blob URL detected: \(urlString)")
                
                // Inject JavaScript to extract the blob content
                let jsScript = """
                    var xhr = new XMLHttpRequest();
                    xhr.open('GET', '\(urlString)', true);
                    xhr.responseType = 'blob';
                    xhr.onload = function(e) {
                        var reader = new FileReader();
                        reader.onload = function() {
                            var base64Data = reader.result.split(',')[1];
                            webkit.messageHandlers.blobHandler.postMessage(base64Data);
                        };
                        reader.readAsDataURL(xhr.response);  // Read blob as base64
                    };
                    xhr.send();
                    """
                
                // Execute the JavaScript code in the WebView
                webView.evaluateJavaScript(jsScript) { _, error in
                    if let error = error {
                        printLog("JavaScript execution error: \(error)")
                    }
                }
                
                decisionHandler(.cancel)  // Cancel the navigation
                return
            }
            
            decisionHandler(.allow)
        }, key: "checkMobileVersion") { error in
            decisionHandler(.allow)
            printLog("Handling error locally: \(error)")
        }
    }
    
    func extractQueryString(from urlString: String) -> String? {
        if let questionMarkIndex = urlString.firstIndex(of: "?") {
            let queryString = String(urlString[questionMarkIndex...]).dropFirst()
            return String(queryString)
        }
        return nil
    }
    
    private func isMobileURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        guard let host = url.host else {
            return false
        }
        if host.hasPrefix("m.") || host.contains("mobile") {
            return true
        }
        return false
    }
    
    private func checkLinkAllowNewTab(_ url : URL) -> Bool {
        let urlString = [".js", ".css", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".woff", ".woff2", ".ttf", ".ico", ".bmp", ".json"]
        let urlLink = url.absoluteString
        if urlString.contains(where: { urlLink.contains($0) }) {
            printLog("The URL contains a resource file extension.")
            printLog("LinkAllow default : \(self.currentHost) : true")
            return true
        } else {
            if let host = url.host {
                if host.contains(self.currentHost) || host.contains("m."+self.currentHost) {
                    printLog("LinkAllow + m : \(self.currentHost) : true")
                    return true
                } else {
                    printLog(host)
                    printLog("LinkAllow : \(self.currentHost) : false")
                    return false
                }
            } else {
                printLog("LinkAllow : \(self.currentHost) : true")
                return true
            }
        }
    }
    
    private func openAppOrStore(appURL: URL, storeURL: String) {
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let appStoreURL = URL(string: storeURL) {
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    private func openInSafari(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension MainUIViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        printLog("Will begin previewing document.")
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        printLog("Did end previewing document.")
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        printLog("Will begin sending document to another application.")
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        printLog("Did end sending document to another application.")
    }
    
    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
        printLog("Did dismiss options menu.")
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        printLog("Did dismiss open-in menu.")
    }
    
    // action image webview
    private func downloadImage(from url: URL) {
        executeWithCatch({
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    printLog("Error downloading image: \(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    printLog("No data received")
                    return
                }
                self.saveImage(data: data, fileName: url.lastPathComponent)
            }
            task.resume()
        }, key: "downloadImageurl")
    }
    
    private func saveImage(data: Data, fileName: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            printLog("Image saved to: \(filePath)")
            DispatchQueue.main.async {
                self.openImageFile(fileURL: filePath)
            }
        } catch {
            printLog("Error saving file: \(error.localizedDescription)")
        }
    }
    // action open image
    private func openImageFile(fileURL: URL) {
        documentController = UIDocumentInteractionController(url: fileURL)
        documentController?.delegate = self
        documentController?.presentPreview(animated: true)
    }
    
    private func saveImg(urlString: String) {
        
        var fileExtension = "png"
        
        if urlString.contains("data:image/png") {
            fileExtension = "png"
        } else if urlString.contains("data:image/jpeg") {
            fileExtension = "jpg"
        } else if urlString.contains("data:image/jpg") {
            fileExtension = "jpg"
        } else if urlString.contains("data:image/gif") {
            fileExtension = "gif"
        } else if urlString.contains("data:image/bmp") {
            fileExtension = "bmp"
        } else if urlString.contains("data:image/webp") {
            fileExtension = "webp"
        }
        
        let randomFileName = UUID().uuidString
        let fileName = "\(randomFileName).\(fileExtension)"
        
        guard let base64Data = urlString.components(separatedBy: ",").last,
              let imageData = Data(base64Encoded: base64Data),
              let image = UIImage(data: imageData) else {
            printLog("Error decoding Base64 string")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // Get the file path to save the image
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            // Write the image data to the file
            try imageData.write(to: filePath)
            printLog("Image saved to: \(filePath)")
            DispatchQueue.main.async {
                self.openImageFile(fileURL: filePath)
            }
        } catch {
            printLog("Error saving file: \(error.localizedDescription)")
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            printLog("Error saving image: \(error.localizedDescription)")
        } else {
            printLog("Image saved to gallery!")
        }
    }  // end action image webview
}

extension MainUIViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        printLog("ProxyWkWebviewViewController: \(message.name)")
        if message.name == "blobHandler", let base64Data = message.body as? String {
            executeWithCatch({
                saveImage(base64Data: base64Data)
            }, key: "saveImageblobHandler")
        }
        
        if message.name == "event", let messageBody = message.body as? String {
            if !self.useAdjust {
                return
            }
            let components = messageBody.split(separator: "+")
            if components.count == 2 {
                let eventName = String(components[0])
                let eventValue = String(components[1])
                handleEvent(eventName: eventName, eventValue: eventValue)
            }
        }
        
    }
    
    func handleEvent(eventName: String, eventValue: String) {
        printLog("📱Event Name: \(eventName), Event Value: \(eventValue)")
    }
    
    // Function to convert base64 data and save the image
    func saveImage(base64Data: String) {
        guard let imageData = Data(base64Encoded: base64Data) else {
            printLog("Error decoding base64 data")
            return
        }
        if let image = UIImage(data: imageData) {
            saveToDocuments(image: image)
        }
    }
    
    func saveToDocuments(image: UIImage) {
        if let data = image.pngData() {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let randomFileName = UUID().uuidString
            let fileExtension = "png"
            let fileName = "\(randomFileName).\(fileExtension)"
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL)
                printLog("Image saved to: \(fileURL)")
                DispatchQueue.main.async {
                    self.openImageFile(fileURL: fileURL)
                }
            } catch {
                printLog("Error saving image: \(error)")
            }
        }
    }
}

extension MainUIViewController: SFSafariViewControllerDelegate {
    
    public func openSafari(url: URLRequest) {
        executeWithCatch({
            DispatchQueue.global(qos: .background).async { [weak self] in
                do {
                    guard let url = url.url else {
                        throw NSError(domain: "InvalidURL", code: 1001, userInfo: [NSLocalizedDescriptionKey: "The provided URLRequest does not contain a valid URL."])
                    }
                    
                    DispatchQueue.main.async {
                        let safariViewController = SFSafariViewController(url: url)
                        safariViewController.delegate = self
                        self?.present(safariViewController, animated: true, completion: {
                            if self?.webView?.canGoBack == true {
                                self?.webView.goBack()
                            }
                        })
                    }
                } catch {
                    DispatchQueue.main.async {
                        // Handle the error, e.g., log or show an alert
                        printLog("Error opening Safari: \(error.localizedDescription)")
                    }
                }
            }
        }, key: "openSafariviewui")
    }
    
    public func openSafariBrowser(url: String) {
        guard let validURL = URL(string: url) else {
            printLog("The provided URL is invalid.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if UIApplication.shared.canOpenURL(validURL) {
                UIApplication.shared.open(validURL, options: [:], completionHandler: { success in
                    printLog(success ? "Successfully opened the URL." : "Failed to open the URL.")
                })
            } else {
                printLog("URL cannot be opened.")
            }
        }
    }
    
    public func openSafari(url: String) {
        executeWithCatch({
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let validURL = URL(string: url) else {
                    DispatchQueue.main.async {
                        printLog("The provided URL is invalid.")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    let safariViewController = SFSafariViewController(url: validURL)
                    safariViewController.delegate = self
                    self?.present(safariViewController, animated: true, completion: nil)
                }
            }
            
        }, key: "openSafariviewui")
    }
}

extension MainUIViewController {
    // action show popup
    private func showActionButtonBottom(completionSuccess :@escaping (_ result : Bool) -> ()) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Thông báo", message: "Bạn chắc chắn muốn thoát khỏi tác vụ hiện tại?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Xác nhận", style: UIAlertAction.Style.default, handler: { action in
                completionSuccess(true)
            }))
            alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.cancel, handler:{ action in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAction(title: String, body: String, completionSuccess :@escaping (_ result : Bool) -> ()) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Xác nhận", style: UIAlertAction.Style.default, handler: { action in
                completionSuccess(true)
            }))
            alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.cancel, handler:{ action in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showMessage(title: String, body: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Thử lại", style: UIAlertAction.Style.default, handler: { action in
                
            }))
            alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.cancel, handler:{ action in}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func resizeImage(named name: String, width: CGFloat, height: CGFloat) -> UIImage? {
        if let image = UIImage(named: name) {
            let newSize = CGSize(width: width, height: height)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            return renderer.image { (context) in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        return nil
    }

}
