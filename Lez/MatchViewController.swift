//
//  ViewController.swift
//  Lez
//
//  Created by Antonija on 09/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI

class MatchViewController: UIViewController, FUIAuthDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
            } else {
                // No user is signed in.
                self.presentLogin()
            }
        }
    }
    
    func presentLogin() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIFacebookAuth()]
        authUI?.providers = providers
        let authViewController = authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let user = user else {
            return
        }
        
        print("Logged in as \(user.displayName!), \(user.email!)")
        self.performSegue(withIdentifier: "LoggedIn", sender: nil)
    }

}

