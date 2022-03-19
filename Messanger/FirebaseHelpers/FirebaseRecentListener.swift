//
//  FirebaseRecentListener.swift
//  Messanger
//
//  Created by Metin Atalay on 9.01.2022.
//

import Foundation


class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init(){}
    
    func dowlandRecentChatsFromFireStore(completion: @escaping(_ allRecent: [RecentChat]) -> Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (snapshot, error) in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = snapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecent = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecent {
               // if recent.lastMessage != "" {
                    recentChats.append(recent)
                //}
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            
            completion(recentChats)
            
        }
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        } catch  {
            print("save recent ex", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
   
    
  
    
}
