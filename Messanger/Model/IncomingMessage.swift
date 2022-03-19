//
//  IncomingMessage.swift
//  Messanger
//
//  Created by Metin Atalay on 23.01.2022.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView : MessagesViewController
    
    init(_collectionView: MessagesViewController){
        messageCollectionView = _collectionView
    }
    
    func createMessage(localMessage: LocalMessage) -> MKMessage?{
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.dowlandImage(imageUrl: localMessage.pictureUrl) { Image in
                mkMessage.photoItem?.image = Image
                self.messageCollectionView.messagesCollectionView.reloadData()
                
            }
            
        }
        
        if localMessage.type == kVIDEO {
            
            FileStorage.dowlandImage(imageUrl: localMessage.pictureUrl) { (thumbNail) in
                
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                    
                    let videoItem = VideoMessage(url: videoURL)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbNail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kLOCATION {
            
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.type == kAUDIO {
            
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            
            FileStorage.downloadAudio(audioLink: localMessage.audioUrl) { (fileName) in
                
                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                
                //mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
      
        
        
        //multimedia message
        
        return mkMessage
    }
    
}
