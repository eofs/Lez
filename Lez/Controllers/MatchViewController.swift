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
import PromiseKit
import SnapKit

class MatchViewController: UIViewController, FUIAuthDelegate {
    
    var name = String()
    var email = String()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLoginStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func checkLoginStatus() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                guard let location = Defaults.sharedInstance.defaults.string(forKey: "location") else { return }
                FirestoreManager.sharedInstance.fetchPotentialMatches(location: location).then { lesbians -> Void in
                    // Pokaži lezbojke
                    print(lesbians)
                }
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
        guard let user = user else { return }
        guard let unwrappedName = user.displayName else { return }
        guard let unwrappedEmail = user.email else { return }
        
        name = unwrappedName
        email = unwrappedEmail
        
        print("Before checkIfExist")
        
        FirestoreManager.sharedInstance.checkIfExist(property: "email", isEqualTo: email).then { userExists -> Void in
            if userExists {
                print("User exists, going to MatchViewController.")
                self.dismiss(animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
            } else {
                print("No user, going to ProfileSetupViewController.")
                self.performSegue(withIdentifier: profileSetupSegue, sender: nil)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSetupSegue {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! ProfileSetupViewController
            targetController.email = email
            targetController.name = name
        }
    }
}

