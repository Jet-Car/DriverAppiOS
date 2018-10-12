//
//  ManageWorkLocationUV.swift
//  DriverApp
//
//  Created by Tarwinder Singh on 30/03/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit

class ManageWorkLocationUV: UIViewController, MyTxtFieldClickDelegate, AddressFoundDelegate, OnLocationUpdateDelegate, MyBtnClickDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noteLbl: MyLabel!
    @IBOutlet weak var workLocHLbl: MyLabel!
    @IBOutlet weak var workLocSelectionArea: UIView!
    @IBOutlet weak var selectedWorkLocTypeTxtField: MyTextField!
    @IBOutlet weak var workLocLbl: MyLabel!
    @IBOutlet weak var workLocStkView: UIStackView!
    @IBOutlet weak var editLocImgView: UIImageView!
    @IBOutlet weak var editLocImgViewWidth: NSLayoutConstraint!
    @IBOutlet weak var workLocContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var workRadiusLbl: MyLabel!
    @IBOutlet weak var workRadiusTxtField: MyTextField!
    @IBOutlet weak var otherWorkRadiusCntViewHeight: NSLayoutConstraint!
    @IBOutlet weak var otherWorkRadiusArea: UIView!
    @IBOutlet weak var otherWorkRadiusTxtField: MyTextField!
    @IBOutlet weak var otherRadiusBtn: MyButton!
    @IBOutlet weak var infoNoteLbl: MyLabel!
    
    let generalFunc = GeneralFunctions()
    
    var getLoc:GetLocation!
    
    var cntView:UIView!
    var userProfileJson:NSDictionary!
    
    var isFirstLaunch = true
    
    var loaderView:UIView!
    
    var eSelectWorkLocation = ""
    
    var isFixedLocationExist = false
    
    var currentLocation:CLLocation!
    
    var workLocAddr = ""
    var workLocLatitude = 0.0
    var workLocLongitude = 0.0
    
    var radiusSelectionListArr = [NSDictionary]()
    
    var isSafeAreaSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cntView = self.generalFunc.loadView(nibName: "ManageWorkLocationScreenDesign", uv: self, contentView: scrollView)
        self.scrollView.backgroundColor = UIColor(hex: 0xFFFFFF)
        self.scrollView.addSubview(cntView)
        self.scrollView.bounces = false
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        self.addBackBarBtn()
        
        setData()
        
        getData()
    }

    override func viewDidAppear(_ animated: Bool) {
        if(isFirstLaunch){
            selectedWorkLocTypeTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            workRadiusTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            
            isFirstLaunch = false
        }
    }
    
    override func closeCurrentScreen() {
        if(self.getLoc != nil){
            self.getLoc.releaseLocationTask()
            self.getLoc.uv = nil
        }
        super.closeCurrentScreen()
    }
    
    override func viewDidLayoutSubviews() {
        let viewHeight = self.infoNoteLbl.frame.maxY + self.infoNoteLbl.paddingBottom + 10
        if(cntView != nil){
            cntView.frame.size.height = viewHeight
        }
        self.scrollView.contentSize = CGSize(width: Application.screenSize.width, height: viewHeight)
    }
    
    func setData(){
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MANAGE_WORK_LOCATION")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MANAGE_WORK_LOCATION")
        
        self.workLocHLbl.backgroundColor = UIColor.UCAColor.AppThemeColor
        
        self.workLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_YOUR_JOB_LOCATION_TXT")
        self.workLocHLbl.fitText()
        
        self.workRadiusLbl.backgroundColor = UIColor.UCAColor.AppThemeColor
        self.workRadiusLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RADIUS")
        self.workRadiusLbl.fitText()
        
        if(UIDevice().type == .iPhoneX || (UIDevice().type == .simulator && Application.screenSize.height == 812)){
            self.noteLbl.paddingBottom = GeneralFunctions.getSafeAreaInsets().bottom / 2
        }
        
        if(self.userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Ride_Delivery_UberX.uppercased()){
            self.noteLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTE")): \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WORK_LOCATION_NOTE"))"
            
            self.noteLbl.halfTextColorChange(fullText: self.noteLbl.text!, changeText: "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTE")):", withColor: UIColor.red)
            self.noteLbl.fitText()
        }else{
            self.noteLbl.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0)
            self.noteLbl.text = ""
            self.noteLbl.fitText()
        }
        
        self.otherRadiusBtn.clickDelegate = self
        self.otherRadiusBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SUBMIT_TXT"))
        
        selectedWorkLocTypeTxtField.myTxtFieldDelegate = self
        
        selectedWorkLocTypeTxtField.disableMenu()
        selectedWorkLocTypeTxtField.getTextField()!.clearButtonMode = .never
        selectedWorkLocTypeTxtField.setEnable(isEnabled: false)
        
        workRadiusTxtField.myTxtFieldDelegate = self
        
        workRadiusTxtField.disableMenu()
        workRadiusTxtField.getTextField()!.clearButtonMode = .never
        workRadiusTxtField.setEnable(isEnabled: false)
        
        self.otherWorkRadiusTxtField.maxCharacterLimit = 4
        self.otherWorkRadiusTxtField.getTextField()!.keyboardType = .numberPad
        
        self.editLocImgViewWidth.constant = 5
        self.editLocImgView.isHidden = true
        
        self.otherWorkRadiusCntViewHeight.constant = 0
        self.otherWorkRadiusArea.isHidden = true
        
        if(userProfileJson.get("PROVIDER_AVAIL_LOC_CUSTOMIZE").uppercased() != "YES"){
            for i in 0..<workLocStkView.subviews.count{
                let sbView = workLocStkView.subviews[i]
                sbView.isHidden = true
            }
            self.infoNoteLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTE")): \n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INFO_WORK_RADIUS"))"
        }else{
            self.infoNoteLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTE")): \n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INFO_WORK_LOCATION"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INFO_WORK_RADIUS"))"
        }
        self.infoNoteLbl.halfTextColorChange(fullText: self.infoNoteLbl.text!, changeText: "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTE")):", withColor: UIColor.red)

        self.infoNoteLbl.fitText()
        
        let locEditTapGue = UITapGestureRecognizer()
        locEditTapGue.addTarget(self, action: #selector(self.locEditTapped))
        editLocImgView.isUserInteractionEnabled = true
        editLocImgView.addGestureRecognizer(locEditTapGue)
    }
    
    func getData(){
        if(loaderView == nil){
            loaderView =  self.generalFunc.addMDloader(contentView: self.view)
            loaderView.isHidden = false
        }else{
            loaderView.isHidden = false
        }
        
        loaderView.backgroundColor = UIColor.clear
        self.scrollView.isHidden = true
        
        let parameters = ["type":"getDriverWorkLocationUFX","iDriverId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                if(dataDict.get("Action") == "1"){
                    
                    self.eSelectWorkLocation = dataDict.getObj(Utils.message_str).get("eSelectWorkLocation")
                    
                    if(dataDict.getObj(Utils.message_str).get("vCountryUnitDriver").uppercased() == "MILES"){
                        self.otherWorkRadiusTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ENTER_RADIUS_PER_MILE"))
                    }else{
                        self.otherWorkRadiusTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ENTER_RADIUS_PER_KMS"))
                    }
                    
                    if(dataDict.getObj(Utils.message_str).get("vWorkLocation") == ""){
                        self.isFixedLocationExist = false
                        self.workLocAddr = ""
                    }else{
                        self.isFixedLocationExist = true
                        self.workLocAddr = dataDict.getObj(Utils.message_str).get("vWorkLocation")
                    }
                    
                    
                    if(self.eSelectWorkLocation.uppercased() == "FIXED"){
                        self.selectedWorkLocTypeTxtField.setText(text: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SPECIFIED_LOCATION"))
                        
                        self.setWorkLoc(address: dataDict.getObj(Utils.message_str).get("vWorkLocation"))
//                        self.workLocLbl.fitText()
                        
                        
                        self.editLocImgViewWidth.constant = 25
                        self.editLocImgView.isHidden = false
                        
                        
                        self.setWorkLocLblHeight()
                        
                    }else{
                        self.selectedWorkLocTypeTxtField.setText(text: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ANY_LOCATION"))
                        self.workLocLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LOAD_ADDRESS")
                        
                        self.setWorkLocLblHeight()
                        
                        self.findAddressOfCurrentLoc()
                        
                    }
                    
                    self.radiusSelectionListArr.removeAll()
                    let radiusListArr = dataDict.getObj(Utils.message_str).getArrObj("RadiusList")
                    
                    for i in 0..<radiusListArr.count{
                        let radiusItem = radiusListArr[i] as! NSDictionary
                        if(radiusItem.get("eSelected").uppercased() == "YES"){
                            self.workRadiusTxtField.setText(text: "\(radiusItem.get("value")) \(radiusItem.get("eUnit"))")
                        }
                        self.radiusSelectionListArr.append(radiusItem)
                    }
                    
                    self.loaderView.isHidden = true
                    self.scrollView.isHidden = false
                   
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
            
            
        })
    }
    
    func findAddressOfCurrentLoc(){
        if(self.currentLocation != nil){
            let getAddFrmLoc = GetAddressFromLocation(uv: self, addressFoundDelegate: self)
            getAddFrmLoc.setLocation(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
            getAddFrmLoc.executeProcess(isOpenLoader: false, isAlertShow: true)
        }
        
        if(getLoc == nil){
            
            getLoc = GetLocation(uv: self, isContinuous: true)
            getLoc.buildLocManager(locationUpdateDelegate: self)
        }
    }
    
    func onAddressFound(address: String, location: CLLocation, isPickUpMode: Bool, dataResult: String) {
        Utils.printLog(msgData: "address::\(address)")
        
        self.setWorkLoc(address: address)
//        self.workLocLbl.fitText()
        setWorkLocLblHeight()
    }
    
    func setWorkLoc(address:String){
        
//        let add = address.replaceNewLineCharater(separator: " ")
//        self.workLocLbl.lineBreakMode = .byWordWrapping
        self.workLocLbl.text = address
        self.workLocLbl.fitText()
    }
    
    func setWorkLocLblHeight(){
        let heightOfWorkLoc = self.workLocLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 55, font: self.workLocLbl.font!) + 10
        self.workLocContainerViewHeight.constant = heightOfWorkLoc
        
    }

    func myBtnTapped(sender: MyButton) {
        if(sender == self.otherRadiusBtn){
            let isDataEntered = Utils.checkText(textField: self.otherWorkRadiusTxtField.getTextField()!) ? (GeneralFunctions.parseDouble(origValue: 0.0, data: Utils.getText(textField: self.otherWorkRadiusTxtField.getTextField()!)) > 0 ? true : Utils.setErrorFields(textField: self.otherWorkRadiusTxtField.getTextField()!, error: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVALID"))) : Utils.setErrorFields(textField: self.otherWorkRadiusTxtField.getTextField()!, error: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT"))
            
            if(isDataEntered){
                self.updateRadius(vWorkLocationRadius: Utils.getText(textField: self.otherWorkRadiusTxtField.getTextField()!))
            }
        }
    }
    func myTxtFieldTapped(sender: MyTextField) {
        if(sender == selectedWorkLocTypeTxtField){
            let openListView = OpenListView(uv: self, containerView: self.view)
            
            var dataList = [String]()
//            if(self.eSelectWorkLocation.uppercased() == "FIXED"){
                dataList += [self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SPECIFIED_LOCATION")]
                dataList += [self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ANY_LOCATION")]
//            }else{
//                dataList += [self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ANY_LOCATION")]
//                dataList += [self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SPECIFIED_LOCATION")]
//            }
            
            openListView.show(listObjects: dataList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WORKLOCATION"), currentInst: openListView, handler: { (selectedItemId) in
//                if(self.eSelectWorkLocation.uppercased() == "FIXED"){
                    if(selectedItemId == 0){
                        self.changeWorkLocationType(eSelectWorkLocation: "Fixed", dataStr: dataList[selectedItemId], isFixedLocationExist: self.isFixedLocationExist)
                    }else{
                        self.changeWorkLocationType(eSelectWorkLocation: "Dynamic", dataStr: dataList[selectedItemId], isFixedLocationExist: true)
                    }
//                }else{
//                    if(selectedItemId == 0){
//                        self.changeWorkLocationType(eSelectWorkLocation: "Dynamic", dataStr: dataList[selectedItemId], isFixedLocationExist: self.isFixedLocationExist)
//                    }else{
//                        self.changeWorkLocationType(eSelectWorkLocation: "Fixed", dataStr: dataList[selectedItemId], isFixedLocationExist: self.isFixedLocationExist)
//                    }
//                }
            })
        }else if(sender == workRadiusTxtField){
            let openListView = OpenListView(uv: self, containerView: self.view)
            var dataList = [String]()
            
            for i in 0..<radiusSelectionListArr.count{
                dataList.append("\(radiusSelectionListArr[i].get("value")) \(radiusSelectionListArr[i].get("eUnit"))")
            }
            dataList.append("\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_OTHER_TXT"))")
            
            
            openListView.show(listObjects: dataList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RADIUS"), currentInst: openListView, handler: { (selectedItemId) in
                
                if((dataList.count - 1) == selectedItemId){
                    self.workRadiusTxtField.setText(text: dataList[selectedItemId])
                    
                    self.otherWorkRadiusCntViewHeight.constant = 130
                    self.otherWorkRadiusArea.isHidden = false
                    
                    /* Below line is just to call viewDiDlayoutSubview */
                    self.noteLbl.fitText()
                }else{
                    self.updateRadius(vWorkLocationRadius: self.radiusSelectionListArr[selectedItemId].get("value"))
                }
            })
        }
    }
    
    func locEditTapped(){
        openPlaceFinder(eSelectWorkLocation: self.eSelectWorkLocation, dataStr: self.generalFunc.getLanguageLabel(origValue: "", key: self.eSelectWorkLocation.uppercased() == "FIXED" ? "LBL_SPECIFIED_LOCATION" : "LBL_ANY_LOCATION"), isFixedLocationExist: self.isFixedLocationExist)
    }
    
    func openPlaceFinder(eSelectWorkLocation:String, dataStr:String, isFixedLocationExist:Bool){
        let launchPlaceFinder = LaunchPlaceFinder(viewControllerUV: self)
        launchPlaceFinder.currInst = launchPlaceFinder
        launchPlaceFinder.currentTransition =
            JTMaterialTransition(animatedView: self.editLocImgView, bgColor: UIColor.UCAColor.AppThemeColor.lighter(by: 35)!)
        
        if(currentLocation != nil){
            launchPlaceFinder.setBiasLocation(sourceLocationPlaceLatitude: currentLocation.coordinate.latitude, sourceLocationPlaceLongitude: currentLocation.coordinate.longitude)
        }
        
        launchPlaceFinder.initializeFinder { (address, latitude, longitude) in
            
            self.workLocAddr = address
            self.workLocLatitude = latitude
            self.workLocLongitude = longitude
            
            self.changeWorkLocationType(eSelectWorkLocation: eSelectWorkLocation, dataStr: dataStr, isFixedLocationExist: true)
            
        }
    }
    
    func updateRadius(vWorkLocationRadius:String){
         let parameters = ["type":"UpdateRadius","iDriverId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "vWorkLocationRadius": vWorkLocationRadius]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    GeneralFunctions.saveValue(key: "IS_WORK_LOCATION_CHANGED", value: "Yes" as AnyObject)
                    
                    self.otherWorkRadiusTxtField.setText(text: "")
                    self.otherWorkRadiusCntViewHeight.constant = 0
                    self.otherWorkRadiusArea.isHidden = true
                    
                    self.getData()
                    
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")))
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    func changeWorkLocationType(eSelectWorkLocation:String, dataStr:String, isFixedLocationExist:Bool){
        
        if(isFixedLocationExist == false){
           openPlaceFinder(eSelectWorkLocation: eSelectWorkLocation, dataStr: dataStr, isFixedLocationExist: isFixedLocationExist)
            return
        }
        
        var parameters = ["type":"UpdateDriverWorkLocationSelectionUFX","iDriverId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "eSelectWorkLocation": eSelectWorkLocation]
        
        if(eSelectWorkLocation.uppercased() == "FIXED" && self.workLocLatitude != 0.0 && self.workLocLongitude != 0.0){
            parameters["vWorkLocation"] = self.workLocAddr
            parameters["vWorkLocationLatitude"] = "\(self.workLocLatitude)"
            parameters["vWorkLocationLongitude"] = "\(self.workLocLongitude)"
        }
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                if(dataDict.get("Action") == "1"){
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    GeneralFunctions.saveValue(key: "IS_WORK_LOCATION_CHANGED", value: "Yes" as AnyObject)
                    
                    self.selectedWorkLocTypeTxtField.setText(text: dataStr)
                    
                    self.eSelectWorkLocation = eSelectWorkLocation
                    
                    if(eSelectWorkLocation.uppercased() == "FIXED"){
                        self.editLocImgViewWidth.constant = 25
                        self.editLocImgView.isHidden = false
                        self.isFixedLocationExist = true
                        
                        self.setWorkLoc(address: self.workLocAddr)
                        //        self.workLocLbl.fitText()
                        self.setWorkLocLblHeight()
                    }else{
                        self.editLocImgViewWidth.constant = 5
                        self.editLocImgView.isHidden = true
                        self.findAddressOfCurrentLoc()
                    }
                    
                    if(dataDict.get("message1") != ""){
                        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")))
                    }
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    func onLocationUpdate(location: CLLocation) {
       
        self.currentLocation = location
    }

}
