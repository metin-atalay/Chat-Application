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
    case Messages
    case Typing
    case Channel
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
