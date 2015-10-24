//
//  NavigationViewController.swift
//  Dreambox Stores
//
//  Created by Daniel Coellar on 10/20/15.
//  Copyright © 2015 dreambox. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    var viewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent        
        
        self.navigationBar.barTintColor = UIColor(red: 185.0/255.0, green: 207.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}