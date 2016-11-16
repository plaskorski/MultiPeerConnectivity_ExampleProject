//
//  EditorViewController.swift
//  cscie65.finalproject
//
//  Created by plaskorski on 4/28/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import Foundation
import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var dataSource : ProfileManager?
    fileprivate var modelObserver : NSObjectProtocol?
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    let imagePicker = UIImagePickerController()
    
    
    @IBAction func profileSavePressed(_ sender: AnyObject) {
        NSLog("%@", "Editor VC save button pressed")
        var d = [String:String]()
        d["displayName"] = dataSource?.myself?.appID
        d["screenName"] = nameTextField.text
        d["age"] = ageTextField.text
        d["headline"] = headlineTextField.text
        d["about"] = aboutTextView.text
        dataSource?.insertSelf(d, img: imageView.image)
    }
    
    func imageTapped(_ img: AnyObject){
        NSLog("%@", "Editor VC image tapped")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataSource = delegate.profileManager
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(EditorViewController.imageTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MCNotifications.SelfProfileUpdated.rawValue), object: dataSource, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            NSLog("%@", "Editor VC received self profile updated notification")
            if let s = self {
                s.modelChanged()
            }
        }
        modelChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let obs = modelObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    func modelChanged() {
        NSLog("%@", "Editor VC ran modelChanged")
        
        if let me = dataSource?.myself {
            nameTextField.text = me.screenName
            ageTextField.text = me.age
            headlineTextField.text = me.headline
            aboutTextView.text = me.about
            if let img = me.img {
                imageView.image = img
            }
        }
    }

}
