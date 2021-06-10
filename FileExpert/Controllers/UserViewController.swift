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

class UserViewController: UIViewController, GIDSignInDelegate {
    
    let gidButton: GIDSignInButton = {
        let b = GIDSignInButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let logoutButton: UIButton = {
        let b = UIButton()
        b.setTitle("Logout", for: .normal)
        b.backgroundColor = .systemBlue
        b.addTarget(self, action: #selector(logoutPressed(_:)), for: .touchUpInside)
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
        
        var sv = UIStackView(arrangedSubviews: [gidButton, logoutButton])
        sv.axis = .vertical
        view.addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true

    }
    
    @objc func googleSignInPressed(_ sender: UIButton?) {
        let alert = UIAlertController(title: "hello", message: "Google Sign In", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func logoutPressed(_ sender: UIButton?) {
        let url = URL(string: "https://accounts.google.com/Logout")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            var data: [String: String] = [:]
            _ = user.profile.name.map { data["fullName"] = $0 }
            _ = user.profile.givenName.map { data["givenName"] = $0 }
            _ = user.profile.familyName.map { data["familyName"] = $0 }
            _ = user.profile.email.map { data["email"] = $0 }
            data["ts"] = "\(date)"
            ref = db.collection("users").addDocument(data: data) { err in
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

