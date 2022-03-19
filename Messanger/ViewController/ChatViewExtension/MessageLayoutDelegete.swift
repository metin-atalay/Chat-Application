//
//  MessageLayoutDelegete.swift
//  Messanger
//
//  Created by Metin Atalay on 18.01.2022.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 3 == 0 {
            
            // TODO : set diffrendt
            
            if  indexPath.section == 0 && allLocalMessage.count > displayingMessageCount {
                return 40
            }
            return 18
        }
        
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.set(avatar: Avatar( initials: mkMessages[indexPath.section].senderInitials))
        
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if  isFromCurrentSender(message: message) {
            
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " +
            message.readDate.time() : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray] )
        }
        
        return nil
    }
    
}

extension ChannelChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 3 == 0 {
            
            // TODO : set diffrendt
            
            if  indexPath.section == 0  {
                return 40
            }
            return 18
        }
        
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.set(avatar: Avatar( initials: mkMessages[indexPath.section].senderInitials))
        
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if  isFromCurrentSender(message: message) {
            
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " +
            message.readDate.time() : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray] )
        }
        
        return nil
    }
    
}

