//
//  FirebaseMessageListener.swift
//  Messanger
//
//  Created by Metin Atalay on 22.01.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListner {
    
    static let shared = FirebaseMessageListner()
    var newChatListener: ListenerRegistration!
    var updateChatListner: ListenerRegistration!
    
    private init() {}
    
    func listenForNewChats(_ documentId: String, collenctionId : String, lastMessageDate : Date){
        
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collenctionId).whereField("date", isGreaterThan: lastMessageDate).addSnapshotListener({ (quertSnapshot, error) in
            
            guard let snapshot = quertSnapshot else { return}
            
            for change in snapshot.documentChanges {
                
                if change.type == .added {
                    
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let messge = messageObject {
                            RealmManager.shared.saveToRealm(messge)
                        }else {
                            print("Document doesnt exists")
                        }
                    case .failure(let error):
                        print("Error decoding local message: \(error.localizedDescription)")
                    }
                    
                }
                
            }
            
            
        })
        
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String){
        
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (quertDocumentsSnapshot) -> LocalMessage? in
                return try? quertDocumentsSnapshot.data(as:LocalMessage.self)
            }
            oldMessages.sort(by: {$0.date < $1.date})
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
            
            
        }
        
    }
    
    
    func addMessage(_ message: LocalMessage, memberId :String)
    {
        
        do {
            
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId)
                .document(message.id).setData(from: message)
            
            
        } catch {
            
            print("saving message error ", error.localizedDescription)
            
        }
        
      
        
        
    }
    func removeListeners() {
        self.newChatListener.remove()
        
        if self.updateChatListner != nil {
            self.updateChatListner.remove()
        }
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updateChatListner = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("Document does not exist chat")
                        }
                        
                        
                    case .failure(let error):
                        print("Error decoding local message: \(error)")
                    }
                }
            }
        })
    }
    
    //MARK: - Add, Update, Delete
    
   
    
    func addChannelMessage(_ message: LocalMessage, channel: Channel) {
        
        do {
            let _ = try FirebaseReference(.Messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
        }
        catch {
            print("error saving message ", error.localizedDescription)
        }
    }


    //MARK: - UpdateMessageStatus
    func updateMessageInFireStore(_ message: LocalMessage, memberIds: [String]) {

        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]

        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }

}
