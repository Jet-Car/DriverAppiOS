//
//  RideDetailUV.swift
//  PassengerApp
//
//  Created by ADMIN on 06/06/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps
import SafariServices

class RideDetailUV: UIViewController, OnDirectionUpdateDelegate {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userHeaderView: UIView!
    @IBOutlet weak var userHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userPicBgView: UIView!
    @IBOutlet weak var userPicBgImgView: UIImageView!
    @IBOutlet weak var userPicImgView: UIImageView!
    @IBOutlet weak var userNameHLbl: MyLabel!
    @IBOutlet weak var userNameVLbl: MyLabel!
    @IBOutlet weak var ratingHLbl: MyLabel!
    @IBOutlet weak var ratingBar: RatingView!
    @IBOutlet weak var thanksHLbl: MyLabel!
    @IBOutlet weak var rideNoLbl: MyLabel!
    @IBOutlet weak var tripReqDateHLbl: MyLabel!
    @IBOutlet weak var tripReqDateVLbl: MyLabel!
    @IBOutlet weak var pickUpLocHLbl: MyLabel!
    @IBOutlet weak var pickUpLocVLbl: MyLabel!
    @IBOutlet weak var destLocHLbl: MyLabel!
    @IBOutlet weak var destLocVLbl: MyLabel!
    @IBOutlet weak var gMapView: GMSMapView!
    @IBOutlet weak var chargesParentView: UIView!
    @IBOutlet weak var chargesHLbl: MyLabel!
    @IBOutlet weak var vehicleTypeLbl: MyLabel!
    @IBOutlet weak var chargesContainerView: UIStackView!
    @IBOutlet weak var chargesContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chargesParentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var payImgView: UIImageView!
    @IBOutlet weak var paymentTypeLbl: MyLabel!
    @IBOutlet weak var tripStatusLbl: MyLabel!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tipInfoLbl: MyLabel!
    @IBOutlet weak var tipHLbl: MyLabel!
    @IBOutlet weak var tipAmountLbl: MyLabel!
    @IBOutlet weak var tipTopPlusLbl: MyLabel!
    @IBOutlet weak var tipViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var serviceAreaCenterViewOffset: NSLayoutConstraint!
    @IBOutlet weak var serviceImageAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceImageAreaView: UIView!
    @IBOutlet weak var beforeServiceImgArea: UIView!
    @IBOutlet weak var afterServiceImgArea: UIView!
    @IBOutlet weak var beforeServiceImgView: UIImageView!
    @IBOutlet weak var beforeServiceLbl: MyLabel!
    @IBOutlet weak var afterServiceImgView: UIImageView!
    @IBOutlet weak var afterServiceLbl: MyLabel!
    @IBOutlet weak var mapTopMargin: NSLayoutConstraint!
    
    var tripDetailDict:NSDictionary!
    
    let generalFunc = GeneralFunctions()
    
    var isPageLoaded = false
    
    var cntView:UIView!
    var PAGE_HEIGHT:CGFloat = 735
    
    var CHARGES_PARENT_VIEW_OFFSET_HEIGHT:CGFloat = 55

    var updateDirection:UpdateDirections!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        cntView = self.generalFunc.loadView(nibName: "RideDetailScreenDesign", uv: self, contentView: scrollView)
        
        self.scrollView.addSubview(cntView)
        //        self.contentView.addSubview(scrollView)
        
        self.addBackBarBtn()
        
        self.userNameHLbl.setCustomBGColor(color: UIColor.clear)
        self.userNameHLbl.setCustomTextColor(color: UIColor.UCAColor.tripDetailHeaderBarHTxtColor)
        
        self.ratingHLbl.setCustomBGColor(color: UIColor.clear)
        self.ratingHLbl.setCustomTextColor(color: UIColor.UCAColor.tripDetailHeaderBarHTxtColor)
        
        self.ratingBar.fullStarColor = UIColor.UCAColor.tripDetailUserRatingFillColor
        
        scrollView.bounces = false
        scrollView.backgroundColor = UIColor(hex: 0xF2F2F4)
        cntView.frame.size = CGSize(width: cntView.frame.width, height: self.PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blurEffectView.frame = userPicBgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.userPicBgView.addSubview(blurEffectView)
        

        setData()
    }
    
