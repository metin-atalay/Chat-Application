//
//  FirebaseUserListener.swift
//  Messanger
//
//  Created by Metin Atalay on 2.01.2022.
//

import Foundation
import Firebase

class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    
    private init () {}
    
    //Mark: -   Login
    
    func loginUserWithEmail(email : String, password : String, completion: @escaping(_ error: Error?, _ isEmailVerified : Bool)->Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil && authDataResult!.user.isEmailVerified {
                
                FirebaseUserListener.shared.dowlandUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
                
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    
    //Mark: - Register
    
    func registerUserWith(email: String, password : String,completion: @escaping (_ error: Error?)->Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResut, error) in
            completion(error)
            
            if error == nil {
                
                //send verifcation email
                authDataResut?.user.sendEmailVerification(completion: { (error) in
                    print("auth email send with error: ", error?.localizedDescription)
                })
            }
            
            if authDataResut?.user != nil {
                let user = User(id: authDataResut!.user.uid , username: email, email: email, pushId: "", avatarLink: "", status:   "Hey there I'm using Messanger" )
                
                saveUserLocally(user)
                self.saveUserToFirestore(user)
                
            }
        }
    }
    
    //Mark : resesnd email
    
    func resendVerificationEmail(email : String, completion: @escaping (_ error : Error?)->Void){
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (eror) in
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email:String, completion : @escaping(_ error: Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    
    //Mark - Save users
    
    func saveUserToFirestore(_ user: User )  {
        do{
            try FirebaseReference(.User).document(user.id).setData(from: user)
        }catch{
            print("save user when firebase", error.localizedDescription)
        }
    }
    
    
    func dowlandUserFromFirebase(userId : String, email : String? = nil){
        
        FirebaseReference(.User).document(userId).getDocument { [self] (querySnapShot, error) in
            
            guard let document = querySnapShot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                }else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("error decoding user", error)
            }
            
        }
    }
    
    func logOut(completiom: @escaping(_ error:Error?)->Void){
        
        do{
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completiom(nil)
            
        } catch let error as NSError{
            completiom(error)
        }
        
        
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }

    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                
                guard let document = querySnapshot else {
                    print("no document for user")
                    return
                }
                
                let user = try? document.data(as: User.self)

                usersArray.append(user!)
                count += 1
                
                
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
    
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "updating user...")
        }
    }
    
}
