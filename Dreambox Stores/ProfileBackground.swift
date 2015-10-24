//
//  ProfileBackground.swift
//  Dreambox Stores
//
//  Created by Daniel Coellar on 10/22/15.
//  Copyright © 2015 dreambox. All rights reserved.
//

import UIKit

class ProfileBackground : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func drawRect(rect: CGRect) {
        
        self.backgroundColor = UIColor.clearColor()

        let path = UIBezierPath(ovalInRect: rect)
        UIColor(red: 185.0/255.0, green: 207.0/255.0, blue: 55.0/255.0, alpha: 1.0).setFill()
        path.fill()
        
        
    }
    
}

