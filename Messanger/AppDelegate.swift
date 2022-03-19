//
//  AppDelegate.swift
//  Messanger
//
//  Created by Metin Atalay on 1.01.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstTimeRun = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        LocationManager.shared.startUpdating()
        
        application.registerForRemoteNotifications()
        
        checkFirstTimeRun()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register notifications",error.localizedDescription)
    }
    
    //Mark: - Remote Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    
    private func requesetPushNotificationsPermission() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            
        }
    }
    
    private func updateUserPushId (newPushId : String) {
        
        if var user = User.currentUser {
            user.pushId = newPushId
            saveUserLocally(user)
            FirebaseUserListener.shared.updateUserInFirebase(user)
        }
        
    }
    

    func checkFirstTimeRun() {
        
        firstTimeRun = userDefaults.bool(forKey: kFIRSTRIN)
        
        if !firstTimeRun {
            
            let status = Status.array.map {$0.rawValue}
            
            userDefaults.setValue(status, forKey: kSTATUS)
            
            userDefaults.setValue(true, forKey: kFIRSTRIN)
            
            userDefaults.synchronize()
        }
        
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("*******push token*****",fcmToken)
        updateUserPushId(newPushId: fcmToken)
    }
    
}

