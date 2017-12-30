//
//  FirestoreManager.swift
//  Lez
//
//  Created by Antonija on 29/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import Foundation
import Firebase
import PromiseKit

class FirestoreManager {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    static let sharedInstance = FirestoreManager()

    private init() { }
    
    func checkIfExist(property: String, isEqualTo: Any) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let query = db.collection("users").whereField(property, isEqualTo: isEqualTo)
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot?.documents else { print(error!); return }
                print("There is \(snapshot.count) items.")
                if snapshot.count == 1 {
                    fulfill(true)
                } else {
                    fulfill(false)
                }
            }
        }
    }
    
    func createUser(email: String, user: Lesbian) {
        FirestoreManager.sharedInstance.checkIfExist(property: email, isEqualTo: user.email).then { userExists -> Void in
            if userExists {
                print("User exists, going to MatchViewController.")
            } else {
                self.db.collection("users").document(user.email).setData([
                    "name": user.name,
                    "email": user.email,
                    "age": user.age,
                    "location": user.location
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
    }
    
    func uploadImage(image: UIImage) -> Promise<Bool> {
        return Promise { fulfull, reject in
            
            guard let currentUser = Auth.auth().currentUser?.email else { return }
            guard let image = image.resizeWithWidth(width: 500) else { return }
            
            // Data in memory
            guard let data = UIImagePNGRepresentation(image) else { return }
            
            // Create a reference to the file you want to upload
            let profileImage = storageRef.child("images/\(currentUser)/profileImage.jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            profileImage.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                guard let downloadURL = metadata.path else { return }
                
                self.db.collection("users").document(currentUser).setData([ "profileImageURL": downloadURL ], options: SetOptions.merge())
            }
            
        }
    }
    
    func signOut() {
        try! Auth.auth().signOut()
    }
    
}