    func setData(){
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIPT_HEADER_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIPT_HEADER_TXT")
        
        let passengerDetails = self.tripDetailDict.getObj("PassengerDetails")
        self.userNameVLbl.text = passengerDetails.get("vName").uppercased() + " " + passengerDetails.get("vLastName").uppercased()

//        self.tripReqDateVLbl.text = self.tripDetailDict.get("tTripRequestDate")
        self.tripReqDateVLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: self.tripDetailDict.get("tTripRequestDateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
        
        self.userNameHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_USER" : (self.tripDetailDict.get("eType").uppercased() == Utils.cabGeneralType_Deliver.uppercased() ? "LBL_SENDER" : "LBL_PASSENGER_TXT") ).uppercased()
        self.ratingHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATING").uppercased()
        
        self.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_SENDER_LOCATION" : (self.tripDetailDict.get("eType").uppercased() == Utils.cabGeneralType_Ride.uppercased() ? "LBL_PICKUP_LOCATION_HEADER_TXT" : "LBL_JOB_LOCATION_TXT")).uppercased()
        
        self.destLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_DELIVERY_DETAILS_TXT" : "LBL_DEST_LOCATION").uppercased()
        
//        self.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PICKUP_LOCATION_HEADER_TXT").uppercased()
//        self.destLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DROP_OFF_LOCATION_TXT").uppercased()
        
        
        self.tripReqDateHLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "DELIVERY REQUEST DATE" : "", key:  self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_DELIVERY_REQUEST_DATE" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_JOB_REQ_DATE" : "LBL_TRIP_REQUEST_DATE_TXT")).uppercased()
        
        self.chargesHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CHARGES_TXT").uppercased()
        
        self.thanksHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_THANKS_DELIVERY_DRIVER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_THANKS_UFX_DRIVER" : "LBL_THANKS_RIDING_DRIVER")).uppercased()
        self.thanksHLbl.fitText()
        
        self.rideNoLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Ride ? "LBL_RIDE" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_SERVICES" : "LBL_DELIVERY")).uppercased() + "# " + Configurations.convertNumToAppLocal(numStr: self.tripDetailDict.get("vRideNo"))
        
        self.pickUpLocVLbl.text = self.tripDetailDict.get("tSaddress")
//        self.destLocVLbl.text = self.tripDetailDict.get("tDaddress") == "" ? "----" :  self.tripDetailDict.get("tDaddress")
        
        if(self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver){
            self.destLocVLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_NAME")): \(self.tripDetailDict.get("vReceiverName"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_LOCATION")): \(self.tripDetailDict.get("tDaddress"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_TYPE_TXT")): \(self.tripDetailDict.get("PackageType"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_DETAILS")): \(self.tripDetailDict.get("tPackageDetails"))"
        }else{
            self.destLocVLbl.text = self.tripDetailDict.get("tDaddress") == "" ? "----" :  self.tripDetailDict.get("tDaddress")
        }
        
        self.pickUpLocVLbl.fitText()
        self.destLocVLbl.fitText()
        
        if(self.tripDetailDict.get("vTripPaymentMode") == "Cash"){
            self.paymentTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CASH_PAYMENT_TXT")
            self.payImgView.image = UIImage(named: "ic_cash_new")!
        }else{
            self.paymentTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CARD_PAYMENT")
            self.payImgView.image = UIImage(named: "ic_card_new")!
        }
        
        self.ratingBar.rating = GeneralFunctions.parseFloat(origValue: 0.0, data: self.tripDetailDict.get("TripRating"))

        
        userPicBgImgView.sd_setImage(with: URL(string: CommonUtils.passenger_image_url + "\(tripDetailDict.get("iUserId"))/\(passengerDetails.get("vImgName"))"), placeholderImage: UIImage(named: "ic_no_pic_user"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
        })
        
        
        userPicImgView.sd_setImage(with: URL(string: CommonUtils.passenger_image_url + "\(tripDetailDict.get("iUserId"))/\(passengerDetails.get("vImgName"))"), placeholderImage: UIImage(named: "ic_no_pic_user"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
        })
        
        Utils.createRoundedView(view: userPicImgView, borderColor: UIColor.clear, borderWidth: 0)
        

        if(tripDetailDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased()){
            self.vehicleTypeLbl.text = "\(tripDetailDict.get("vVehicleCategory"))-\(tripDetailDict.get("vVehicleType"))"
        }else{
            self.vehicleTypeLbl.text = tripDetailDict.get("carTypeName")
        }
        
        let vTypeNameHeight = self.vehicleTypeLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 56, font: UIFont(name: "Roboto-Light", size: 20)!) - 24
        
        self.CHARGES_PARENT_VIEW_OFFSET_HEIGHT = self.CHARGES_PARENT_VIEW_OFFSET_HEIGHT + vTypeNameHeight
        
