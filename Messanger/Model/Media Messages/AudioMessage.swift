//
//  AudioMessage.swift
//  Messager
//
//  Created by David Kababyan on 14/09/2020.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {
    
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(duration: Float) {
        
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
    
    
}
