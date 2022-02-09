//
//  GlobalFunctions.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import Foundation


func fileNameFrom(fileURL : String) -> String {
    
    let fileName = ((fileURL.components(separatedBy: "_").last!).components(separatedBy: "?").first!).components(separatedBy: ".").first!
    
    print(fileName)
    
    return fileName
    
}
