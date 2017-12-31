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
import Koloda
import Alamofire
import AlamofireImage

class MatchViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var cardView: KolodaView!
    
    var name = String()
    var email = String()
    var activityIndicator = UIActivityIndicatorView()
    var lesbians = [Lesbian]()
    var images = [UIImage]()
    
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
        
        cardView.dataSource = self
        cardView.delegate = self
    }
    
    func checkLoginStatus() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                guard let email = Auth.auth().currentUser?.email else { return }
                FirestoreManager.sharedInstance.fetchUsersLocation(email: email).then { location -> Void in
                    FirestoreManager.sharedInstance.fetchPotentialMatches(location: location).then { lesbians -> Void in
                        // Download images
                        for lesbian in lesbians {
                            self.fetchImage(url: lesbian.profileImageURL!).then { image -> Void in
                                self.images.append(image)
                                self.cardView.reloadData()
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            } else {
                // No user is signed in.
                self.presentLogin()
            }
        }
    }
    
    func fetchImage(url: String) -> Promise<UIImage> {
        return Promise { (fulfill, reject) in
            let imageRef = FirestoreManager.sharedInstance.storageRef.child(url)
            imageRef.downloadURL { url, error in
                if let error = error {
                    reject(error)
                } else {
                    Alamofire.request(url!).responseImage { response in
                        if let image = response.result.value {
                            fulfill(image)
                        }
                    }
                }
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

extension MatchViewController: KolodaViewDelegate, KolodaViewDataSource {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print(index)
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return images.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: images[index].af_imageAspectScaled(toFill: CGSize(width: self.view.bounds.width, height: 530)))
    }

}

