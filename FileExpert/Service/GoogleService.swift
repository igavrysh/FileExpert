//
//  GoogleService.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import GoogleSignIn

class GoogleService: NSObject {
    
    static var accessToken: String = ""
    
    func setAccessToken() {
        guard let accessToken = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken else {
            fatalError()
        }
        GoogleService.accessToken = accessToken
    }
    
    func signIn() {
        GIDSignIn.sharedInstance()?.delegate = self
    }
}

extension GoogleService: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("New or signed out user")
            } else {
                print(error.localizedDescription)
            }
        }
        self.setAccessToken()
        
    }
}
