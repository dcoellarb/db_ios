//
//  ReservaViewController.swift
//  Dreambox Stores
//
//  Created by Daniel Coellar on 10/23/15.
//  Copyright © 2015 dreambox. All rights reserved.
//

import UIKit
import Alamofire

class ReservaViewController : UIViewController {
    
    let codigo = UITextField()
    let validar = UIButton()
    var reserva : Reserva?
    var fecha = UILabel()
    var hora = UILabel()
    var token: String = ""
    
    init() {
        super.init(nibName:nil, bundle: nil)
    }

    init(reserva param : Reserva) {
        self.reserva = param
        super.init(nibName:nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        self.view.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        
        self.navigationController!.setToolbarHidden(true, animated: false)
        
        if let selectedReserva = self.reserva {
            print(selectedReserva.cod_reserva)
            setBody(self.view,offset: 70)
        }else{
            setHeader()
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let token = userDefaults.valueForKey("token") {
            self.token = token as! String
        }        
    }
    
    internal func setHeader(){
        codigo.placeholder = "Ingrese el codigo"
        codigo.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(codigo)
        codigo.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.top.equalTo(self.view.snp_top).offset(75)
            make.centerX.equalTo(self.view)
        }
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, codigo.frame.height))
        codigo.leftView = paddingView
        codigo.leftViewMode = UITextFieldViewMode.Always
        
