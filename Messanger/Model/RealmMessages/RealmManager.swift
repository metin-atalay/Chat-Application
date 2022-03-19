//
//  RealmManager.swift
//  Messanger
//
//  Created by Metin Atalay on 22.01.2022.
//

import Foundation
import  RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() {}
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
           // realm.refresh()
            try realm.write {
                realm.add(object, update: .all)
            }
        }catch {
                print( "Error saving realm Object ", error.localizedDescription)
            }
        }
}
