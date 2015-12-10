//
//  AccessCodeViewController.swift
//  Critter Sitter
//
//  Created by Michael Slaughter on 11/12/15.
//  Copyright © 2015 Pet Sitter App. All rights reserved.
//

import UIKit
import CoreData

class AccessCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accessText: UITextField!
    @IBOutlet var textFields: [UITextField]!
    var activeTextField: UITextField? = nil
    
    @IBOutlet weak var errorLabel: UILabel!
    var user: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Red border for missing inputs
        let missingColor : UIColor = UIColor(red: 1, green: 0, blue:0, alpha: 1.0)
        self.errorLabel.textColor = missingColor
        self.input.layer.borderColor = missingColor.CGColor
        self.accessText.layer.borderColor = missingColor.CGColor
        self.accessText.layer.borderWidth = 0
        self.input.layer.borderWidth = 0
        self.errorLabel.text = ""
        
        if (user != nil){
            self.input.text = user!.valueForKey("email") as! String
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func confirmAccount(sender: AnyObject) {
        // Reset border width
        self.input.layer.borderWidth = 0
        
        // Check every input is provided, if not set border for input to red
        if(self.input.text?.isEmpty == true) {
            self.errorLabel.text = "Missing input!"
            self.input.layer.borderWidth = 2
            return
        }
        
        if(self.accessText.text?.isEmpty == true) {
            self.errorLabel.text = "Missing input!"
            self.accessText.layer.borderWidth = 2
            return
        }
        // Create POST object
        let poster = Poster()
        var dataString = ""
        var postString = "http://discworld-js1h704o.cloudapp.net/test/code.php"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // Construct data string for the post
        dataString += "email=" + self.input.text! + "&code=" + self.accessText.text!
        
        // Perform POST
        poster.doPost(postString, dataString: dataString) {
        (response, errorStr) -> Void in
            if let errorString = errorStr {
                // Check the POST was successful
                self.errorLabel.text = errorString
                print(self.errorLabel.text)
            } else {
                if let status = response["status"] as? String {
                    if (status == "ok") {
                        // Account activiated so update status and go to home page
                        // Segue to the Home Page
                        self.user!.setValue("LOGGEDIN", forKey: "status")
                        
                        // Complete save and handle potential error
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                        
                        self.navigationController!.viewControllers = []
                        self.performSegueWithIdentifier("HomeView", sender:self)
                    } else {
                        // Check for error message
                        if let errorMessage = response["message"] as? String {
                            self.errorLabel.text = errorMessage
                            print(errorMessage)
                        } else {
                            // Unknown error occurred
                            self.errorLabel.text = "Unknown Error!"
                        }
                    }
                } else {
                    // Unknown error occurred
                    self.errorLabel.text = "Unknown Error!"
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        
        if (segue.identifier == "HomeView") {
            if let homeViewController = destinationViewController as? HomeViewController {
                homeViewController.user = user
            }
        }
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        activeTextField?.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        activeTextField?.resignFirstResponder()
        
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


}
