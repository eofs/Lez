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
    
    // TODO: Put spinner, disable UI
    @IBAction func finishButtonTapped(_ sender: Any) {
        if profileImage.image == nil {
            print("No image")
        } else {
            // Start app
            guard let image = profileImage.image else { return }
            FirestoreManager.sharedInstance.uploadImage(image: image).then { isUploaded -> Void in
                print(isUploaded)
                if isUploaded {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "InitialController") 
                    self.present(viewController, animated: true)
                } else {
                     let dialogMessage = UIAlertController(title: "Oh-uh", message: "Image couldn't be uploaded, please try again.", preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        print("Ok button tapped")
                    })
                    
                    // Create Cancel button with action handlder
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                        print("Cancel button tapped")
                    }
                    
                    //Add OK and Cancel button to dialog message
                    dialogMessage.addAction(ok)
                    dialogMessage.addAction(cancel)
                    
                    // Present dialog message to user
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.contentMode = .scaleAspectFill
            profileImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
