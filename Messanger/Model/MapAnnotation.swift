//
//  MapAnnotation.swift
//  Messanger
//
//  Created by Metin Atalay on 30.01.2022.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
