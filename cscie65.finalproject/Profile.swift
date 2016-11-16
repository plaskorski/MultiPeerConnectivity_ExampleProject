//
//  Profile.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 5/2/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import UIKit

/* 
 The data model for the peer's profile. This would be what is persisted to
 disk if I got that to work.
 */
class Profile {
    
    var appID : String
    var screenName : String?
    var age : String?
    var headline : String?
    var about : String?
    var img : UIImage?
    var imgDate : String?
    fileprivate var messages = [Message]()
    var discoveryStatus : String?
    
    init(id: String, d: [String:String]?) {
        appID = id
        insertText(d)
    }
    
    func insertText(_ d: [String:String]?) {
        if let dct = d {
            if let screenName = dct["screenName"] {self.screenName = screenName}
            if let age = dct["age"] {self.age = age}
            if let headline = dct["headline"] {self.headline = headline}
            if let about = dct["about"] {self.about = about}
            if let imgDate = dct["imgDate"] {self.imgDate = imgDate}
        }
    }
    
    func insertImage(_ img: UIImage) {
        self.img = img
        self.imgDate = "\(Date())"
    }
    
    func insertChat(_ msg: Message) {
        messages.append(msg)
    }
    
    func setStatus(_ status: String) {
        discoveryStatus = status
    }
    
    func asDict() -> [String:String] {
        var d = [String:String]()
        d["displayName"] = appID
        d["screenName"] = screenName
        d["age"] = age
        d["headline"] = headline
        d["about"] = about
        d["imgDate"] = imgDate
        return d
    }
    
    func getMessages() -> [Message] {
        var m = messages
        m.sort(by: Message.messageOrder)
        return m
    }
    
}
