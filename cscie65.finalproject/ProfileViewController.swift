//
//  ProfileViewController.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/20/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import UIKit

class ProfileCell : UITableViewCell {
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
}

class ProfileViewController: UITableViewController {
    
    var dataSource : ProfileManager?
    fileprivate var modelObserver : NSObjectProtocol?

    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataSource = delegate.profileManager
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.ProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "Profiles VC received profile updated notification")
            if let s = self {
                s.modelChanged()
            }
        }
        profileTableView.backgroundColor = UIColor.lightGray
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
        NSLog("%@", "Profiles VC ran modelChanged")
        profileTableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.allProfiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataSource!.allProfiles[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell")! as! ProfileCell
        
        if let name = data.screenName {
            cell.screenNameLabel.text = name
        } else {
            cell.screenNameLabel.text = "Unknown"
        }
        
        if let age = data.age {
            cell.ageLabel.text = String(age)
        } else {
            cell.ageLabel.text = "Unknown"
        }
        
        if let headline = data.headline {
            cell.headlineLabel.text = headline
        } else {
            cell.headlineLabel.text = "Unknown"
        }

        if let about = data.about {
            cell.aboutLabel.text = about
        } else {
            cell.aboutLabel.text = "Unknown"
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

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DetailedProfileVCSeque", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailedProfileViewController
        let id = dataSource!.allProfiles[profileTableView.indexPathForSelectedRow!.row].appID
        vc.id = id
    }


}