        validar.setTitle("VALIDAR CODIGO", forState: UIControlState.Normal)
        validar.titleLabel?.font = UIFont(name: (validar.titleLabel?.font.fontName)!, size: 12)
        validar.backgroundColor = UIColor(red: 231.0/255.0, green: 31.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        validar.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        validar.addTarget(self, action: "validate:", forControlEvents: .TouchUpInside)
        self.view.addSubview(validar)
        validar.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.top.equalTo(codigo.snp_bottom).offset(10)
            make.centerX.equalTo(self.view)
        }
    }
    
    func validate(sender: UIButton!) {
        let parameters = ["codigo":codigo.text! as String]
        let headers = ["Code": token]
        Alamofire.request(.POST, "http://dreambox.com.ec/APP/abrirReserva.php", parameters: parameters, headers: headers, encoding: .JSON).response { (request, response, data, error) -> Void in
            
            if error == nil{
                do{
                    let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                    if let jsonResponse = json as? NSDictionary {
                        if let jsonError = jsonResponse["error"]{
                            if let jsonErrorArray = jsonError as? NSArray{
                                for element in jsonErrorArray {
                                    print("\(element) ")
                                }
                                
                                let alert = UIAlertController(title: "Error", message: "No se pudo validar el codigo de la reservar, por favor intente de nuevo o contactese con Dreambox", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }else{
                            self.reserva = Reserva()
                            self.reserva!.cliente = "Daniel Coellar"
                            self.reserva!.paquete = "Inpusm dolo"
                            self.reserva!.fecha = NSDate()
                            
                            self.codigo.enabled = false
                            self.codigo.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
                            self.validar.enabled = false
                            self.validar.setTitleColor(UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0), forState: .Normal)
                            
                            self.setBody(self.validar, offset: 60)
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

    
    internal func setBody(topView : UIView, offset: Int){
        let title = UILabel();
        title.text = "Informacion de la reserva"
        title.font = UIFont(name: title.font.fontName, size: 10)
        self.view.addSubview(title)
        title.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topView).offset(offset)
            make.height.equalTo(20)
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.centerX.equalTo(self.view)
        }
        
        let container = UIView()
        container.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(container)
        container.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(title.snp_bottom).offset(2)
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.centerX.equalTo(self.view)
        }
        
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        imageView.backgroundColor = UIColor(red: 185.0/255.0, green: 207.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        imageView.layer.cornerRadius = 5.0
        imageView.image = UIImage(named: "Profile")
        container.addSubview(imageView)
        imageView.snp_makeConstraints{
            $0.left.equalTo(container.snp_left).offset(5)
            $0.top.equalTo(container.snp_top).offset(3)
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }
        
        let labelCliente = UILabel()
        labelCliente.text = self.reserva?.cliente
        container.addSubview(labelCliente)
        labelCliente.font = UIFont(name: labelCliente.font.fontName, size: 14)
        labelCliente.snp_makeConstraints{
            $0.left.equalTo(container.snp_left).offset(35)
            $0.top.equalTo(container.snp_top).offset(3)
            $0.height.equalTo(20)
        }
        
        let labelPaquete = UILabel()
        labelPaquete.text = self.reserva?.paquete
        labelPaquete.lineBreakMode = .ByWordWrapping
        labelPaquete.numberOfLines = 2
        container.addSubview(labelPaquete)
        labelPaquete.font = UIFont(name: labelPaquete.font.fontName, size: 10)
        labelPaquete.snp_makeConstraints{
            $0.left.equalTo(container.snp_left).offset(35)
            $0.top.equalTo(labelCliente.snp_bottom)
            $0.height.equalTo(20)
        }
        
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        container.addSubview(separator)
        separator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imageView.snp_bottom).offset(30)
            make.height.equalTo(1)
            make.left.equalTo(container.snp_left)
            make.width.equalTo(container.snp_width)
        }
        
        let fechaTitle = UILabel();
        fechaTitle.text = "Toque la fecha y hora para actualizar"
        fechaTitle.font = UIFont(name: title.font.fontName, size: 10)
        container.addSubview(fechaTitle)
        fechaTitle.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(separator.snp_bottom).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(self.view.snp_width).offset(-50)
            make.centerX.equalTo(self.view)
        }
        
        let fechaContainer = UIView()
        fechaContainer.backgroundColor = UIColor(red: 246.0/255.0, green: 161.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        container.addSubview(fechaContainer)
        fechaContainer.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(fechaTitle.snp_bottom)
            make.height.equalTo(40)
            make.left.equalTo(container.snp_left).offset(5)
            make.right.equalTo(container.snp_right).offset(-5)
        }
        
        let fechaLabel = UILabel()
        fechaLabel.text = "Fecha y hora"
        fechaLabel.textColor = UIColor.whiteColor()
        fechaLabel.font = UIFont(name: fechaLabel.font.fontName, size: 8)
        fechaContainer.addSubview(fechaLabel)
        fechaLabel.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(fechaContainer)
            make.left.equalTo(fechaContainer.snp_left).offset(5)
            make.width.equalTo(60)
        }
        
        fechaContainer.addSubview(fecha)
        fecha.text = formatDate((reserva?.fecha)!)
        fecha.textColor = UIColor.whiteColor()
        fecha.font = UIFont(name: title.font.fontName, size: 12)
        fecha.userInteractionEnabled = true
        let fechaTapGesture = UITapGestureRecognizer(target: self, action: "datePicker")
        fecha.addGestureRecognizer(fechaTapGesture)
        fecha.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(fechaContainer)
            make.left.equalTo(fechaLabel.snp_right).offset(5)
            make.width.equalTo(80)
        }

        fechaContainer.addSubview(hora)
        hora.text = formatTime((reserva?.fecha)!)
        hora.textColor = UIColor.whiteColor()
        hora.font = UIFont(name: title.font.fontName, size: 12)
        hora.userInteractionEnabled = true
        let horaTapGesture = UITapGestureRecognizer(target: self, action: "timePicker")
        hora.addGestureRecognizer(horaTapGesture)
        hora.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(fechaContainer)
            make.left.equalTo(fecha.snp_right).offset(5)
            make.right.equalTo(fechaContainer.snp_right).offset(5)
        }
        
        let actualizar = UIButton()
        actualizar.setTitle("ACTUALIZAR", forState: UIControlState.Normal)
        actualizar.titleLabel?.font = UIFont(name: (actualizar.titleLabel?.font.fontName)!, size: 12)
        actualizar.backgroundColor = UIColor(red: 231.0/255.0, green: 31.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        actualizar.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        actualizar.addTarget(self, action: "update:", forControlEvents: .TouchUpInside)
        self.view.addSubview(actualizar)
        actualizar.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view.snp_width).offset(-40)
            make.height.equalTo(40)
            make.bottom.equalTo(self.view.snp_bottom)
            make.centerX.equalTo(self.view)
        }
    }

    func update(sender: UIButton!) {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: (self.reserva?.fecha)!)
        let fecha = String(components.year) + "-" + String(components.month) + "-" + String(components.day)
        
        let parameters = ["fecha":fecha,"hora":String(components.hour),"minuto":String(components.minute),"id_estado":self.reserva!.id_estado as String,"id_paquete":self.reserva!.id_paquete as String,"cod_reserva":self.reserva!.cod_reserva as String]
        let headers = ["Code": token]
        Alamofire.request(.POST, "http://dreambox.com.ec/APP/actualizarReserva.php", parameters: parameters, headers: headers, encoding: .JSON).response { (request, response, data, error) -> Void in
            
            if error == nil{
                do{
                    let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                    if let jsonResponse = json as? NSDictionary {
                        if let jsonError = jsonResponse["error"]{
                            if let jsonErrorArray = jsonError as? NSArray{
                                for element in jsonErrorArray {
                                    print("\(element) ")
                                }
                                
                                let alert = UIAlertController(title: "Error", message: "No se pudo actualizar la reserva, por favor contactese con Dreambox", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                } catch {
                    print("error throw in catch")
                    let alert = UIAlertController(title: "Error", message: "No se pudo actualizar la reserva, por favor contactese con Dreambox", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }else{
                print("Error - \(error!.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "No se pudo actualizar la reserva, por favor contactese con Dreambox", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    internal func datePicker(){
        
        DatePickerDialog().show("Fecha", doneButtonTitle: "Seleccionar", cancelButtonTitle: "Cancelar", defaultDate:(self.reserva?.fecha)!, datePickerMode: .Date) {
            (date) -> Void in
            self.reserva?.fecha = date
            self.fecha.text = self.formatDate(date)
        }
        
    }

    internal func formatDate(date: NSDate) -> String{
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: date)
        
        let year = String(components.year)
        var month = String(components.month)
        var day = String(components.day)
        
        if components.day < 10 { day = "0" + day}
        if components.month < 10 { month = "0" + month}
        
        return day + "/" + month + "/" + year
    }
    

    internal func timePicker(){
        
        DatePickerDialog().show("Hora", doneButtonTitle: "Seleccionar", cancelButtonTitle: "Cancelar", defaultDate:(self.reserva?.fecha)!, datePickerMode: .Time) {
            (date) -> Void in
            self.reserva?.fecha = date
            self.hora.text = self.formatTime(date)
        }
        
    }
    
    internal func formatTime(date: NSDate) -> String{
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: date)
        
        var hour = String(components.hour)
        if (components.hour > 12){
            hour = String(components.hour - 12)
        }
        var minute = String(components.minute)
        var ampm = "am"
        
        if components.hour < 10 { hour = "0" + hour}
        if components.minute < 10 { minute = "0" + minute}
        if components.hour > 11 { ampm = "pm" }
        
        return hour + ":" + minute + ampm
    }
    
}
