//
//  FCollectionReference.swift
//  Messanger
//
//  Created by Metin Atalay on 2.01.2022.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference:String{
    case User
    case Recent
}


func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
