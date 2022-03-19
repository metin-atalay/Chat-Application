//
//  MapViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 30.01.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var location: CLLocation?
    var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView()
        configureLeftButton()
        configureTitle()
    }
    
    private func configureMapView(){
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: (location?.coordinate)!))
        }
        
        view.addSubview(mapView)
        
        
    }
    
    private func configureLeftButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain,
                                                                target: self, action: #selector(self.backButtonPressed))
    }
    
   @objc func backButtonPressed(){
    navigationController?.popViewController(animated: true)
        
    }
    
    private func configureTitle() {
        
        self.title = "Map View"
    }

  

}
