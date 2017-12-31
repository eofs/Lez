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
import CodableFirebase

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
                guard let snapshot = snapshot?.documents else {
                    reject(error!)
                    return
                }
                if snapshot.count > 0 {
                    fulfill(true)
                } else {
                    fulfill(false)
                }
            }
        }
    }
    
    /// Create new user or update existing
    ///
    /// - Parameters:
    ///   - email: User's email address
    ///   - user: The user object
    /// - Returns: A promise that resolves a boolean indicating if new user profile was created.
    func createUser(email: String, user: Lesbian) -> Promise<Bool> {
        return Promise { fulfill, reject in
            FirestoreManager.sharedInstance.checkIfExist(property: email, isEqualTo: user.email).then { userExists -> Void in
                if userExists {
                    print("User exists, going to MatchViewController.")
                    fulfill(false)
                } else {
                    Defaults.sharedInstance.saveLocation(location: user.location)
                    self.db.collection("users").document(user.email).setData([
                        "name": user.name,
                        "email": user.email,
                        "age": user.age,
                        "location": user.location
                    ]) { err in
                        guard err == nil else {
                            print("Error writing document:", err!)
                            reject(err!)
                            return
                        }
                        print("Document successfully written!")
                        fulfill(true)
                    }
                }
            }
        }
    }
    
    func fetchUsersLocation(email: String) -> Promise<String> {
        return Promise { fulfill, reject in
            let docRef = db.collection("users").document(email)
            docRef.getDocument { (document, error) in
                guard let document = document else {
                    reject(error!)
                    return
                }
                print(document.data())
                let lesbian = try! FirestoreDecoder().decode(Lesbian.self, from: document.data())
                
                fulfill(lesbian.location)
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
                    reject(error!)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                guard let downloadURL = metadata.path else { return }   
                self.db.collection("users").document(currentUser).setData([ "profileImageURL": downloadURL ], options: SetOptions.merge())
                fulfull(true)
            }
            
        }
    }
    
    func fetchPotentialMatches(location: String) -> Promise<[Lesbian]> {
        return Promise { fulfill, reject in
            let query = db.collection("users").whereField("location", isEqualTo: location)
            var lesbians = [Lesbian]()
            
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot?.documents else {
                    reject(error!)
                    return
                }
                
                for lesbian in snapshot {
                    let newLesbian = try! FirestoreDecoder().decode(Lesbian.self, from: lesbian.data())
                    lesbians.append(newLesbian)
                }
                
                fulfill(lesbians)
            }
        }
    }
    
//    func fetchPotentialMatchesWithAgeRange(location: String, ageStart: Int, ageEnd: Int) {
//        let query = db.collection("users").whereField("location", isEqualTo: location).whereField("age", isGreaterThanOrEqualTo: ageStart).whereField("age", isLessThanOrEqualTo: ageEnd)
//
//        query.getDocuments { (snapshot, error) in
//            if let err = error {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in snapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        }
//    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
