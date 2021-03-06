//
//  PetProfileCreationViewController.swift
//  Critter Sitter
//
//  Created by MU IT Program on 11/24/15.
//  Copyright © 2015 Pet Sitter App. All rights reserved.
//

import UIKit
import CoreData

class PetProfileCreationViewController: UIViewController, UIPageViewControllerDataSource {
    var user: NSManagedObject?
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var placeHolderText: NSArray!
    var dataString: String = ""
    var viewControllers = NSMutableArray()
    
    @IBAction func save(sender: AnyObject) {
        // pet profile saving function
        var size = self.pageTitles.count
        
        self.dataString = "user_id=" + (self.user!.valueForKey("user_id") as! String)
        
        for var i = 0; i < size; i++ {
            var vc = self.viewControllerAtIndex(i)
            
            if(self.pageTitles[i] as! String != "Owners") {
                self.dataString += "&"
                
                if(self.pageTitles[i] as! String == "Emergency Contact") {
                    self.dataString +=  "emergency_contact=";

                } else {
                    self.dataString +=  self.pageTitles[i].lowercaseString + "="
                }
            
                if let field = vc.infoField {
                    if(field.text!.isEmpty == false) {
                        self.dataString += field.text!
                    } else {
                        self.dataString += "None"
                    }
                } else {
                self.dataString += "None"
                }
            }
        }
        
        // TODO: POST data then segue, DB needs update to hold all the data
        var postString = "http://discworld-js1h704o.cloudapp.net/test/petCreate.php"
        
        // Create POST object
        let poster = Poster()
        
        print(dataString)
        // Perform POST
        poster.doPost(postString, dataString: dataString) {
            (response, errorStr) -> Void in
            if let errorString = errorStr {
                // Check the POST was successful
                
                print(errorStr);
            } else {
                if let status = response["status"] as? String {
                    if (status == "ok") {
                        // Segue to the Access Code verification
                        self.navigationController!.popViewControllerAnimated(true)
                    } else {
                        // Check for error message
                        if let errorMessage = response["message"] as? String {
                            print(errorMessage)
                        } else {
                            // Unknown error occurred
                        }
                    }
                } else {
                    // Unknown error occurred"
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageTitles = NSArray(objects: "Name", "Bio", "Food", "Medicine", "Exercise", "Bathroom", "Veterinarian", "Other", "Emergency Contact", "Owners")
        self.placeHolderText = NSArray(objects: "Enter Name", "Enter Bio", "Enter Food", "Enter Medicine", "Enter Exercise", "Enter Bathroom", "Enter Veterinarian", "Enter Other", "Enter Emergency Contact", "Enter Owners")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PetCreationPageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
    
            for var i = 0; i < self.pageTitles.count; i++ {
                var vc = self.storyboard?.instantiateViewControllerWithIdentifier("PetProfileCreationContentViewController") as! PetProfileCreationContentViewController
                
                vc.pageIndex = i
                vc.titleText = self.pageTitles[i] as! String
                
                viewControllers.addObject(vc)
            }
        
        let startpage = NSArray(object: self.viewControllers[0])
        self.pageViewController.setViewControllers((startpage as! [UIViewController]), direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMoveToParentViewController(self)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func restartAction(sender: AnyObject) {
        
    }
    
    func viewControllerAtIndex(index: Int) -> PetProfileCreationContentViewController {
        return viewControllers[index] as! PetProfileCreationContentViewController
    }
    
    //MARK: Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PetProfileCreationContentViewController
        var index = vc.pageIndex as Int
        
        if(index == 0 || index == NSNotFound){
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! PetProfileCreationContentViewController
        var index = vc.pageIndex as Int
        
        if(index == NSNotFound){
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
