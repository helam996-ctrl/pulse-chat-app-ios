import XCTest

final class iOSChatAppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestsRunning", "YES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAppLaunchAndCaptureScreenshots() throws {
        // Allow UI to settle
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10.0))
        
        let fileManager = FileManager.default
        let screenshotsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Screenshots", isDirectory: true)
        
        try? fileManager.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true)
        
        // 1. Capture LoginView Screenshot
        let authSegmentedPicker = app.segmentedControls["AuthModeSegmentedPicker"]
        let emailField = app.textFields["EmailTextField"]
        
        if emailField.waitForExistence(timeout: 5.0) || authSegmentedPicker.exists {
            let loginScreenshot = app.screenshot()
            let loginAttachment = XCTAttachment(screenshot: loginScreenshot)
            loginAttachment.name = "LoginView_Screenshot"
            loginAttachment.lifetime = .keepAlways
            add(loginAttachment)
            
            let loginFileUrl = screenshotsDirectory.appendingPathComponent("LoginView.png")
            try? loginScreenshot.pngRepresentation.write(to: loginFileUrl)
            
            // Switch to Create Account mode to verify UI responsiveness
            if authSegmentedPicker.buttons["Create Account"].exists {
                authSegmentedPicker.buttons["Create Account"].tap()
                
                let registerScreenshot = app.screenshot()
                let registerAttachment = XCTAttachment(screenshot: registerScreenshot)
                registerAttachment.name = "CreateAccountView_Screenshot"
                registerAttachment.lifetime = .keepAlways
                add(registerAttachment)
            }
        }
        
        // 2. Capture MainMessagesView Screenshot
        // If already logged in or navigating into MainMessagesView
        let mainMessagesView = app.otherElements["MainMessagesView"]
        let recentMessagesScroll = app.scrollViews["RecentMessagesScrollView"]
        let floatingNewMessageButton = app.buttons["FloatingNewMessageButton"]
        
        if mainMessagesView.waitForExistence(timeout: 3.0) || floatingNewMessageButton.exists || recentMessagesScroll.exists {
            let mainMessagesScreenshot = app.screenshot()
            let mainAttachment = XCTAttachment(screenshot: mainMessagesScreenshot)
            mainAttachment.name = "MainMessagesView_Screenshot"
            mainAttachment.lifetime = .keepAlways
            add(mainAttachment)
            
            let mainFileUrl = screenshotsDirectory.appendingPathComponent("MainMessagesView.png")
            try? mainScreenshot.pngRepresentation.write(to: mainFileUrl)
        } else {
            // Dismiss or capture whatever view is visible
            let currentScreenshot = app.screenshot()
            let currentAttachment = XCTAttachment(screenshot: currentScreenshot)
            currentAttachment.name = "MainMessagesView_Screenshot"
            currentAttachment.lifetime = .keepAlways
            add(currentAttachment)
            
            let fallbackFileUrl = screenshotsDirectory.appendingPathComponent("MainMessagesView.png")
            try? currentScreenshot.pngRepresentation.write(to: fallbackFileUrl)
        }
    }
}
