//
//  MessageKitDefaults.swift
//  Messanger
//
//  Created by Metin Atalay on 22.01.2022.
//

import Foundation
import UIKit
import MessageKit

struct  MKSender: SenderType,Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    static let bubbleColorOutgoing  = UIColor(named: "chatOutgoingColor") ??
        UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let bubbleColorIncoming = UIColor(named: "chatIncomingColor") ??
    UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
