//
//  DetailedChatViewController.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/29/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import UIKit

class DetailedChatViewController: UIViewController {
    
    var dataSource : ProfileManager?
    var serviceManager : ServiceManager?
    fileprivate var modelObserver : NSObjectProtocol?
    var id : String?
    var profile : Profile?
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sendTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataSource = delegate.profileManager
        serviceManager = delegate.serviceManager
        profile = dataSource!.profiles[id!]
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.ProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "Detailed Chat VC received chat updated notification")
            if let s = self {
                s.modelChanged()
            }
        }
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
        NSLog("%@", "Detailed Chat VC ran modelChanged")
        chatTextView.text = messagesToString()
        screennameLabel.text = profile!.screenName
        ageLabel.text = profile!.age
        if let img = profile!.img {
            if let status = profile!.discoveryStatus {
                if status == "Found" {
                    imageView.image = img
                } else {
                    imageView.image = img.toGrayscale()
                }
            } else {
                imageView.image = img
            }
        }
        if let status = profile!.discoveryStatus {
            if status == "Lost" {
                statusLabel.text = "Lost"
            } else if status == "Found" {
                statusLabel.text = "Found"
            } else {
                statusLabel.text = "NA"
            }
        }
        view.setNeedsDisplay()
    }
    
    func messagesToString() -> String {
        
        let data = profile!.getMessages()
        var txt = ""
        for msg in data {txt = "\(txt)\(msg.toString())\n"}
        return txt
    }
        
    @IBAction func backPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ToMainVCFromDetailedChat", sender: self)
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        if let txt = sendTextField.text {
            serviceManager!.sendMessage(id!, msg: txt)
            sendTextField.text = nil
            modelChanged()
        }
    }
}

