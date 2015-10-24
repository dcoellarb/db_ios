//
//  LoginViewController.swift
//  Dreambox Stores
//
//  Created by Daniel Coellar on 10/20/15.
//  Copyright © 2015 dreambox. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class LoginViewController: UIViewController {

    let login = UIButton()
    let email  = UITextField()
    let password  = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)        
        
        let logo = UIImageView()
        logo.image = UIImage(named: "AppLogo")
        self.view.addSubview(logo)
        logo.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(150)
            make.height.equalTo(100)
            make.top.equalTo(self.view.snp_top).offset(20)
            make.centerX.equalTo(self.view)
        }
        
        
        email.placeholder = "Email"
        email.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(email)
        email.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.top.equalTo(logo.snp_bottom)
            make.centerX.equalTo(self.view)
        }
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, email.frame.height))
        email.leftView = paddingView
        email.leftViewMode = UITextFieldViewMode.Always
        
        
        password.placeholder = "Contraseña"
        password.backgroundColor = UIColor.whiteColor()
        password.secureTextEntry = true;
        self.view.addSubview(password)
        password.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.top.equalTo(email.snp_bottom).offset(20)
            make.centerX.equalTo(self.view)
        }
        let paddingPasswordView = UIView(frame: CGRectMake(0, 0, 15, password.frame.height))
        password.leftView = paddingPasswordView
        password.leftViewMode = UITextFieldViewMode.Always
        
        
        login.setTitle("LOGIN", forState: UIControlState.Normal)
        login.backgroundColor = UIColor(red: 231.0/255.0, green: 31.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        login.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        login.titleLabel?.font = UIFont(name: (login.titleLabel?.font.fontName)!, size: 12)
        login.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        login.frame = CGRectMake(0,0,0,0)
                
        self.view.addSubview(login)
        
        login.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.top.equalTo(password.snp_bottom).offset(20)
            make.centerX.equalTo(self.view)
        }
    }
    
    func pressed(sender: UIButton!) {
        let parameters = ["usuario":email.text!,"clave":password.text!]
        
        Alamofire.request(.POST, "http://dreambox.com.ec/APP/login.php", parameters: parameters, encoding: .JSON).response { (request, response, data, error) -> Void in
            
            if error == nil{
                
                do{
                    let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                    if let jsonResponse = json as? NSDictionary {
                        if let jsonError = jsonResponse["error"]{
                            if let jsonErrorArray = jsonError as? NSArray{
                                for element in jsonErrorArray {
                                    print("\(element) ")
                                }
                                
                                let alert = UIAlertController(title: "Error", message: "No se pudo ingresar al sistema, por favor contactese con Dreambox", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                        
                        if let codigo = jsonResponse["codigo"]{
                            NSUserDefaults.standardUserDefaults().setObject(codigo, forKey: "token")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            let reservas = ReservasListViewController()
                            let home:NavigationViewController = NavigationViewController(rootViewController:reservas)
                            self.presentViewController(home, animated: true, completion: nil)
                        }
                        
                        
                    }
                } catch {
                    print("error throw in catch")
                }
            
            }else{
                print("Error - \(error!.localizedDescription)")
            }
        }
    }
    
}
