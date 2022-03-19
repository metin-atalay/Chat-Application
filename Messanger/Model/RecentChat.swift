//
//  RecentChat.swift
//  Messanger
//
//  Created by Metin Atalay on 9.01.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    
    var id = ""
    var chatRoomId =  ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds: [String] = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
}
