//
//  MKMessage.swift
//  Messanger
//
//  Created by Metin Atalay on 22.01.2022.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject,MessageType {
  
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType {return mkSender}
    var senderInitials: String
    
   var photoItem: PhotoMessage?
   var videoItem : VideoMessage?
   var locationItem : LocationItem?
   var audioItem: AudioItem?
    
    var status:String
    var readDate:Date
    
    
    init(message: LocalMessage) {
        
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch  message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        case kVIDEO:
            let videoItem = VideoMessage(url:nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            

        default:
            print("error in message ")
        }
        
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
    }
    
    
}
