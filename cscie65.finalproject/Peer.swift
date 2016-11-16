//
//  Peer.swift
//
//  Created by plaskorski on 4/16/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// Used for tracking the lost/found status
enum DiscoveryStatus : String {
    
    case Found = "Found"
    case Lost = "Lost"
    
}

// Used for tracking the current status of any connection.
enum ConnectionStatus : String {
    
    case Connected = "Connected"
    case Connecting = "Connecting"
    case NotConnected = "NotConnected"
    
}

// The Peer contains the discovery and connnection status of the peer, a session
//  for it to use when needed, and the dictionary of profile data.
class Peer : NSObject, MCSessionDelegate {
    
    var peerID : MCPeerID
    var discoveryInfo : [String:String]?
    
    var dataSource : ProfileManager
    var delegate : ServiceManager
    
    var session : MCSession
    var discoveryStatus : DiscoveryStatus // lost/found/nil(no session)
    var connectionStatus : ConnectionStatus // connected/connected/notconnected/nil (no session)
    
    fileprivate var taskQueue = [Task]()
    
    fileprivate var timer : Timer?

    init (peerID : MCPeerID, discoveryInfo: [String:String]?, pM : ProfileManager, delegate: ServiceManager) {

        self.peerID = peerID
        self.discoveryInfo = discoveryInfo
        self.dataSource = pM
        self.delegate = delegate
        self.session = MCSession(peer: delegate.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.discoveryStatus = .Lost
        self.connectionStatus = .NotConnected
        super.init()
        self.session.delegate = self
        NSLog("%@", "Created Peer with Peer ID: \(peerID)")
    }
    
    // update the peer's connection status
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        switch state {
            case .connecting:
                connectionStatus = .Connecting
                NSLog("%@", "peer \(peerID) didChangeState: Connecting")
            case .connected:
                connectionStatus = .Connected
                NSLog("%@", "peer \(peerID) didChangeState: Connected")
                NSLog("%@", "Calling runTasksForPeer \(peerID.displayName)")
                startTimer()
            case .notConnected:
                NSLog("%@", "peer \(peerID) didChangeState: NotConnected")
                connectionStatus = .NotConnected
        }
    
    }
    
    // Unpack and respond to incoming data from peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        NSLog("%@", "didReceiveData from peer: \(peerID.displayName)")
        
        if let packet = NSKeyedUnarchiver.unarchiveObject(with: data) as? Packet {
            switch packet.packetType as String {
                case PacketType.Message.rawValue:
                    NSLog("%@", "unpacking Packet from \(peerID.displayName) as message")
                    if let msg = NSKeyedUnarchiver.unarchiveObject(with: packet.data as Data) as? Message {
                        NSLog("%@", "unpacked Packet from \(peerID.displayName) as message, sending to data model")
                        msg.source = "Received"
                        dataSource.insertChat(peerID.displayName, message: msg)
                    } else {
                        NSLog("%@", "could not unpack Packet from \(peerID.displayName) as message")
                    }
                case PacketType.Image.rawValue:
                    NSLog("%@", "unpacking Packet from \(peerID.displayName) as image")
                    if let img = UIImage(data: packet.data as Data) {
                        NSLog("%@", "unpacked Packet from \(peerID.displayName) as image, sending to data model")
                        dataSource.insertImage(peerID.displayName, img: img)
                    } else {
                        NSLog("%@", "could not unpack Packet from \(peerID.displayName) as image")
                    }
                case PacketType.ImageRequest.rawValue:
                    NSLog("%@", "unpacking Packet from \(peerID.displayName) as image request")
                    if let img = dataSource.myself?.img {
                        NSLog("%@", "Calling send image to \(peerID.displayName)")
                        delegate.sendImage(peerID.displayName, img: img)
                    } else {
                        NSLog("%@", "No profile image found for self")
                    }
                default:
                    NSLog("%@", "could not unpack Packet from \(peerID.displayName)")
            }
        } else {
            NSLog("%@", "Could not convert data from \(peerID.displayName) to Packet")
        }
        NSLog("%@", "Finished didReceiveData from \(peerID.displayName), disconnecting from session")
        session.disconnect()
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream from peer: \(peerID), doing nothing")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName: \(resourceName) from peer: \(peerID), doing nothing")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName: \(resourceName) from peer: \(peerID), doing nothing")
    }
    
    // Start the timer to run tasks
    func startTimer() {
        NSLog("%@", "Starting timer for: \(peerID)")
        let interval = TimeInterval(MCConfig.timerInterval)
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(Peer.runTasks), userInfo: nil, repeats: true)
    }
    
    // Stop the timer to run tasks
    func stopTimer() {
        NSLog("%@", "Ending timer for: \(peerID)")
        timer?.invalidate()
    }
    
    // Add a task to the task queue
    func appendTask(_ task: Task) {
        
        NSLog("%@", "appending task to queue for: \(task.id)")
        taskQueue = taskQueue + [task]
        startTimer()
    }
    
    // Run the tasks, if any. Also invites peer if needed.
    func runTasks() {
        NSLog("%@", "Calling run tasks, there are \(taskQueue.count) tasks on the queue")

        if !(taskQueue.count == 0) && (discoveryStatus == .Found) {
            if session.connectedPeers.contains(peerID) {
                var newTaskQueue = [Task]()
                for task in taskQueue {
                    NSLog("%@", "Running task...")
                    do {
                        try session.send(task.data as Data, toPeers: [peerID], with: .reliable)
                        NSLog("%@", "appending task to queue for: \(task.id)")
                    } catch {
                        NSLog("%@", "Data not sent! Putting task on top of queue...")
                        newTaskQueue.append(task)
                    }
                    if let packet = NSKeyedUnarchiver.unarchiveObject(with: task.data as Data) as? Packet {
                        if let msg = NSKeyedUnarchiver.unarchiveObject(with: packet.data as Data) as? Message {
                            dataSource.insertChat(peerID.displayName, message: msg)
                        }
                    }
                }
                taskQueue = newTaskQueue
            } else if connectionStatus != .Connecting {
                NSLog("%@", "Peer not connected, Inviting to connect.")
                delegate.serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: TimeInterval(20))
            }
        } else {
            stopTimer()
        }
    }
    
}
