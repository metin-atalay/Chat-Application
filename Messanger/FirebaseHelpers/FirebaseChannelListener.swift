//
//  FirebaseChannelListener.swift
//  Messanger
//
//  Created by Metin Atalay on 5.02.2022.
//

import Foundation
import Firebase

class FirebaseChannelListener {
    
    static let shared = FirebaseChannelListener()
    
    var channelListener: ListenerRegistration!
    
    private init() { }
    
    //MARK: - Fetching
    func downloadUserChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for user channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    
    func downloadSubscribedChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener({ (querySnapshot, error) in
            
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for subscribed channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    func downloadAllChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        
        FirebaseReference(.Channel).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for all channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels = self.removeSubscribedChannels(allChannels)
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
    }
    
    
    
    
    //MARK: - Add Update Delete
    func saveCannel(_ channel: Channel) {
        
        do {
            try         FirebaseReference(.Channel).document(channel.id).setData(from: channel)
            
        } catch {
            print("Error saving channel ", error.localizedDescription)
        }
    }
    
    func deleteChannel(_ channel: Channel) {
        FirebaseReference(.Channel).document(channel.id).delete()
    }
    
    //MARK: - Helpers
    
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
