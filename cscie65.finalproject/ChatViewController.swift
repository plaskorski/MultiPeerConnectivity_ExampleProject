//
//  ChatViewController.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/20/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import UIKit

class ChatCell : UITableViewCell {
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
}

class ChatViewController: UITableViewController {
    
    var dataSource : ProfileManager?
    fileprivate var modelObserver : NSObjectProtocol?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataSource = delegate.profileManager
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.ProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "Chat VC received chat updated notification")
            if let s = self {
                s.modelChanged()
            }
        }
        chatTableView.backgroundColor = UIColor.lightGray
        modelChanged()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        if let obs = modelObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    func modelChanged() {
        NSLog("%@", "Chat VC ran modelChanged")
        chatTableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.profilesWithChats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataSource!.profilesWithChats[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")! as! ChatCell
        
        if let name = data.screenName {
            cell.screenNameLabel.text = name
        } else {
            cell.screenNameLabel.text = "Unknown"
        }
        
        if let img = data.img {
            if let status = data.discoveryStatus {
                if status == "Found" {
                    cell.profileImage.image = img
                } else {
                    cell.profileImage.image = img.toGrayscale()
                }
            } else {
                cell.profileImage.image = img
            }
        }
        
        if let status = data.discoveryStatus {
            if status == "Lost" {
                cell.statusLabel.text = "Lost"
            } else if status == "Found" {
                cell.statusLabel.text = "Found"
            } else {
                cell.statusLabel.text = "NA"
            }
        }
        
        // Parse messages
        let c = data.getMessages()
        var textMessage = ""
        let cnt = c.count
        print("There are \(cnt) messages")
        if cnt >= 3 {
            textMessage = "\(c[cnt-3].toString())\n\(c[cnt-2].toString())\n\(c[cnt-1].toString()))"
        } else if cnt == 2 {
            textMessage = "\(c[cnt-2].toString())\n\(c[cnt-1].toString()))"
        } else if cnt == 1 {
            textMessage = "\(c[cnt-1].toString())"
        }
        cell.messageLabel.text = textMessage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DetailedChatVCSeque", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailedChatViewController
        let id = dataSource!.profilesWithChats[chatTableView.indexPathForSelectedRow!.row].appID
        vc.id = id
    }

}

