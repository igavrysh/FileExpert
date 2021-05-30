//
//  ViewController.swift
//  FileExpert
//
//  Created by new on 5/26/21.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate {

    let gidButton: GIDSignInButton = {
        let b = GIDSignInButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(gidButton)
        gidButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gidButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(gidButton)
    }
    
    @objc func googleSignInPressed(_ sender: UIButton?) {
        let alert = UIAlertController(title: "hello", message: "Google Sign In", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        let fvc = MainViewController()
        fvc.navigationItem.title = "HOHO"
        fvc.modalPresentationStyle = .fullScreen
        self.present(fvc, animated: true, completion: nil)

        // Perform any operations on signed in user here.
        /*
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
         */
        // ...
    }
}

