//
//  FirebaseTypingListener.swift
//  Messanger
//
//  Created by Metin Atalay on 29.01.2022.
//

import Foundation
import Firebase

class FirebaseTypingListener {
    
    static let shared = FirebaseTypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])

    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
}
