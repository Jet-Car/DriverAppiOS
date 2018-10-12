//
//  WayBillUV.swift
//  DriverApp
//
//  Created by ADMIN on 25/07/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class WayBillUV: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var driverNameLbl: MyLabel!
    
    @IBOutlet weak var tripView: UIView!
    @IBOutlet weak var tripViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tripLbl: MyLabel!
    @IBOutlet weak var tripNoLbl: MyLabel!
    @IBOutlet weak var tripNoVLbl: MyLabel!
    @IBOutlet weak var tripTimeLbl: MyLabel!
    @IBOutlet weak var tripTimeVLbl: MyLabel!
    @IBOutlet weak var tripRateLbl: MyLabel!
    @IBOutlet weak var tripRateVLbl: MyLabel!
    @IBOutlet weak var passengerNameLbl: MyLabel!
    @IBOutlet weak var passengerNameVLbl: MyLabel!
    @IBOutlet weak var viaLbl: MyLabel!
    @IBOutlet weak var viaVLbl: MyLabel!
    @IBOutlet weak var fromLocLbl: MyLabel!
    @IBOutlet weak var fromLocVLbl: MyLabel!
    @IBOutlet weak var toLocLbl: MyLabel!
    @IBOutlet weak var toLocVLbl: MyLabel!
    @IBOutlet weak var tripAreaBottomView: UIView!
    
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var driverViewHeight: NSLayoutConstraint!
    @IBOutlet weak var driverLbl: UILabel!
    @IBOutlet weak var driverNameHLbl: MyLabel!
    @IBOutlet weak var driverNameVLbl: MyLabel!
    @IBOutlet weak var carLicPlateLbl: MyLabel!
    @IBOutlet weak var carLicPlateVLbl: MyLabel!
    @IBOutlet weak var passengerCapLbl: MyLabel!
    @IBOutlet weak var passengerCapVLbl: MyLabel!
    @IBOutlet weak var driverAreaBottomView: UIView!
    
    @IBOutlet weak var recNameStackViewTop: NSLayoutConstraint!
    @IBOutlet weak var recnameVLbl: MyLabel!
    @IBOutlet weak var recnameHLbl: MyLabel!
    @IBOutlet weak var recnameStackView: UIStackView!
    @IBOutlet weak var pacDetailsHLbl: MyLabel!
    @IBOutlet weak var pacDetailsVLbl: MyLabel!
    @IBOutlet weak var pacNameHLbl: MyLabel!
    @IBOutlet weak var pacNameVLbl: MyLabel!
    
    @IBOutlet weak var packageDetailsStackView: UIStackView!
    @IBOutlet weak var packageNameStackView: UIStackView!
    var PAGE_HEIGHT:CGFloat = 500
    
    let generalFunc = GeneralFunctions()
    
    var cntView:UIView!
    var loaderView:UIView!
    
    var isFirstLaunch = true
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "WayBillScreenDesign", uv: self, contentView: contentView)
        
        self.scrollView.addSubview(cntView)
        self.scrollView.backgroundColor = UIColor(hex: 0xf2f2f4)
        
        scrollView.bounces = false
        scrollView.isHidden = true
        
        self.addBackBarBtn()
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isFirstLaunch == true){
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
            
            isFirstLaunch = false
            
            loadData()
        }
    }
    
    func setData(){
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Way Bill", key: "LBL_MENU_WAY_BILL")
        self.title = self.generalFunc.getLanguageLabel(origValue: "Way Bill", key: "LBL_MENU_WAY_BILL")
        
        self.tripLbl.text = ""
        self.tripNoLbl.text = ""
        self.tripTimeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIME_TXT")
        self.tripRateLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATE")
        self.passengerNameLbl.text = self.generalFunc.getLanguageLabel(origValue: "Passenger Name", key: "LBL_PASSENGER_NAME_TEXT")
        self.viaLbl.text = self.generalFunc.getLanguageLabel(origValue: "Via", key: "LBL_VIA_TXT")
        self.fromLocLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_From")
        self.toLocLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_To")
        
        self.driverLbl.text = self.generalFunc.getLanguageLabel(origValue: "Driver", key: "LBL_DIVER")
        self.driverNameHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Name", key: "LBL_NAME_TXT")
        self.carLicPlateLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LICENCE_PLATE_TXT") + "# "
        self.passengerCapLbl.text = ""
        
        self.recnameStackView.isHidden = true
        self.packageNameStackView.isHidden = true
        self.packageDetailsStackView.isHidden = true
    }
    
    func loadData(){
        scrollView.isHidden = true
        
        if(loaderView != nil){
            loaderView.removeFromSuperview()
        }
        
        loaderView =  self.generalFunc.addMDloader(contentView: self.contentView)
        loaderView.backgroundColor = UIColor.clear
        
        let parameters = ["type":"displayWayBill","UserType": Utils.appUserType, "iDriverId": GeneralFunctions.getMemberd()]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                print(dataDict)
                if(dataDict.get("Action") == "1"){
                    
                    let msgData = dataDict.getObj(Utils.message_str)
                    
                    if(msgData.get("eType") == Utils.cabGeneralType_Deliver){
                        self.tripLbl.text = self.generalFunc.getLanguageLabel(origValue: "Delivery", key: "LBL_DELIVERY")
                        self.tripNoLbl.text = self.generalFunc.getLanguageLabel(origValue: "Delivery", key: "LBL_DELIVERY") + "# "
                        self.driverLbl.text = self.generalFunc.getLanguageLabel(origValue: "Carrier", key: "LBL_CARRIER")
                    }else{
                        self.tripLbl.text = self.generalFunc.getLanguageLabel(origValue: "Trip", key: "LBL_TRIP_TXT")
                        self.tripNoLbl.text = self.generalFunc.getLanguageLabel(origValue: "Trip", key: "LBL_TRIP_TXT") + "# "
                        self.driverLbl.text = self.generalFunc.getLanguageLabel(origValue: "Driver", key: "LBL_DIVER")
                    }
                    
                    self.driverNameLbl.text = msgData.get("DriverName")
                    self.tripNoVLbl.text = Configurations.convertNumToAppLocal(numStr: msgData.get("vRideNo"))
                    self.tripTimeVLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: msgData.get("tTripRequestDate"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                    self.tripRateVLbl.text = Configurations.convertNumToAppLocal(numStr: msgData.get("Rate"))
                    
                    self.passengerNameVLbl.text = msgData.get("PassengerName")
                    self.viaVLbl.text = msgData.get("ProjectName")
                    self.fromLocVLbl.text = msgData.get("tSaddress")
                    self.toLocVLbl.text = msgData.get("tDaddress") == "" ? "--" : msgData.get("tDaddress")
                    
                    self.driverNameVLbl.text = msgData.get("DriverName")
                    self.carLicPlateVLbl.text =  msgData.get("eType") == Utils.cabGeneralType_UberX ? "--" : msgData.get("Licence_Plate")
                    
                    if (msgData.get("eType") == Utils.cabGeneralType_Deliver || msgData.get("eType") == Utils.cabGeneralType_UberX){
                        if(msgData.get("eType") == Utils.cabGeneralType_UberX){
                            self.recNameStackViewTop.constant = -20.5
                        }else{
                            self.passengerCapLbl.isHidden = true
                            self.passengerCapVLbl.isHidden = true
                        }
                     }else{
                        self.passengerCapLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PASSENGER_TXT") + " " + self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CAPACITY")
                        self.passengerCapVLbl.text = Configurations.convertNumToAppLocal(numStr: msgData.get("PassengerCapacity"))
                        
                        self.recNameStackViewTop.constant = -20.5
                        self.recnameStackView.isHidden = true
                    }
                    
                    if(msgData.get("eType") == Utils.cabGeneralType_Deliver)
                    {
                        self.packageNameStackView.isHidden = false
                        self.packageDetailsStackView.isHidden = false
                        self.recnameStackView.isHidden = false
                        
                        self.recnameHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_NAME")
                        self.recnameVLbl.text = msgData.get("vReceiverName")
                        self.pacNameHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_TYPE")
                        self.pacDetailsHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_DETAILS")
                        
                        self.passengerNameLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SENDER_NAME")
                        self.toLocLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_LOCATION")
                        
                        self.pacNameVLbl.text = msgData.get("PackageName")
                        self.pacDetailsVLbl.text = msgData.get("tPackageDetails")
                        
                    }
                    self.viaVLbl.fitText()
                    self.fromLocVLbl.fitText()
                    self.recnameVLbl.fitText()
                    self.toLocVLbl.fitText()
                    self.tripRateVLbl.fitText()
                    self.tripTimeVLbl.fitText()
                    self.pacNameVLbl.fitText()
                    self.pacDetailsVLbl.fitText()
                    
                    //                    self.carLicPlateVLbl.fitText()
                    
                    
                    
                    //                    print("BottomViewY1:\(self.tripAreaBottomView.frame.maxY)")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        //                        print("BottomViewY:\(self.tripAreaBottomView.frame.maxY)")
                        self.tripNoVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.tripTimeVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.tripRateVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.passengerNameVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.viaVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.fromLocVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        if msgData.get("eType") == Utils.cabGeneralType_Deliver
                        {
                          self.recnameVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        }
                        self.toLocVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.driverNameVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.passengerCapVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        self.carLicPlateVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                        
                        
                       
                        if msgData.get("eType") == Utils.cabGeneralType_Deliver
                        {
                            
                            self.pacNameVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                            self.pacDetailsVLbl.layer.addDashedBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 1.0)
                            self.tripViewHeight.constant = self.tripAreaBottomView.frame.maxY + 10
                        }
                        else
                        {
                            self.tripViewHeight.constant = self.tripAreaBottomView.frame.maxY + 10 - 60
                            
                        }
                        
                        self.driverViewHeight.constant = self.driverAreaBottomView.frame.maxY + 10
                        
                        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.tripViewHeight.constant + self.driverViewHeight.constant + 90)
                        
                        self.loaderView.isHidden = true
                        self.scrollView.isHidden = false
                        
                    })
                    
                    
                }else{
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                        
                        //                        self.loadData()
                        self.closeCurrentScreen()
                    })
                    
                    //                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                    
                    self.loaderView.isHidden = true
                }
                
            }else{
                //                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Please try again.", key: "LBL_TRY_AGAIN_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Retry", key: "LBL_RETRY_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                //
                //                    self.loadData()
                //                })
                
                //                self.generalFunc.setError(uv: self)
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: InternetConnection.isConnectedToNetwork() ? "Please try again later" : "No Internet Connection", key: InternetConnection.isConnectedToNetwork() ? "LBL_TRY_AGAIN_TXT" : "LBL_NO_INTERNET_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                    //                        self.loadData()
                    self.closeCurrentScreen()
                })
                
                self.loaderView.isHidden = true
            }
            
        })
    }
}