//        self.vehicleTypeLbl.text = "\(self.tripDetailDict.get("vVehicleCategory"))-\(self.tripDetailDict.get("vVehicleType"))"
        self.vehicleTypeLbl.textAlignment = .center
//        self.vehicleTypeLbl.text = self.tripDetailDict.get("carTypeName")
        
        let tripStatus = tripDetailDict.get("iActive")
        
        if(tripStatus == "Canceled"){
            
            if(tripDetailDict.get("eCancelledBy").uppercased() == "DRIVER"){
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_CANCELED_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELED_JOB" : "LBL_CANCELED_TRIP_TXT"))
            }else{
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_SENDER_CANCEL_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_USER_CANCEL_JOB_TXT" : "LBL_PASSENGER_CANCEL_TRIP_TXT"))
            }
        }else if(tripStatus == "Finished"){
            self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_FINISHED_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_FINISHED_JOB_TXT" : "LBL_FINISHED_TRIP_TXT"))
            
            if(tripDetailDict.get("tEndLat") != "" && tripDetailDict.get("tEndLong") != "" && (self.tripDetailDict.get("eType") != Utils.cabGeneralType_UberX || self.tripDetailDict.get("eFareType") == "Regular")){
                drawRoute()
            }
        }else{
            self.tripStatusLbl.text = tripStatus
        }
        
        if(tripDetailDict.get("eCancelled") == "Yes"){
            
            if(tripDetailDict.get("eCancelledBy").uppercased() == "DRIVER"){
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_PREFIX_DELIVERY_CANCEL_YOU" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_PREFIX_JOB_CANCEL_YOU" : "LBL_PREFIX_TRIP_CANCEL_YOU")) + " " + tripDetailDict.get("vCancelReason")
            }else{
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_SENDER_CANCEL_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_USER_CANCEL_JOB_TXT" : "LBL_PASSENGER_CANCEL_TRIP_TXT"))
            }
        }
        self.tripStatusLbl.fitText()
        
        GeneralFunctions.setImgTintColor(imgView: self.payImgView, color: UIColor.UCAColor.AppThemeColor)
        self.tripStatusLbl.backgroundColor = UIColor.UCAColor.AppThemeColor_1
        self.tripStatusLbl.textColor = UIColor.UCAColor.AppThemeTxtColor_1
        self.tripStatusLbl.setPadding(paddingTop: 20, paddingBottom: 20, paddingLeft: 10, paddingRight: 10)
        
        Utils.createRoundedView(view: self.tripStatusLbl, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 5)
        Utils.createRoundedView(view: self.chargesParentView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        Utils.createRoundedView(view: self.tipView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        var bounds = GMSCoordinateBounds()
        
        let sourceMarker = GMSMarker()
        sourceMarker.position = (CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLong")))).coordinate
        sourceMarker.icon = UIImage(named: "ic_source_marker")!

        sourceMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        sourceMarker.map = self.gMapView
        
        bounds = bounds.includingCoordinate(sourceMarker.position)
        
        if(tripDetailDict.get("tEndLat") != ""){
            let destMarker = GMSMarker()
            destMarker.position = (CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLong")))).coordinate
            destMarker.icon = UIImage(named: "ic_destination_place_image")!

            destMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            destMarker.map = self.gMapView
            
            bounds = bounds.includingCoordinate(destMarker.position)
        }
        
        if(self.tripDetailDict.get("eHailTrip") == "Yes"){
            self.userHeaderView.isHidden = true
            userHeaderViewHeight.constant = 0
            self.PAGE_HEIGHT = self.PAGE_HEIGHT - 145
        }
        
        if(self.tripDetailDict.get("fTipPrice") != "" && self.tripDetailDict.get("fTipPrice") != "0" && self.tripDetailDict.get("fTipPrice") != "0.00"){
//            self.PAGE_HEIGHT = 1100
            self.PAGE_HEIGHT = self.PAGE_HEIGHT + 130
            self.tipAmountLbl.text = Configurations.convertNumToAppLocal(numStr: self.tripDetailDict.get("fTipPrice"))
            self.tipInfoLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_TIP_INFO_SHOW_CARRIER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_TIP_INFO_SHOW_PROVIDER" : "LBL_TIP_INFO_SHOW_DRIVER"))
            
            
            self.tipHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIP_AMOUNT")
            self.tipViewHeight.constant = self.tipViewHeight.constant + (self.tipInfoLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: "Roboto-Light", size: 16)!) - 20)
            self.tipInfoLbl.fitText()
            
            self.tipTopPlusLbl.text = "+"
        }else{
            self.tipView.isHidden = true
            self.tipViewHeight.constant = 0
            self.tipViewTopMargin.constant = 0
            
            self.tipTopPlusLbl.text = ""
            self.tipTopPlusLbl.fitText()
        }
        
        
        if(self.tripDetailDict.get("vBeforeImage") != "" || self.tripDetailDict.get("vAfterImage") != "" ){
            self.PAGE_HEIGHT = self.PAGE_HEIGHT + 115
            self.serviceImageAreaView.isHidden = false
            self.beforeServiceLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BEFORE_SERVICE")
            self.afterServiceLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_AFTER_SERVICE")
            
            beforeServiceImgView.sd_setImage(with: URL(string: self.tripDetailDict.get("vBeforeImage")), placeholderImage: UIImage(named: ""),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
            })
            
            afterServiceImgView.sd_setImage(with: URL(string: self.tripDetailDict.get("vAfterImage")), placeholderImage: UIImage(named: ""),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
            })
            
            if(self.tripDetailDict.get("vBeforeImage") == ""){
                self.beforeServiceImgArea.isHidden = true
                self.serviceAreaCenterViewOffset.constant = -60
            }
            
            if(self.tripDetailDict.get("vAfterImage") == ""){
                self.afterServiceImgArea.isHidden = true
                self.serviceAreaCenterViewOffset.constant = 60
            }
            
            let beforeTapGue = UITapGestureRecognizer()
            let afterTapGue = UITapGestureRecognizer()
            
            beforeTapGue.addTarget(self, action: #selector(self.openBeforeImage))
            afterTapGue.addTarget(self, action: #selector(self.openAfterImage))
            
            self.beforeServiceImgArea.isUserInteractionEnabled = true
            self.beforeServiceImgArea.addGestureRecognizer(beforeTapGue)
            
            self.afterServiceImgArea.isUserInteractionEnabled = true
            self.afterServiceImgArea.addGestureRecognizer(afterTapGue)
            
        }else{
            self.serviceImageAreaHeight.constant = 0
            self.serviceImageAreaView.isHidden = true
        }
        
//        if(userProfileJson.get("APP_DESTINATION_MODE").uppercased() == "NONE"){
//            self.destLocHLbl.isHidden = true
//            mapTopMargin.constant = -70
//            self.destLocVLbl.isHidden = true
//        }

        if(self.tripDetailDict.get("tDaddress") == ""){
            self.destLocHLbl.isHidden = true
            mapTopMargin.constant = -70
            self.destLocVLbl.isHidden = true
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        gMapView.animate(with: update)
        
        self.addFareDetails()
    }
    
    
    func openBeforeImage(){
        let url = URL(string: self.tripDetailDict.get("vBeforeImage"))!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)

    }
    
    func openAfterImage(){
        let url = URL(string: self.tripDetailDict.get("vAfterImage"))!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    func addFareDetails(){
        
        let HistoryFareDetailsNewArr = self.tripDetailDict.getObj(Utils.message_str).getArrObj("HistoryFareDetailsNewArr")
        
        var currentYposition:CGFloat = 0
        var currentPosition = 0
        
        for i in 0..<HistoryFareDetailsNewArr.count {
            
            let dict_temp = HistoryFareDetailsNewArr[i] as! NSDictionary
            
            for (key, value) in dict_temp {
                
                let viewWidth = Application.screenSize.width - 36
                
                let viewCus = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 40))
                
                
                let titleStr = Configurations.convertNumToAppLocal(numStr: key as! String)
                let valueStr = Configurations.convertNumToAppLocal(numStr: value as! String)

                let font = UIFont(name: "Roboto-Light", size: 16)!
                var widthOfTitle = titleStr.width(withConstrainedHeight: 40, font: font) + 15
                var widthOfvalue = valueStr.width(withConstrainedHeight: 40, font: font) + 15
                
                if(widthOfTitle > ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100)){
                    widthOfvalue = ((viewWidth * 80) / 100)
                    widthOfTitle = ((viewWidth * 20) / 100)
                }else if(widthOfTitle < ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100) && (viewWidth - widthOfTitle - widthOfvalue) < 0){
                   widthOfvalue = viewWidth - widthOfTitle
                }
               
                let widthOfParentView = viewWidth - widthOfvalue
                
                var lblTitle = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfParentView - 5, height: 40))
                var lblValue = MyLabel(frame: CGRect(x: widthOfParentView, y: 0, width: widthOfvalue, height: 40))
                
                if(Configurations.isRTLMode()){
                    lblTitle = MyLabel(frame: CGRect(x: widthOfvalue + 5, y: 0, width: widthOfParentView, height: 40))
                    lblValue = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfvalue, height: 40))
                    
                    lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                    lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                }else{
                    lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                    lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                }
                
                lblTitle.textColor = UIColor(hex: 0x272727)
                lblValue.textColor = UIColor(hex: 0x272727)
                
                lblTitle.font = font
                lblValue.font = font
                
                lblTitle.numberOfLines = 2
                lblValue.numberOfLines = 2
                
                lblTitle.minimumScaleFactor = 0.5
                lblValue.minimumScaleFactor = 0.5
                
                lblTitle.text = titleStr
                lblValue.text = valueStr
                
                viewCus.addSubview(lblTitle)
                viewCus.addSubview(lblValue)
                
                self.chargesContainerView.addArrangedSubview(viewCus)
                
                self.chargesContainerViewHeight.constant = self.chargesContainerViewHeight.constant + 40
                
                currentYposition = currentYposition + 40
                currentPosition = currentPosition + 1
                
                if(Configurations.isRTLMode()){
                    lblValue.textAlignment = .left
                }else{
                    lblValue.textAlignment = .right
                }
            }
        }
        if(HistoryFareDetailsNewArr.count > 0){
            self.chargesContainerView.subviews[HistoryFareDetailsNewArr.count - 1].backgroundColor = UIColor(hex: 0xe3e3e3)
            (self.chargesContainerView.subviews[HistoryFareDetailsNewArr.count - 1].subviews[0] as! MyLabel).textColor = UIColor(hex: 0x000000)
            (self.chargesContainerView.subviews[HistoryFareDetailsNewArr.count - 1].subviews[1] as! MyLabel).textColor = UIColor.UCAColor.AppThemeColor
        }
        
        self.chargesContainerViewHeight.constant = self.chargesContainerViewHeight.constant - 45
        
        self.chargesParentViewHeight.constant = self.chargesContainerViewHeight.constant + CHARGES_PARENT_VIEW_OFFSET_HEIGHT
        
        
        self.chargesContainerView.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            //            self.cntView.frame.size = CGSize(width: self.contentView.frame.width, height: (defaultContentSize > displayHeight ? defaultContentSize : displayHeight))
            //
            //            self.scrollView.setContentViewSize()
            
            self.cntView.frame.size = CGSize(width: self.contentView.frame.width, height: self.tripStatusLbl.frame.maxY + 20)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.tripStatusLbl.frame.maxY + 20)
        })
        
    }
    
    func drawRoute(){
        let fromLocation = CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLong")))
        let toLocation = CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLong")))
        
        updateDirection = UpdateDirections(uv: self, gMap: self.gMapView, fromLocation: fromLocation, destinationLocation: toLocation, isCurrentLocationEnabled: false)
        updateDirection.onDirectionUpdateDelegate = self
        updateDirection.setCurrentLocEnabled(isCurrentLocationEnabled: false)
        updateDirection.scheduleDirectionUpdate(eTollSkipped: tripDetailDict.get("eTollSkipped"))
    }
    
    func onDirectionUpdate(directionResultDict: NSDictionary) {
        if(updateDirection != nil){
            updateDirection.releaseTask()
            updateDirection.onDirectionUpdateDelegate = nil
            updateDirection = nil
        }
    }
}
