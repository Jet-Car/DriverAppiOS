//
//  AppTypeSelectionUV.swift
//  DriverApp
//
//  Created by Admin on 3/12/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit

class AppTypeSelectionUV: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentView: UIView!
    
    var cntView:UIView!
    
    var generalFunc = GeneralFunctions()
    
    @IBOutlet weak var rideView: UIView!
    @IBOutlet weak var deliveryView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var rideImgView: UIImageView!
    @IBOutlet weak var rideLbl: MyLabel!
    @IBOutlet weak var deliveryImgView: UIImageView!
    @IBOutlet weak var deliveryLbl: MyLabel!
    @IBOutlet weak var servicesImgView: UIImageView!
    @IBOutlet weak var servicesLbl: MyLabel!
    
    var screenToNavigate = ""
    var isFromDriverStatesUV = false
    var userProfileJson:NSDictionary!
    var isFromMainUV = false
    var isViewLoad = false
    
    var totalAddedVehicles = -1
    
    @IBOutlet weak var tableView: UITableView!
//    var dataArrList = [String]()
    var dataArrList = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addBackBarBtn()
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TYPE")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
      
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        self.userProfileJson = userProfileJson
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isViewLoad == false{
            cntView = self.generalFunc.loadView(nibName: "AppTypeSelctionScreenDesign", uv: self, contentView: contentView)
            cntView.frame = self.view.bounds
            self.contentView.addSubview(cntView)
            //self.setView()
            
            self.tableView.register(HelpCategoryListTVCell.self, forCellReuseIdentifier: "HelpCategoryListTVCell")
            self.tableView.register(UINib(nibName: "HelpCategoryListTVCell", bundle: nil), forCellReuseIdentifier: "HelpCategoryListTVCell")
            
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.bounces = false
            self.tableView.tableFooterView = UIView()
            
            setData()
           
            self.tableView.reloadData()
            self.isViewLoad = true
        }
        
        if(GeneralFunctions.getValue(key: "IS_VEHICLE_ADDED") != nil && (GeneralFunctions.getValue(key: "IS_VEHICLE_ADDED") as! String).uppercased() == "YES"){
            totalAddedVehicles = 1
            screenToNavigate = "MANAGE_VEHICLE"
            setData()
        }
        
        GeneralFunctions.removeValue(key: "IS_VEHICLE_ADDED")
        
    }
    
    func setData(){
        self.dataArrList.removeAll()
        if(screenToNavigate == "UPLOAD_DOC"){
            if(self.userProfileJson.get("eShowRideVehicles").uppercased() != "NO"){
                let dict = NSMutableDictionary()
                dict["Title"] = "LBL_UPLOAD_DOC_RIDE"
                dict["Type"] = "RIDE"
                self.dataArrList.append(dict)
            }
            
            if(self.userProfileJson.get("eShowDeliveryVehicles").uppercased() != "NO"){
                let dict = NSMutableDictionary()
                dict["Title"] = "LBL_UPLOAD_DOC_DELIVERY"
                dict["Type"] = "DELIVERY"
                self.dataArrList.append(dict)
            }
            
            if (self.userProfileJson.get("APP_TYPE") == Utils.cabGeneralType_Ride_Delivery_UberX){
                let dict = NSMutableDictionary()
                dict["Title"] = "LBL_UPLOAD_DOC_UFX"
                dict["Type"] = "UBERX"
                self.dataArrList.append(dict)
            }
        }else{
            if(self.userProfileJson.get("eShowRideVehicles").uppercased() != "NO"){
                let dict = NSMutableDictionary()
                dict["Title"] = self.totalAddedVehicles != -1 ? (self.totalAddedVehicles > 0 ? "LBL_MANANGE_VEHICLES_RIDE" : "LBL_ADD_VEHICLES_RIDE") : "LBL_MANANGE_VEHICLES_RIDE"
                dict["Type"] = "RIDE"
                self.dataArrList.append(dict)
            }
            
            if(self.userProfileJson.get("eShowDeliveryVehicles").uppercased() != "NO"){
                let dict = NSMutableDictionary()
                dict["Title"] = self.totalAddedVehicles != -1 ? (self.totalAddedVehicles > 0 ? "LBL_MANANGE_VEHICLES_DELIVERY" : "LBL_ADD_VEHICLES_DELIVERY") : "LBL_MANANGE_VEHICLES_DELIVERY"
                dict["Type"] = "DELIVERY"
                self.dataArrList.append(dict)
            }
            
            if (isFromMainUV == false && (self.userProfileJson.get("APP_TYPE") == Utils.cabGeneralType_Ride_Delivery_UberX)){
                let dict = NSMutableDictionary()
                dict["Title"] = "LBL_MANANGE_OTHER_SERVICES"
                dict["Type"] = "UBERX"
                self.dataArrList.append(dict)
            }
            
        }
        
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.dataArrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCategoryListTVCell", for: indexPath) as! HelpCategoryListTVCell
        
        let item = self.dataArrList[indexPath.item]
        
        cell.categoryNameLbl.font = UIFont.systemFont(ofSize: 16)
        cell.categoryNameLbl.sizeToFit()
        cell.categoryNameLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: item.get("Title"))
        cell.categoryNameLbl.removeGestureRecognizer(cell.categoryNameLbl.tapGue)
        
        GeneralFunctions.setImgTintColor(imgView: cell.rightImgView, color: UIColor(hex: 0x9f9f9f))
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.dataArrList[indexPath.item]

        if(item.get("Type") == "RIDE"){
            if(screenToNavigate == "UPLOAD_DOC"){
                let listOfDocumentUV = GeneralFunctions.instantiateViewController(pageName: "ListOfDocumentUV") as! ListOfDocumentUV
                listOfDocumentUV.isRedirectFromAppTypeSelView = true
                listOfDocumentUV.eType = Utils.cabGeneralType_Ride
                self.pushToNavController(uv: listOfDocumentUV)
            }else if (screenToNavigate == "ADD_VEHICLE") {
                let addVehiclesUv = GeneralFunctions.instantiateViewController(pageName: "AddVehiclesUV") as! AddVehiclesUV
                addVehiclesUv.eType = Utils.cabGeneralType_Ride
                addVehiclesUv.isFromDriverStatesUV = self.isFromDriverStatesUV
                self.pushToNavController(uv: addVehiclesUv)
            }else if (screenToNavigate == "MANAGE_VEHICLE") {
                let manageVehiclesUv = GeneralFunctions.instantiateViewController(pageName: "ManageVehiclesUV") as! ManageVehiclesUV
                manageVehiclesUv.eType = Utils.cabGeneralType_Ride
                self.pushToNavController(uv: manageVehiclesUv)
            }
        }else if(item.get("Type") == "DELIVERY"){
            if(screenToNavigate == "UPLOAD_DOC"){
                let listOfDocumentUV = GeneralFunctions.instantiateViewController(pageName: "ListOfDocumentUV") as! ListOfDocumentUV
                listOfDocumentUV.eType = Utils.cabGeneralType_Deliver
                listOfDocumentUV.isRedirectFromAppTypeSelView = true
                self.pushToNavController(uv: listOfDocumentUV)
            }else if (screenToNavigate == "ADD_VEHICLE") {
                let addVehiclesUv = GeneralFunctions.instantiateViewController(pageName: "AddVehiclesUV") as! AddVehiclesUV
                addVehiclesUv.eType = Utils.cabGeneralType_Deliver
                addVehiclesUv.isFromDriverStatesUV = self.isFromDriverStatesUV
                self.pushToNavController(uv: addVehiclesUv)
            }else if (screenToNavigate == "MANAGE_VEHICLE") {
                let manageVehiclesUv = GeneralFunctions.instantiateViewController(pageName: "ManageVehiclesUV") as! ManageVehiclesUV
                manageVehiclesUv.eType = Utils.cabGeneralType_Deliver
                self.pushToNavController(uv: manageVehiclesUv)
            }
        }else if(item.get("Type") == "UBERX"){
            if(screenToNavigate == "UPLOAD_DOC"){
                let listOfDocumentUV = GeneralFunctions.instantiateViewController(pageName: "ListOfDocumentUV") as! ListOfDocumentUV
                listOfDocumentUV.isRedirectFromAppTypeSelView = true
                listOfDocumentUV.eType = Utils.cabGeneralType_UberX
                self.pushToNavController(uv: listOfDocumentUV)
            }else if (screenToNavigate == "MANAGE_VEHICLE") {
                let manageServicesUV = GeneralFunctions.instantiateViewController(pageName: "ManageServicesUV") as! ManageServicesUV
                
                manageServicesUV.iVehicleCategoryId = self.userProfileJson.get("UBERX_PARENT_CAT_ID")
                self.pushToNavController(uv: manageServicesUV)
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 72
    }
    
    func setView(){
        self.rideLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RIDE")
        self.deliveryLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVER")
        self.servicesLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_OTHER")
        
        GeneralFunctions.setImgTintColor(imgView: self.rideImgView, color: UIColor(hex: 0x272727))
        GeneralFunctions.setImgTintColor(imgView: self.deliveryImgView, color: UIColor(hex: 0x272727))
        GeneralFunctions.setImgTintColor(imgView: self.servicesImgView, color: UIColor(hex: 0x272727))
        
        Utils.createRoundedView(view: deliveryImgView, borderColor: UIColor.black, borderWidth: 1)
        Utils.createRoundedView(view: rideImgView, borderColor: UIColor.black, borderWidth: 1)
        Utils.createRoundedView(view: servicesImgView, borderColor: UIColor.black, borderWidth: 1)
        
        
        let rideViewTapGue = UITapGestureRecognizer()
        rideViewTapGue.addTarget(self, action: #selector(self.rideViewTapped))
        
        let deliveryViewTapGue = UITapGestureRecognizer()
        deliveryViewTapGue.addTarget(self, action: #selector(self.deliveryViewTapped))
        
        let serviceViewTapGue = UITapGestureRecognizer()
        serviceViewTapGue.addTarget(self, action: #selector(self.serviceViewTapped))
        
        self.rideView.isUserInteractionEnabled = true
        self.deliveryView.isUserInteractionEnabled = true
        self.servicesView.isUserInteractionEnabled = true
        
        self.rideView.addGestureRecognizer(rideViewTapGue)
        self.deliveryView.addGestureRecognizer(deliveryViewTapGue)
        self.servicesView.addGestureRecognizer(serviceViewTapGue)
        
        if isFromMainUV == true{
            self.servicesView.isHidden = true
        }
    }
    
    func rideViewTapped(){
        
    }
    
    func deliveryViewTapped(){
        
    }
    
    func serviceViewTapped(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func unwindToAppTypeSelection(_ segue:UIStoryboardSegue) {
        
    }

}
