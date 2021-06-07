//
//  ViewController.swift
//  FileExpert
//
//  Created by new on 5/26/21.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseFirestoreSwift

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
    
    func configureFilestore() {
        FirebaseApp.configure()
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
        
        DispatchQueue.global(qos: .background).async {
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = Date(timeIntervalSinceNow: 0)            
            ref = db.collection("users").addDocument(data: [
                "fullName": user.profile.name,
                "givenName": user.profile.givenName,
                "familyName": user.profile.familyName,
                "email": user.profile.email,
                "ts": "\(date)"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
        
        let fvc = MainViewController()
        fvc.navigationItem.title = "HOHO"
        fvc.modalPresentationStyle = .fullScreen
        self.present(fvc, animated: true, completion: nil)
    }
}

