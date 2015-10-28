//
//  ViewController.swift
//  Dreambox Stores
//
//  Created by Daniel Coellar on 10/19/15.
//  Copyright © 2015 dreambox. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class ReservasListViewController: UIViewController {

    let CELL_ID = "cellreuse"
    let HOST = "http://dreambox.com.ec"
    var reservas = [Reserva]()
    var token: String = ""
    var tableView : UITableView = UITableView()
    var search = ""
    var id_estado = "5"
    var searchController: UISearchController!
    let filterContainer = UIView()
    var filterOpen = false
    var filterTopConstraint: Constraint? = nil
    let filterPenedientes = UILabel()
    let filterCompletadas = UILabel()
    let filterCanceladas = UILabel()
    let filterTitle = UILabel()
    var refreshControl:UIRefreshControl!
    
    
    /// State restoration values.
    enum RestorationKeys : String {
        case viewControllerTitle
        case searchControllerIsActive
        case searchBarText
        case searchBarIsFirstResponder
    }
    
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    var restoredState = SearchControllerRestorableState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title="Dreambox Stores"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add")
        addButton.tintColor = UIColor(red: 231.0/255.0, green: 31.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        let filterButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "filters")
        filterButton.tintColor = UIColor(red: 231.0/255.0, green: 31.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        
        var items: Array<UIBarButtonItem> = []
        items.append(filterButton)
        items.append(flexibleSpace)
        items.append(addButton)
        
        self.setToolbarItems(items, animated: true)
        
        tableView.separatorColor = UIColor.clearColor();
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(ReservaTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Refrescar")
        self.refreshControl.addTarget(self, action: "LoadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        searchController.searchBar.barTintColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        /*
        searchController.view.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        searchController.searchBar.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        searchController.searchBar.barStyle = UIBarStyle.BlackTranslucent
        */
        
        
        self.filterContainer.backgroundColor = UIColor.whiteColor()
        filterContainer.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        self.view.addSubview(self.filterContainer)
        self.filterContainer.snp_makeConstraints{(make) -> Void in
            self.filterTopConstraint = make.top.equalTo(self.view.snp_bottom).constraint
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.height.equalTo(140)
        }
        
        let filterHeader = UIView()
        filterHeader.backgroundColor = UIColor(red: 246.0/255.0, green: 181.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        self.filterContainer.addSubview(filterHeader)
        filterHeader.snp_makeConstraints{
            $0.top.equalTo(self.filterContainer.snp_top)
            $0.left.equalTo(self.filterContainer.snp_left)
            $0.right.equalTo(self.filterContainer.snp_right)
            $0.height.equalTo(20)
        }
        
        filterTitle.text = "filtrar por..."
        filterTitle.font = UIFont(name: filterTitle.font.fontName, size: 10)
        filterTitle.textColor = UIColor.whiteColor()
        filterHeader.addSubview(filterTitle)
        filterTitle.snp_makeConstraints{
            $0.centerY.equalTo(filterHeader)
            $0.left.equalTo(filterHeader.snp_left).offset(5)
        }

        let filterPendientesContainer = UIView()
        self.filterContainer.addSubview(filterPendientesContainer)
        filterPendientesContainer.snp_makeConstraints{
            $0.top.equalTo(filterHeader.snp_bottom)
            $0.width.equalTo(self.filterContainer.snp_width)
            $0.height.equalTo(40)
        }
    
        filterPenedientes.text = "Pendientes"
        filterPenedientes.font = UIFont(name: "sans-serif-Bold", size: 10)
        filterPenedientes.userInteractionEnabled = true
        let filterPenedientesTapGesture = UITapGestureRecognizer(target: self, action: "filterPendientesAction")
        filterPenedientes.addGestureRecognizer(filterPenedientesTapGesture)
        filterPendientesContainer.addSubview(filterPenedientes)
        filterPenedientes.snp_makeConstraints{
            $0.centerY.equalTo(filterPendientesContainer)
            $0.left.equalTo(filterPendientesContainer.snp_left).offset(20)
        }
        
        let filterCompletadasContainer = UIView()
        self.filterContainer.addSubview(filterCompletadasContainer)
        filterCompletadasContainer.snp_makeConstraints{
            $0.top.equalTo(filterPendientesContainer.snp_bottom)
            $0.width.equalTo(self.filterContainer.snp_width)
            $0.height.equalTo(40)
        }
        
        filterCompletadas.text = "Completadas"
        filterCompletadas.font = UIFont(name: filterTitle.font.fontName, size: 12)
        filterCompletadas.userInteractionEnabled = true
        let filterCompletadasTapGesture = UITapGestureRecognizer(target: self, action: "filterCompletadasAction")
        filterCompletadas.addGestureRecognizer(filterCompletadasTapGesture)
        filterCompletadasContainer.addSubview(filterCompletadas)
        filterCompletadas.snp_makeConstraints{
            $0.centerY.equalTo(filterCompletadasContainer)
            $0.left.equalTo(filterCompletadasContainer.snp_left).offset(20)
        }

        let filterCanceladasContainer = UIView()
        self.filterContainer.addSubview(filterCanceladasContainer)
        filterCanceladasContainer.snp_makeConstraints{
            $0.top.equalTo(filterCompletadasContainer.snp_bottom)
            $0.width.equalTo(self.filterContainer.snp_width)
            $0.height.equalTo(40)
        }
        
        filterCanceladas.text = "Canceladas"
        filterCanceladas.font = UIFont(name: filterTitle.font.fontName, size: 12)
        filterCanceladas.userInteractionEnabled = true
        let filterCanceladasTapGesture = UITapGestureRecognizer(target: self, action: "filterCanceladasAction")
        filterCanceladas.addGestureRecognizer(filterCanceladasTapGesture)
        filterCanceladasContainer.addSubview(filterCanceladas)
        filterCanceladas.snp_makeConstraints{
            $0.centerY.equalTo(filterCanceladasContainer)
            $0.left.equalTo(filterCanceladasContainer.snp_left).offset(20)
        }

        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        self.definesPresentationContext = true
    }

    internal func add(){
        let detailViewController = ReservaViewController()
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    internal func filters(){
        if filterOpen{
            filterOpen = false
            self.filterTopConstraint!.updateOffset(0)
        }else{
            filterOpen = true
            self.filterTopConstraint!.updateOffset(-180)
        }
    }
    
    internal func filterPendientesAction(){
        self.id_estado = "5"
        LoadData()
        filters()
        
        filterPenedientes.font = UIFont(name: "sans-serif-Bold", size: 10)
        filterCompletadas.font = UIFont(name: filterTitle.font.fontName, size: 10)
        filterCanceladas.font = UIFont(name: filterTitle.font.fontName, size: 10)
        
    }
    internal func filterCompletadasAction(){
        self.id_estado = "6"
        LoadData()
        filters()
        
        filterPenedientes.font = UIFont(name: filterTitle.font.fontName, size: 10)
        filterCompletadas.font = UIFont(name: "sans-serif-Bold", size: 10)
        filterCanceladas.font = UIFont(name: filterTitle.font.fontName, size: 10)
        
    }
    internal func filterCanceladasAction(){
        self.id_estado = "8"
        LoadData()
        filters()
        
        filterPenedientes.font = UIFont(name: filterTitle.font.fontName, size: 10)
        filterCompletadas.font = UIFont(name: filterTitle.font.fontName, size: 10)
        filterCanceladas.font = UIFont(name: "sans-serif-Bold", size: 10)

    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let token = userDefaults.valueForKey("token") {
            self.token = token as! String
            LoadData();
        }        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.active = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func LoadData() -> Void{
        let headers = [
            "Code": token
        ]
        let url  = HOST + "/APP/listadoReservas.php"
        Alamofire.request(.GET, url, parameters : ["id_estado":self.id_estado,"cliente":self.search], headers: headers)
            .response { (request, response, data, error) -> Void in
                                
                if error == nil{
                    
                    self.reservas = [Reserva]()
                    
                    do{
                        let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                        if let jsonResponse = json as? NSDictionary {
                            if let jsonError = jsonResponse["error"]{
                                if let jsonErrorArray = jsonError as? NSArray{
                                    var isWrongUser = false
                                    for element in jsonErrorArray {
                                        print("\(element) ")
                                        if let jsonError = element as? NSDictionary{
                                            if let cod = jsonError["codigo"] as? NSNumber{
                                                if cod == 100{
                                                    isWrongUser = true
                                                }
                                            }
                                        }
                                    }

                                    if isWrongUser{
                                        let loginController = LoginViewController()
                                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                        appDelegate.window!.rootViewController = loginController
                                    }
                                }
                            }
                            
                            if let datos = jsonResponse["datos"]{
                                if let datosArray = datos as? NSArray{
                
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
                                    
                                    for element in datosArray {
                                        print("\(element) ")
                                        if let elementDic = element as? NSDictionary{
                                            let reserva = Reserva()
                                            reserva.cliente = (elementDic["cliente"] as? String)!
                                            reserva.cod_reserva = (elementDic["cod_reserva"] as? String)!
                                            reserva.estado = (elementDic["estado"] as? String)!
                                            
                                            let reservaFechaStr = (elementDic["fecha"] as? String)! + " +0000"
                                            let date = dateFormatter.dateFromString(reservaFechaStr)
                                            reserva.fecha = date!.dateByAddingTimeInterval(60*60*5)
                                            
                                            reserva.id_estado = (elementDic["id_estado"] as? String)!
                                            reserva.id_paquete = (elementDic["id_paquete"] as? String)!
                                            reserva.id_proveedor = (elementDic["id_proveedor"] as? String)!
                                            reserva.nom_proveedor = (elementDic["nom_proveedor"] as? String)!
                                            reserva.paquete = (elementDic["paquete"] as? String)!
                                            self.reservas.append(reserva)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }catch{
                    }
                }else{
                    print("Error - \(error!.localizedDescription)")
                }
                
                let count = String(self.reservas.count)
                print("reloading data:" + count)
                self.tableView.reloadData();
                self.refreshControl.endRefreshing()
        }
    }
}

extension ReservasListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ReservasListViewController : UISearchControllerDelegate{
    func presentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
        self.search = ""
        self.LoadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
}

extension ReservasListViewController : UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)

        self.search = strippedString
        self.LoadData()
    }
}

extension ReservasListViewController : UITableViewDelegate{
    
    /**
    Action when a row with a suggested item is tapped
    */
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedReserva = reservas[indexPath.row]
        
        if selectedReserva.id_estado == "5" || selectedReserva.id_estado == "7" {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            // Set up the detail view controller to show.
            let detailViewController = ReservaViewController(reserva: selectedReserva)
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }
}

extension ReservasListViewController : UITableViewDataSource{
    
    /**
    Returns the number of sections
    */
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
    Returns the number of sections
    */
    internal func tableView(tableView: UITableView,numberOfRowsInSection section: Int)-> Int {
        return reservas.count
    }
    
    /**
    Returns the cell to be draw
    */
    internal func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        let cellView = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as? ReservaTableViewCell
        cellView?.labelCliente.text = reservas[indexPath.row].cliente
        cellView?.labelPaquete.text = reservas[indexPath.row].paquete
        cellView?.labelFecha.text = formatDate(reservas[indexPath.row].fecha)
        //cellView?.labelHora.text = reservas[indexPath.row].cliente
        
        
        return cellView!
    }
    
    internal func formatDate(date: NSDate) -> String{
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: date)
    
        let month = components.month
        let day = components.day
        
        return getMonthName(month) + " " + String(day)
    }
    
    internal func getMonthName(month: Int) -> String {
        switch(month){
        case 1:
            return "Ene"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Abr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Ago"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dic"
        default:
            return "Ene"
        }
    }
    
    /**
    Returns the cell height
    */
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 50.0
    }
    
    
    /**
    Returns the header to be draw
    */
    internal func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        return headerView
    }
    
    /**
    Returns the header height
    */
    internal func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    /**
    Returns the footer to be draw
    */
    internal func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UITableViewHeaderFooterView()
        return footerView
    }
    
    /**
    Returns the footer height
    */
    internal func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

class ReservaTableViewCell : UITableViewCell{

    var labelCliente = UILabel()
    var labelPaquete = UILabel()
    var labelFecha = UILabel()
    var labelHora = UILabel()
    var profile = ProfileBackground()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        
        let background = CGRect(x: 0, y: 0, width: 100, height: 40)
        let backgroundView = UIView(frame: background)
        backgroundView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backgroundView)
        backgroundView.snp_makeConstraints{
            $0.left.equalTo(contentView.snp_left)
            $0.top.equalTo(contentView.snp_top)
            $0.width.equalTo(contentView.snp_width)
            $0.height.equalTo(40)
        }

        let separator = CGRect(x: 0, y: 0, width: 100, height: 1)
        let separatorView = UIView(frame: separator)
        separatorView.backgroundColor = UIColor.whiteColor()
        separatorView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        contentView.addSubview(separatorView)
        separatorView.snp_makeConstraints{
            $0.left.equalTo(contentView.snp_left)
            $0.top.equalTo(backgroundView.snp_bottom)
            $0.width.equalTo(contentView.snp_width)
            $0.height.equalTo(1)
        }
        
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        imageView.backgroundColor = UIColor(red: 185.0/255.0, green: 207.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        imageView.layer.cornerRadius = 5.0
        imageView.image = UIImage(named: "Profile")
        backgroundView.addSubview(imageView)
        imageView.snp_makeConstraints{
            $0.left.equalTo(backgroundView.snp_left).offset(5)
            $0.top.equalTo(backgroundView.snp_top).offset(3)
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }
        
        backgroundView.addSubview(labelCliente)
        labelCliente.font = UIFont(name: labelCliente.font.fontName, size: 14)
        labelCliente.snp_makeConstraints{
            $0.left.equalTo(backgroundView.snp_left).offset(35)
            $0.top.equalTo(backgroundView.snp_top).offset(3)
            $0.height.equalTo(20)
        }

        backgroundView.addSubview(labelPaquete)
        labelPaquete.font = UIFont(name: labelPaquete.font.fontName, size: 10)
        labelPaquete.snp_makeConstraints{
            $0.left.equalTo(backgroundView.snp_left).offset(35)
            $0.top.equalTo(labelCliente.snp_bottom)
            $0.height.equalTo(20)
        }

        backgroundView.addSubview(labelFecha)
        labelFecha.font = UIFont(name: labelFecha.font.fontName, size: 10)
        labelFecha.textColor = UIColor(red: 185.0/255.0, green: 207.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        labelFecha.snp_makeConstraints{
            $0.right.equalTo(backgroundView.snp_right).offset(-5)
            $0.top.equalTo(backgroundView.snp_top).offset(3)
            $0.height.equalTo(20)
        }

        backgroundView.addSubview(labelHora)
        labelHora.font = UIFont(name: labelHora.font.fontName, size: 10)
        labelHora.snp_makeConstraints{
            $0.right.equalTo(backgroundView.snp_right).offset(5)
            $0.top.equalTo(labelCliente.snp_bottom)
            $0.height.equalTo(20)
        }
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


