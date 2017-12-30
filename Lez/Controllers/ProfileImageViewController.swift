//
//  ProfileImageViewController.swift
//  Lez
//
//  Created by Antonija on 29/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit
import Firebase


class ProfileImageViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }
    
    @IBAction func profileImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        if profileImage.image == nil {
            print("No image")
        } else {
            // Start app
            guard let image = profileImage.image else { return }
            FirestoreManager.sharedInstance.uploadImage(image: image).then { isUploaded -> Void in
                // Segue to MatchViewController
            }
            print("Shit is on!!!")
        }
    }
}

extension ProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.contentMode = .scaleToFill
            profileImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
