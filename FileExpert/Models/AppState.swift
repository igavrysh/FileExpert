//
//  AppState.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import Foundation

import GoogleSignIn

enum DirectoryViewStyle: String {
    case icons = "icons"
    case list = "list"
}

class AppState : NSObject {
    
    static let changedNotification = Notification.Name("AppStateChanged")

    
    static let shared = AppState(style: .icons)
    
    private var styleInternal: DirectoryViewStyle
    
    var style: DirectoryViewStyle {
        get { return styleInternal }
    }
    
    func toggleNextStyle() {
        self.styleInternal = getNextStyle()
        NotificationCenter.default.post(name: AppState.changedNotification, object: self, userInfo: [AppState.changeReasonKey: AppState.styleChanged, AppState.styleKey: style])
    }
    
    func getNextStyle() -> DirectoryViewStyle {
        switch (style) {
        case DirectoryViewStyle.icons:
            return DirectoryViewStyle.list
        case DirectoryViewStyle.list:
            return  DirectoryViewStyle.icons
        }
    }
    
    init(style: DirectoryViewStyle) {
        self.styleInternal = style
        super.init()
        GIDSignIn.sharedInstance().delegate = self

    }
}

extension AppState: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            return
        }
        if let u = user {
            Foundation.NotificationCenter.default.post(name: AppState.changedNotification, object: self, userInfo: [AppState.changeReasonKey: AppState.userSignedIn, AppState.userKey: u])
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            return
        }
        if let u = user {
            NotificationCenter.default.post(name: AppState.changedNotification, object: self, userInfo: [AppState.changeReasonKey: AppState.userSignedOut, AppState.userKey: u])
        }
    }
}

extension AppState {
    static let styleKey = "style"
    static let changeReasonKey = "reason"
    static let styleChanged = "styleChanged"
    static let userSignedIn = "userSignedIn"
    static let userSignedOut = "userSignedOut"
    static let userKey = "user"
}

