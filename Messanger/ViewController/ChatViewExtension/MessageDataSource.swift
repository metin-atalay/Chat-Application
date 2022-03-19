//
//  MessageDataSource.swift
//  Messanger
//
//  Created by Metin Atalay on 18.01.2022.
//

import Foundation
import MessageKit

extension ChatViewController : MessagesDataSource{
    func currentSender() -> SenderType {
       return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let showLoadMore = indexPath.section == 0 && allLocalMessage.count > displayingMessageCount
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            
            let color  = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
            
        }
        
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section != mkMessages.count - 1 {
            
            return NSAttributedString(string: message.sentDate.time(), attributes:
                                        [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
    
    
    
}


extension ChannelChatViewController : MessagesDataSource{
    func currentSender() -> SenderType {
       return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let showLoadMore = indexPath.section == 0 
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            
            let color  = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
            
        }
        
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section != mkMessages.count - 1 {
            
            return NSAttributedString(string: message.sentDate.time(), attributes:
                                        [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
    
    
    
}
