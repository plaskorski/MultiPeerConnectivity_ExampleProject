//
//  ServiceManager.swift
//
//  Created by plaskorski on 4/16/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// Contains static constants used through the backend
class MCConfig {
    static let serviceName = "myservice" // should be more unique
    static let timerInterval = 0.5 // how many seconds between task runs
}

// Notification string values
enum MCNotifications : String {
    case ProfileUpdated = "ProfileUpdated"
    case ProfileImageUpdated = "ProfileImageUpdated"
    case SelfProfileUpdated = "SelfProfileUpdated"
}

/*
The service manager runs both the browser and advertiser services, and handles
 their delegate methods. It also is the central point for sending data to a
 peer.
*/
class ServiceManager : NSObject, MCNearbyServiceBrowserDelegate,
    MCNearbyServiceAdvertiserDelegate {
    
    // the id for MultiPeerConnectivity, changes with every run
    var myPeerID : MCPeerID
    // the "persistent" application level id.
    var myAppID : String
    // public advertised data, contains the profile w/o image
    var myDiscoveryInfo : [String:String]?

    // MPC classes needed to browse and advertise a service
    var serviceAdvertiser : MCNearbyServiceAdvertiser
    var serviceBrowser : MCNearbyServiceBrowser

    // All peers are stored in the ServiceManager
    var peers = [String:Peer]()
    
    // Data model
    var dataSource : ProfileManager

    // Used to respond to update of user's profile
    fileprivate var modelObserver : NSObjectProtocol?

    init(pM: ProfileManager, d: [String:String]) {

        dataSource = pM

        if let displayName = d["displayName"] {
            myPeerID = MCPeerID(displayName: displayName)
            myAppID = displayName
        } else {
            let id = String(arc4random_uniform(10000000))
            myPeerID = MCPeerID(displayName: id)
            myAppID = id
        }
        myDiscoveryInfo = d
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: myDiscoveryInfo, serviceType: MCConfig.serviceName)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MCConfig.serviceName)
        super.init()
        startServices()
        
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.SelfProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "MCServiceManager received self profile updated notification")
            if let s = self {
                if let me = s.dataSource.myself {
                    s.stopServices()
                    let d = me.asDict()
                    s.myDiscoveryInfo = d
                    // http://stackoverflow.com/questions/27517632/how-to-create-a-delay-in-swift
                    let time = DispatchTime(uptimeNanoseconds: (UInt64) (Double(4 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)))
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        s.startServices()
                    }
                }
            }
        }
    }
    
    deinit {
        
        stopServices()
        
    }

    func startServices() {

        NSLog("%@", "Starting Services")
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: myDiscoveryInfo, serviceType: MCConfig.serviceName)
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        
    }

    func stopServices() {
        
        NSLog("%@", "Stopping Services")
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.delegate = nil
        serviceBrowser.delegate = nil
        
    }

    // Always accept invitations.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        NSLog("%@", "didReceiveInvitationFromPeer: \(peerID)")
        if let peer = peers[peerID.displayName] {
            invitationHandler(true, peer.session)
        } else {
            NSLog("%@", "peer does not exist, ignoring invitation from: \(peerID)")
        }

    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        
    }
    
    // When peer is found, add it to the peer array and data model
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        NSLog("%@", "foundPeer: \(peerID)")
        if peerID.displayName != myPeerID.displayName {
            if let peer = peers[peerID.displayName] {
                peer.discoveryInfo = info
                peer.discoveryStatus = .Found
                peers[peerID.displayName] = peer
            } else {
                let peer = Peer(peerID: peerID, discoveryInfo: info, pM: dataSource, delegate: self)
                peer.discoveryStatus = .Found
                peers[peerID.displayName] = peer
            }
            dataSource.insertText(peerID.displayName, d: info)
            dataSource.setStatus(peerID.displayName, status: "Found")
        }
    }
    
    // When peer is lost, set its status to "Lost"
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        NSLog("%@", "lostPeer: \(peerID)")

        if let peer = peers[peerID.displayName] {
            peer.discoveryStatus = .Lost
            peers[peerID.displayName] = peer
        }
        dataSource.setStatus(peerID.displayName, status: "Lost")

    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        
    }

    // Encodes a message into a packet, then task, and adds to peer's tasks
    func sendMessage(_ id: String, msg: String) {
        
        NSLog("%@", "Adding sendMessage task for: \(id)")
        
        let message = Message(time: "\(Date())", source: "Sent", message: msg)
        let msgdata = NSKeyedArchiver.archivedData(withRootObject: message)
        let packet = Packet(packetType: PacketType.Message.rawValue, data: msgdata)
        let data = NSKeyedArchiver.archivedData(withRootObject: packet) as Data
        let task = Task(id: id, data: data)
        peers[id]?.appendTask(task)
        
    }
    
    // Encodes an image into a packet, then task, and adds to peer's tasks
    func sendImage(_ id: String, img: UIImage) {
        
        if let imgdata = UIImagePNGRepresentation(img) {
            NSLog("%@", "Adding sendImage task for: \(id)")
            let packet = Packet(packetType: PacketType.Image.rawValue, data: imgdata)
            let data = NSKeyedArchiver.archivedData(withRootObject: packet) as Data
            let task = Task(id: id, data: data)
            peers[id]?.appendTask(task)
        } else {
            NSLog("%@", "Could not add sendImage task for: \(id)")
        }
        
    }
    
    // Encodes an image request into a packet, then task, and adds to peer's tasks
    func sendImageRequest(_ id: String) {
        
        NSLog("%@", "Adding sendImageRequest task for: \(id)")
        
        let packet = Packet(packetType: PacketType.ImageRequest.rawValue, data: Data())
        let data = NSKeyedArchiver.archivedData(withRootObject: packet) as Data
        let task = Task(id: id, data: data)
        peers[id]?.appendTask(task)
        
    }

}
