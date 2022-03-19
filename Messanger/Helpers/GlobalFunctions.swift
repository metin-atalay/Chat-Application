//
//  GlobalFunctions.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import Foundation
import UIKit
import AVFoundation

func fileNameFrom(fileURL : String) -> String {
    let fileName = ((fileURL.components(separatedBy: "_").last!).components(separatedBy: "?").first!).components(separatedBy: ".").first!
    print(fileName)
    return fileName
}

func timeElapsed(_ date: Date) -> String {
    let secound = Date().timeIntervalSince(date)
    
    var elapsed = ""
    
    if secound < 60 {
        elapsed = "Just now"
    } else if secound < 60*60 {
        let minutes = Int(secound/60)
        
        let minText = minutes > 1 ?  "mins" : "min"
        
        elapsed = "\(minutes)\(minText)"
    }else if secound < 24*60*60 {
        let hours = Int(secound / (60*60))
        let hourText =  hours > 1 ?  "hours" : "hour"
        
        elapsed = "\(hours)\(hourText)"
    } else {
        elapsed = date.longDate()
    }
    
    
    return elapsed
    
}


func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
    } catch let error as NSError {
        print("error making thumbnail ", error.localizedDescription)
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(named: "photoPlaceholder")!
    }
}
