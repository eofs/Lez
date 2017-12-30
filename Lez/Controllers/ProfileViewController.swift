//
//  ProfileViewController.swift
//  Lez
//
//  Created by Antonija on 29/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signOutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
    }
    
}
