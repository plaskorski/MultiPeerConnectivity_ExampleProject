//
//  TaskUtilities.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/25/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

// Type of data sent in a Packet.
enum PacketType : String {
    case Image = "image"
    case ImageRequest = "imageRequest"
    case Message = "message"
}

/*
 The Packet class is what is sent and received over MPC as NSData. It contains
 a string representing the kind of data, and the data itself.
*/
class Packet: NSObject, NSCoding {
    
    var packetType: String!
    var data: Data!
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.packetType = decoder.decodeObject(forKey: "packetType") as! String
        self.data = decoder.decodeObject(forKey: "data") as! Data
    }
    convenience init(packetType: String, data: Data) {
        self.init()
        self.packetType = packetType
        self.data = data
    }
    func encode(with coder: NSCoder) {
        if let packetType = packetType { coder.encode(packetType, forKey: "packetType") }
        if let data = data { coder.encode(data, forKey: "data") }
        
    }
}

// Encoded as NSData to be packaged into a Packet
class Message: NSObject, NSCoding {
    
    var time: String!
    var source: String!
    var message: String!
    
    convenience init(time: String, source: String, message: String) {
        self.init()
        self.time = time
        self.source = source
        self.message = message
    }

    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.time = decoder.decodeObject(forKey: "time") as! String
        self.source = decoder.decodeObject(forKey: "source") as! String
        self.message = decoder.decodeObject(forKey: "message") as! String
    }

    func encode(with coder: NSCoder) {
        if let time = time { coder.encode(time, forKey: "time") }
        if let source = source { coder.encode(source, forKey: "source") }
        if let message = message { coder.encode(message, forKey: "message") }
    }
    
    static func messageOrder(_ m1: Message, m2: Message) -> Bool {
        return m1.time < m2.time
    }

    func toString() -> String {
        if source == "Sent" {return "Me: \(message)"}
        else {return "Him: \(message)"}
    }
    
}

/*
 The Task class contains a peer id and data Packet. The task is added to the 
 queue to be run by the peer object.
*/
class Task {
    
    var id : String
    var data : Data
    
    init(id: String, data: Data) {
        self.id = id
        self.data = data
    }
    
}

// Quick extension to UIImage to convert an image to grayscale
extension UIImage {
    // from http://stackoverflow.com/questions/22422480/apply-black-and-white-filter-to-uiimage
    func toGrayscale() -> UIImage {
        let ciImage = UIKit.CIImage(image: self)
        let grayscale = ciImage!.applyingFilter("CIColorControls", withInputParameters: [ kCIInputSaturationKey: 0.0 ])
        return UIImage(ciImage: grayscale)
    }

}
