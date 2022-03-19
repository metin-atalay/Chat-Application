//
//  Status.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import Foundation

enum Status : String {
    case Avaible = "Avaible"
    case Busy = "Busy"
    case AtSchool = "At School"
    case AtWork = "At Work"
    case AtMovie = "At The Movie"
    case BattaryAboutToDie = "Battary About To Die"
    case CantTalk = "Can't Talk"
    case InAMeeting = "In a Meeting"
    case AtTheGym = "At The Gym"
    case Sleeping = "Sleeping"
    case UrgentCallsOnly  =  "Urgent Calls Only"
    
    
    static var array : [Status] {
        
        var a: [Status] = []
        
        switch Status.Avaible {
        case .Avaible:
            a.append(.Avaible); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .AtSchool:
            a.append(.AtSchool); fallthrough
        case .AtMovie:
            a.append(.AtMovie); fallthrough
        case .AtWork:
            a.append(.AtWork); fallthrough
        case .BattaryAboutToDie:
            a.append(.BattaryAboutToDie); fallthrough
        case .CantTalk:
            a.append(.CantTalk); fallthrough
        case .AtTheGym:
            a.append(.AtTheGym); fallthrough
        case .Sleeping:
            a.append(.Sleeping); fallthrough
        case .UrgentCallsOnly:
            a.append(.UrgentCallsOnly); fallthrough
        case .InAMeeting:
            a.append(.InAMeeting);
        }
        return a
    }
    
}
