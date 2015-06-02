//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    
    @IBAction func submit(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(self.username.text, password: "mypass") { (user:PFUser?, error:NSError?) -> Void in
            if user != nil {
                println("user is logged in")
                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                println("log in failed")
                // set up a new user
                var user = PFUser()
                user.username = self.username.text
                user.password = "mypass"
                user.signUpInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) -> Void in
                    if error == nil {
                        println("signed up")
                        self.performSegueWithIdentifier("showUsers", sender: self)
                    }else {
                        print(error)
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

