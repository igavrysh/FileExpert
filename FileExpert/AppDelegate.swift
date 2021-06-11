//
//  AppDelegate.swift
//  FileExpert
//
//  Created by new on 5/26/21.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //GIDSignIn.sharedInstance()?.clientID = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"

        //var configureError: NSError?
        //GGLContext.sharedInstance()?.configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = "421258405956-caqbdhke8c2j7msom2eb9ddh7foln9o4.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.scopes.append(kGTLRAuthScopeSheetsSpreadsheets)
        GIDSignIn.sharedInstance()?.scopes.append(kGTLRAuthScopeSheetsDrive)
        GIDSignIn.sharedInstance()
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

