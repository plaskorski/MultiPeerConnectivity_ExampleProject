//
//  ProfileManager.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/24/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import UIKit

/*
The ProfileManager is the main data model that contains all of the profiles. It
 uses notifications to let the VCs know when the data has changed, and 
 datasource/delegate protocol to communicate with the back end.
*/
class ProfileManager {
    
    var myself : Profile?
    var profiles = [String:Profile]()
    var delegate : ServiceManager?
    
    var allProfiles : [Profile] {
        var p = [Profile]()
        for profile in profiles {
            p.append(profile.1)
        }
        return p
    }
    
    // Return profiles that have chat data
    var profilesWithChats : [Profile] {
        var p = [Profile]()
        for profile in profiles {
            if profile.1.getMessages().count > 0 {
                p.append(profile.1)
            }
        }
        return p
    }
    
    // Add or Change user's profile text and image
    func insertSelf(_ d: [String:String]?, img: UIImage?) {
        NSLog("%@", "Data Model inserted text for self")
        if let me = myself {
            if d != nil {me.insertText(d!)}
            if img != nil {me.insertImage(img!)}
        } else {
            if let id = delegate?.myAppID {
                NSLog("%@", "Data Model created profile for self")
                myself = Profile(id: id, d: d)
                if d != nil {myself?.insertText(d!)}
                if img != nil {myself?.insertImage(img!)}
            }
        }
        selfProfileNotification()
    }
    
    // Add or change peer's profile text
    func insertText(_ id: String, d: [String:String]?) {
        NSLog("%@", "Data Model inserted text for \(id)")
        if let profile = profiles[id] {
            if let newImgDate = d?["imgDate"] {
                if let oldImgDate = profile.imgDate {
                    if newImgDate != oldImgDate {
                        delegate?.sendImageRequest(profile.appID)
                    }
                } else {
                    delegate?.sendImageRequest(profile.appID)
                }
            }
            profile.insertText(d)
            profiles[id] = profile
        } else {
            let profile = Profile(id: id, d: d)
            if profile.imgDate != nil {
                delegate?.sendImageRequest(profile.appID)
            }
            profiles[id] = profile
        }
        profileNotification()
    }
    
    // Add or change peer's profile image
    func insertImage(_ id: String, img: UIImage) {
        NSLog("%@", "Data Model inserted image for \(id)")
        if let profile = profiles[id] {
            profile.insertImage(img)
            profiles[id] = profile
            profileNotification()
        }
    }
    
    // Add a message to the peer's chat data
    func insertChat(_ id: String, message: Message) {
        NSLog("%@", "Data Model inserted chat for \(id)")
        if let profile = profiles[id] {
            profile.insertChat(message)
            profiles[id] = profile
            profileNotification()
        }
    }
    
    // Change the discovery status
    func setStatus(_ id: String, status: String) {
        NSLog("%@", "Data Model set status for \(id) to \(status)")
        if let profile = profiles[id] {
            profile.setStatus(status)
            profiles[id] = profile
            profileNotification()
        }
    }
    
    // Notifies when the peer's profile or chat has changed
    func profileNotification() {
        NSLog("%@", "Data Model sent Profile updated notification")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: MCNotifications.ProfileUpdated.rawValue), object: self))
    }

    // Notifies when the user's profile has changed
    func selfProfileNotification() {
        NSLog("%@", "Data Model sent Self Profile updated notification")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: MCNotifications.SelfProfileUpdated.rawValue), object: self))
    }
    
}
