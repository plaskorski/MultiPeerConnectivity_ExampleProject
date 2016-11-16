//
//  DetailedProfileViewController.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/29/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import UIKit

class DetailedProfileViewController: UIViewController {
    
    var dataSource : ProfileManager?
    fileprivate var modelObserver : NSObjectProtocol?
    var id : String?
    var profile : Profile?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataSource = delegate.profileManager
        profile = dataSource!.profiles[id!]
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.ProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "Detailed Profile VC received profile updated notification")
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
        NSLog("%@", "Detailed Profile VC ran modelChanged")
        
        if let p = dataSource?.profiles[id!] {
            nameLabel.text = p.screenName
            ageLabel.text = p.age
            headlineLabel.text = p.headline
            aboutTextView.text = p.about
            if let img = p.img {
                if let status = p.discoveryStatus {
                    if status == "Found" {
                        imageView.image = img
                    } else {
                        imageView.image = img.toGrayscale()
                    }
                } else {
                    imageView.image = img
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetailedChatFromDetailedProfile" {
            let vc = segue.destination as! DetailedChatViewController
            vc.id = id
        }
    }

    @IBAction func chatPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ToDetailedChatFromDetailedProfile", sender: self)
    }
   
    @IBAction func backPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ToMainVCFromDetailedProfile", sender: self)
    }

}
