//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Vincent Renais on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var userArray:[String] = []
    var activeUser = 0
    var messageCount = 0
    
    
    @IBAction func logOutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    // timer variable
    var timer = NSTimer()
    
    
    // image picker controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // upload to parse
        var imageSend = PFObject(className: "Image")
        imageSend.ACL?.setPublicWriteAccess(true)
        imageSend["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))
        imageSend["sender"] = PFUser.currentUser()?.username
        imageSend["receiver"] = userArray[activeUser]
        imageSend.save()
    }
    
    
    func pickImage(sender:AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        var query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        var users = query?.findObjects()
        if let testUser = users {
            for user in users! {
                println(user.username)
                userArray.append(user.username!!)
                // reload the tableView
                tableView.reloadData()
            }
        }
        
        // Use timer for reloading image
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("checkForMessages"), userInfo: nil, repeats: true)
        
    }

    
    func loadImages() {
        var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0.5
        backgroundView.tag = 3
        self.view.addSubview(backgroundView)
    }
    
    
    func displayImages(photo: UIImage) {
        var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        displayedImage.image = photo
        displayedImage.tag = 3
        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(displayedImage)
    }
    
    
    func alert(senderUsername: String, photo: UIImage, image: AnyObject){
        var alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // load our images
            self.loadImages()
            // var for displayed image
            self.displayImages(photo)
            //delete image
            image.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if success == true {
                    println("Bravo")
                } else {
                    println("didn't work")
                }
            })
            // hide message
            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
        }))
        if self.messageCount == 0 {
            self.presentViewController(alert, animated: true, completion: nil)
            self.messageCount++
        }
    }
    
    
    func checkForMessages() {
        println("Checking for messages")
        // set up a query on the image class
        var query = PFQuery(className: "Image")
        
        // get the user
        query.whereKey("receiver", equalTo: PFUser.currentUser()!.username!)
        
        // grab the images from the list
        var images:Void = query.findObjectsInBackgroundWithBlock { (photo, error) -> Void in
            if (error == nil) {
                var done = false
                if let myPhotoObject = photo {
                    var imageView:PFImageView = PFImageView()
                    for image in myPhotoObject {
                        if let imageFile = image["image"] as? PFFile {
                            imageView.file = imageFile
                            imageView.loadInBackground()
                            println(imageView.file)
                            imageView.loadInBackground({ (photo, error) -> Void in
                                if error == nil {
                                    var senderUsername = ""
                                    if image["sender"] != nil {
                                        senderUsername = image["sender"] as! String
                                    } else {
                                        senderUsername = "unknown user"
                                    }
                                    // create an alert view
                                    self.alert(senderUsername, photo: photo!, image: image)
                                }

                            })
                            done = true
                        }
                    }
                }
            }
        }
        
    }
    
    
    func hideMessage(){
        for subview in self.view.subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = userArray[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activeUser = indexPath.row
        pickImage(self)
    }
}
