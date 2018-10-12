//
//  TaxiHailUV.swift
//  DriverApp
//
//  Created by ADMIN on 25/07/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class TaxiHailUV: UIViewController, OnLocationUpdateDelegate, AddressFoundDelegate, GMSMapViewDelegate, MyBtnClickDelegate, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gMapContainerView: UIView!
    @IBOutlet weak var destView: UIView!
    @IBOutlet weak var destLbl: MyLabel!
    @IBOutlet weak var destHLbl: MyLabel!
    @IBOutlet weak var destPointView: UIView!
    @IBOutlet weak var progressBarContainerView: UIView!
    @IBOutlet weak var destPinImgview: UIImageView!
    
     //Request PickUp BottomView OutLets
    @IBOutlet weak var cabTypeCollectionView: UICollectionView!
    @IBOutlet weak var noCabTypeLbl: MyLabel!
    @IBOutlet weak var bookNowBtn: MyButton!
    @IBOutlet weak var payImgView: UIImageView!
    @IBOutlet weak var payLbl: MyLabel!
    @IBOutlet weak var topCabTypeCollectionView: NSLayoutConstraint!
    @IBOutlet weak var categoryContainerView: UIView!
    @IBOutlet weak var rentalOptionImgView: UIImageView!
    @IBOutlet weak var rentalBackImgView: UIImageView!
    @IBOutlet weak var rentalInfoLbl: MyLabel!
    @IBOutlet weak var rentalLbl: MyLabel!
    @IBOutlet weak var vwRentalTap: UIView!
    
    // Surge Price OutLets
    @IBOutlet weak var surgePriceHLbl: MyLabel!
    @IBOutlet weak var surgePriceVLbl: MyLabel!
    @IBOutlet weak var surgePayAmtLbl: MyLabel!
    @IBOutlet weak var surgeAcceptBtn: MyButton!
    @IBOutlet weak var surgeLaterLbl: MyLabel!
    
    var vVehicleDefaultImgPath = CommonUtils.webServer + "webimages/icons/DefaultImg/"
    var vVehicleImgPath = CommonUtils.webServer + "webimages/icons/VehicleType/"
    
    var getAddressFrmLocation:GetAddressFromLocation!
    
    var isDataSet = false
    
    var getLocation:GetLocation!
    var gMapView:GMSMapView!
    
    var destLocation:CLLocation!
    var pickUpLocation:CLLocation!
    
    var pickUpAddress = ""
    
    var isFirstLocationUpdate = true
    
    var generalFunc = GeneralFunctions()
    
    var requestPickUpView:UIView!
    
    var isCashPayment = true
    
    var cabTypesArr = [NSDictionary]()
    
    var selectedCabTypeId = ""
    
//    var carTypeResponse:NSDictionary!
    
    let linearProgressBar = LinearProgressBarView()
    
    var isSkipAddressFind = false
    
    var isTollChecked = false
    var isSurgePriceChecked = false
    
    var currTollPrice = ""
    var currTollPriceCurrencyCode = ""
    var currTollSkipped = ""
    
    var userProfileJson:NSDictionary!
    
    var surgePriceView:UIView!
    var surgePriceBGView:UIView!
    
    var selectedCabTypeIdIndex = 0
    
    var fareDetailView:FareDetailView!
    var fareDetailBGView:UIView!
    
    var isRouteDrawnFailed = false
    
    var eFlatTrip = false
    
    var selectedCabCategoryType = ""
    var listOfLoadedCategories = [NSMutableDictionary]()
    var selectedCabTypeName = ""
    var selectedCabTypeLogo = ""
    var selectedRentalPackageTypeId = ""
    var isRentalPackageSelected = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.addSubview(self.generalFunc.loadView(nibName: "TaxiHailScreenDesign", uv: self, contentView: contentView))
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)

        
        getAddressFrmLocation = GetAddressFromLocation(uv: self, addressFoundDelegate: self)
        
        self.addBackBarBtn()
        
        setData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.releaseAllTask), name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
        
        if(self.userProfileJson.get("ENABLE_TOLL_COST").uppercased() != "YES"){
            self.isTollChecked = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isDataSet == false){
            let camera = GMSCameraPosition.camera(withLatitude: -180, longitude: -180, zoom: Utils.defaultZoomLevel)
            gMapView = GMSMapView.map(withFrame: self.gMapContainerView.frame, camera: camera)
            
            gMapView.isMyLocationEnabled = true
            gMapView.delegate = self
            self.gMapContainerView.addSubview(gMapView)
            
            
            linearProgressBar.heightForLinearBar = 5
            linearProgressBar.backgroundColor = UIColor.clear
            linearProgressBar.backgroundProgressBarColor = self.progressBarContainerView.backgroundColor != nil ? self.progressBarContainerView.backgroundColor! : UIColor.clear
            linearProgressBar.progressBarColor = UIColor.UCAColor.AppThemeColor_1
            
            self.progressBarContainerView.addSubview(linearProgressBar)
            
            linearProgressBar.startAnimation()
            
            getLocation = GetLocation(uv: self, isContinuous: false)
            getLocation.buildLocManager(locationUpdateDelegate: self)
            
            isDataSet = true
            
            
        }
    }
    
    override func closeCurrentScreen() {
        
//        if(self.requestPickUpView != nil){
//            self.requestPickUpView.removeFromSuperview()
//            self.destPinImgview.isHidden = true
//            self.destLocation = nil
//            self.destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_DESTINATION_BTN_TXT")
//            self.requestPickUpView = nil
//            return
//        }
        
        releaseAllTask()
        super.closeCurrentScreen()
    }

    func setData(){
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Taxi Hail", key: "LBL_TAXI_HAIL")
        self.title = self.generalFunc.getLanguageLabel(origValue: "Taxi Hail", key: "LBL_TAXI_HAIL")
        
        destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_DESTINATION_BTN_TXT")
        destHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Drop at", key: "LBL_DROP_AT")
    }
    
    deinit {
        releaseAllTask()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = nil
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if(destPinImgview.isHidden == true){
            return
        }
        if(isSkipAddressFind == true){
            isSkipAddressFind = false
            return
        }
        self.destLocation = nil
        self.destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECTING_LOCATION_TXT")
        
        if(bookNowBtn != nil){
            bookNowBtn.setButtonEnabled(isBtnEnabled: false)
        }
        
        getAddressFrmLocation.setLocation(latitude: getCenterLocation().coordinate.latitude, longitude: getCenterLocation().coordinate.longitude)
        getAddressFrmLocation.setPickUpMode(isPickUpMode: false)
        getAddressFrmLocation.executeProcess(isOpenLoader: false, isAlertShow:false)
    }
    
    
    func getCenterLocation() -> CLLocation{
        return CLLocation(latitude: self.gMapView.camera.target.latitude, longitude: self.gMapView.camera.target.longitude)
    }
    
    
    func releaseAllTask(){
        if(self.linearProgressBar != nil){
            self.linearProgressBar.stopAnimation()
        }
        if(gMapView != nil){
            gMapView!.stopRendering()
            gMapView!.removeFromSuperview()
            gMapView!.clear()
            gMapView!.delegate = nil
            gMapView = nil
        }
        
        if(self.getLocation != nil){
            self.getLocation!.locationUpdateDelegate = nil
            self.getLocation!.releaseLocationTask()
            self.getLocation = nil
        }
        
        GeneralFunctions.removeObserver(obj: self)
        
    }
    
    func onLocationUpdate(location: CLLocation) {
        self.pickUpLocation = location
        
        
        var currentZoomLevel:Float = self.gMapView.camera.zoom
        
        if(currentZoomLevel < Utils.defaultZoomLevel && isFirstLocationUpdate == true){
            currentZoomLevel = Utils.defaultZoomLevel
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude, zoom: currentZoomLevel)
        
        self.gMapView.animate(to: camera)
        
        
        if(isFirstLocationUpdate == true){
            getAddressFrmLocation.setLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            getAddressFrmLocation.setPickUpMode(isPickUpMode: true)
            getAddressFrmLocation.executeProcess(isOpenLoader: false, isAlertShow:false)
        }
        
        
        isFirstLocationUpdate = false
    }
    
    var tempDestLocation:CLLocation!
    
    func onAddressFound(address: String, location: CLLocation, isPickUpMode:Bool, dataResult:String) {
        if(isPickUpMode == true){
            self.pickUpAddress = address
            
            if(self.progressBarContainerView.isHidden == false){
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.progressBarContainerView.isHidden = true
                    if(self.linearProgressBar != nil){
                        self.linearProgressBar.stopAnimation()
                    }
                })
            }
            
            
            let destTapGue = UITapGestureRecognizer()
            destTapGue.addTarget(self, action: #selector(self.openPlaceFinder))
            destView.isUserInteractionEnabled = true
            
            destView.addGestureRecognizer(destTapGue)
        }else{
            if(bookNowBtn != nil){
                bookNowBtn.setButtonEnabled(isBtnEnabled: true)
            }
            self.destLocation = location
            self.destLbl.text = address
            
            if(tempDestLocation != nil && tempDestLocation.distance(from: location) > 100){
                tempDestLocation = location
                
                self.getDirectionData()
            }else if(tempDestLocation == nil){
                
                tempDestLocation = location
            }
        }
        
    }
    
    func openPlaceFinder(){
        let launchPlaceFinder = LaunchPlaceFinder(viewControllerUV: self)
        launchPlaceFinder.currInst = launchPlaceFinder
        launchPlaceFinder.currentTransition =
            JTMaterialTransition(animatedView: self.destPointView, bgColor: UIColor.UCAColor.AppThemeColor.lighter(by: 35)!)
        
        
        launchPlaceFinder.setBiasLocation(sourceLocationPlaceLatitude: (destLocation == nil ? pickUpLocation : destLocation).coordinate.latitude, sourceLocationPlaceLongitude: (destLocation == nil ? pickUpLocation : destLocation).coordinate.longitude)
        
        
        launchPlaceFinder.initializeFinder { (address, latitude, longitude) in
            
            self.destLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            self.destLbl.text = address
            
            let camera = GMSCameraPosition.camera(withLatitude: self.destLocation.coordinate.latitude,
                                                  longitude: self.destLocation.coordinate.longitude, zoom: self.gMapView.camera.zoom)
            
            if(self.requestPickUpView != nil){
                self.isSkipAddressFind = true
            }
            
            self.gMapView.moveCamera(GMSCameraUpdate.setCamera(camera))
            
            self.getDirectionData()
            
        }
    }
    
    
    func openRequestPickUpView(){
        self.destPinImgview.isHidden = false
        
        requestPickUpView = self.generalFunc.loadView(nibName: "RequestPickUpBottomView", uv: self, isWithOutSize: true)
        
        
        var height:CGFloat = 277 + GeneralFunctions.getSafeAreaInsets().bottom
        
        if listOfLoadedCategories.count <= 1{
            height = height - 30
        }
        
        requestPickUpView.frame = CGRect(x: 0, y: self.view.frame.size.height + height, width: Application.screenSize.width, height: height)
        
        self.contentView.addSubview(requestPickUpView)
        
        UIView.animate(withDuration: 0.8,
                       animations: {
                        //                        self.requestPickUpView.center = CGPoint(x: 0, y: 310)
                        self.requestPickUpView.frame.origin.y = self.contentView.frame.size.height - height
                        self.contentView.layoutIfNeeded()
        },  completion: { finished in
            
        })
        
        self.noCabTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "No aervice available in your selected pickup location.", key: "LBL_NO_SERVICE_AVAILABLE_TXT")
        self.noCabTypeLbl.fitText()
        self.noCabTypeLbl.isHidden = true
        
        if(self.cabTypesArr.count < 1){
            self.noCabTypeLbl.isHidden = false
            bookNowBtn.setButtonEnabled(isBtnEnabled: false)
        }
        
        self.payLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CASH_TXT")
        self.payImgView.image = UIImage(named: "ic_cash_new")
        
        self.bookNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_START_TRIP"))
        
        

//        self.cabTypeCollectionView.reloadData()
        
        if listOfLoadedCategories.count <= 1 {
            self.categoryContainerView.isHidden = true
            self.topCabTypeCollectionView.constant = 5
        }else{
            self.categoryContainerView.isHidden = false
            self.topCabTypeCollectionView.constant = 30
            
            if(Configurations.isRTLMode()){
                self.rentalOptionImgView.transform  = CGAffineTransform(rotationAngle: 180 * CGFloat(CGFloat.pi/180)).concatenating(CGAffineTransform(scaleX: 1, y: -1))
                
                self.rentalBackImgView.transform = CGAffineTransform(rotationAngle: 180 * CGFloat(CGFloat.pi/180))
            }
            
            let rentalOptionTapGue = UITapGestureRecognizer()
            rentalOptionTapGue.addTarget(self, action: #selector(self.rentalOptionTapped))
            self.vwRentalTap.addGestureRecognizer(rentalOptionTapGue)
            self.vwRentalTap.isUserInteractionEnabled = true
            
            self.rentalInfoLbl.isHidden = true
            self.rentalBackImgView.isHidden = true
            
            self.rentalInfoLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENT_PKG_INFO")
            self.rentalInfoLbl.fitText()
            
            self.rentalLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENT_CAR_TITLE_TXT").uppercased()
            self.rentalLbl.fitText()
            self.rentalLbl.backgroundColor = UIColor.UCAColor.blackColor
            self.rentalLbl.textColor = UIColor.UCAColor.AppThemeTxtColor
            
            let rentalBackTapGue = UITapGestureRecognizer()
            rentalBackTapGue.addTarget(self, action: #selector(self.rentalBackImgTapped))
            rentalBackImgView.isUserInteractionEnabled = true
            rentalBackImgView.addGestureRecognizer(rentalBackTapGue)
            GeneralFunctions.setImgTintColor(imgView: rentalBackImgView, color: UIColor.UCAColor.AppThemeColor)
        }
        
        self.cabTypeCollectionView.register(UINib(nibName: "CabTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "CabTypeCVCell")
        self.cabTypeCollectionView.dataSource = self
        self.cabTypeCollectionView.delegate = self
        self.cabTypeCollectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.cabTypeCollectionView.bounces = false
        
        self.bookNowBtn.clickDelegate = self
        
//        self.bookNowBtn.setButtonEnabled(isBtnEnabled: false)
//        self.bookNowBtn.setButtonTitleColor(color: UIColor(hex: 0x6b6b6b))
        
    }
    
    func rentalBackImgTapped(){
        self.selectedCabCategoryType = Utils.dailyRideCategoryType
       
        //update array as per category selection
        self.cabTypesArr = self.listOfLoadedCategories[0].getArrObj("CabTypes") as! [NSDictionary]
        
        //set first cab type value as default when new category selected
        selectedCabTypeIdIndex = 0
        self.selectedCabTypeId = self.cabTypesArr[0].get("iVehicleTypeId")
        self.selectedCabTypeLogo = self.cabTypesArr[0].get("vLogo")
        self.selectedCabTypeName = self.cabTypesArr[0].get("vVehicleTypeName")
       
        self.cabTypeCollectionView.reloadData()
        
        self.vwRentalTap.isHidden = false
        self.rentalLbl.isHidden = false
        self.rentalOptionImgView.isHidden = false
        self.rentalInfoLbl.isHidden = true
        self.rentalBackImgView.isHidden = true
    }
    
    func rentalOptionTapped(){
        if self.selectedCabCategoryType != Utils.rentalCategoryType {
            self.selectedCabCategoryType = Utils.rentalCategoryType
            
            //update array as per category selection
            self.cabTypesArr = self.listOfLoadedCategories[1].getArrObj("CabTypes") as! [NSDictionary]
            
            //set first cab type value as default when new category selected
            selectedCabTypeIdIndex = 0
            self.selectedCabTypeId = self.cabTypesArr[0].get("iVehicleTypeId")
            self.selectedCabTypeLogo = self.cabTypesArr[0].get("vLogo")
            self.selectedCabTypeName = self.cabTypesArr[0].get("vRentalVehicleTypeName")
            
            self.cabTypeCollectionView.reloadData()
            
            self.vwRentalTap.isHidden = true
            self.rentalLbl.isHidden = true
            self.rentalOptionImgView.isHidden = true
            self.rentalInfoLbl.isHidden = false
            self.rentalBackImgView.isHidden = false
            
        }
    }
    
    func getDirectionData(){
        
        self.progressBarContainerView.isHidden = false
        if(self.linearProgressBar != nil){
            self.linearProgressBar.startAnimation()
        }
        
        if(bookNowBtn != nil){
            bookNowBtn.setButtonEnabled(isBtnEnabled: false)
        }
        
         let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.pickUpLocation!.coordinate.latitude),\(self.pickUpLocation!.coordinate.longitude)&destination=\(destLocation!.coordinate.latitude),\(destLocation!.coordinate.longitude)&key=\(Configurations.getInfoPlistValue(key: "GOOGLE_SERVER_KEY"))&language=\(Configurations.getGoogleMapLngCode())&sensor=true"

        
        let exeWebServerUrl = ExeServerUrl(dict_data: [String:String](), currentView: self.view, isOpenLoader: false)
        
        exeWebServerUrl.executeGetProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("status").uppercased() != "OK" || dataDict.getArrObj("routes").count == 0){
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Direction to your selected place is not found. Please try again later or choose another place.", key: "LBL_DEST_ROUTE_NOT_FOUND"))
                    self.progressBarContainerView.isHidden = true
                    if(self.linearProgressBar != nil){
                        self.linearProgressBar.stopAnimation()
                    }
                    
//                    if(self.pickUpLocation != nil){
//
//                        let camera = GMSCameraPosition.camera(withLatitude: self.pickUpLocation!.coordinate.latitude,
//                                                              longitude: self.pickUpLocation!.coordinate.longitude, zoom: self.gMapView.camera.zoom)
//
//                        self.gMapView.animate(to: camera)
//                    }
//                    self.resetDestination()
                    self.isRouteDrawnFailed = true
                    
                    self.getVehicleTypesData(duration: "", distance: "")
                    
                    return
                }
                self.isRouteDrawnFailed = false
                
                let routesArr = dataDict.getArrObj("routes")
                let legs_arr = (routesArr.object(at: 0) as! NSDictionary).getArrObj("legs")
                let duration = (legs_arr.object(at: 0) as! NSDictionary).getObj("duration").get("value")
                let distance = (legs_arr.object(at: 0) as! NSDictionary).getObj("distance").get("value")
                
                self.getVehicleTypesData(duration: duration, distance: distance)
            }else{
                //                self.generalFunc.setError(uv: self)
                
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Please try again.", key: "LBL_TRY_AGAIN_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Retry", key: "LBL_RETRY_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                    
                    if(btnClickedIndex == 0){
                        self.getDirectionData()
                    }else{
                        self.resetDestination()
                    }
                })
                
            }
        }, url: directionURL)
    }
    
    func resetDestination(){
        self.destLocation = nil
        self.destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_DESTINATION_BTN_TXT")
        self.destHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Drop at", key: "LBL_DROP_AT")
    }
    
    func getAvailableCarTypesIds() -> String{
        var carTypesIds = ""
        
        var finalLoadedCarTypeIds = [NSDictionary]()
        var tmpAddedCarTypeIdsArr = [String]()
        if(listOfLoadedCategories.count > 0){
            
            for i in 0..<listOfLoadedCategories.count{
                let tmpCarTypesArr = listOfLoadedCategories[i].getArrObj("CabTypes")
                
                for j in 0..<tmpCarTypesArr.count{
                    let tmpDict = tmpCarTypesArr[j] as! NSDictionary
                    
                    if(!tmpAddedCarTypeIdsArr.contains(tmpDict.get("iVehicleTypeId"))){
                        
                        tmpAddedCarTypeIdsArr.append(tmpDict.get("iVehicleTypeId"))
                        finalLoadedCarTypeIds.append(tmpDict)
                    }
                }
            }
        }else{
            finalLoadedCarTypeIds.append(contentsOf: self.cabTypesArr)
        }
        
        for i in 0..<finalLoadedCarTypeIds.count{
            let iVehicleTypeId = finalLoadedCarTypeIds[i].get("iVehicleTypeId")
            
            carTypesIds = carTypesIds == "" ? iVehicleTypeId : (carTypesIds + "," + iVehicleTypeId)
        }
        
        return carTypesIds
    }
    
    func getVehicleTypesData(duration:String, distance:String){
        self.progressBarContainerView.isHidden = false
        if(self.linearProgressBar != nil){
            self.linearProgressBar.startAnimation()
        }
        
        if(bookNowBtn != nil){
            bookNowBtn.setButtonEnabled(isBtnEnabled: false)
        }
        var parameters = ["type":"getDriverVehicleDetails","UserType": Utils.appUserType, "iDriverId": GeneralFunctions.getMemberd(), "distance": distance, "time": duration, "VehicleTypeIds": self.getAvailableCarTypesIds()]
        
        if(pickUpLocation != nil){
            parameters["StartLatitude"] =  "\(pickUpLocation.coordinate.latitude)"
            parameters["EndLongitude"] =  "\(pickUpLocation.coordinate.longitude)"
        }
        
        if(destLocation != nil && self.isRouteDrawnFailed == false){
            parameters["DestLatitude"] =  "\(destLocation.coordinate.latitude)"
            parameters["DestLongitude"] =  "\(destLocation.coordinate.longitude)"
        }
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                
                if(dataDict.get("Action") == "1"){
                    
//                    self.carTypeResponse = dataDict
                    
                    let msgDataArr = dataDict.getArrObj(Utils.message_str)
                    
                    self.listOfLoadedCategories.removeAll()
                    self.cabTypesArr.removeAll()
                    
                    for i in 0..<msgDataArr.count{
                        let item = msgDataArr[i] as! NSDictionary
                        if(i == 0 && self.selectedCabTypeId == ""){
                            self.selectedCabTypeId = item.get("iVehicleTypeId")
                        }
                        self.cabTypesArr += [item]
                    }
                    
                    var cabCategoriesArr = [NSMutableDictionary]()
                    
                    //One Static Category for all
                    var listOfLoadedCategoriesNames = [Utils.dailyRideCategoryType]
                    
                    //Get Other categories if any
                    for i in 0..<self.cabTypesArr.count {
                        
                        let tempItem = self.cabTypesArr[i]
                        let eRental = tempItem.get("eRental")
                        
                        //Add Rental category if eRental is Yes
                        if (eRental.uppercased() == "YES"){
                            listOfLoadedCategoriesNames.append(Utils.rentalCategoryType)
                            break
                        }
                    }
                    
                    //Get Vehicletypes for categories
                    for i in 0..<listOfLoadedCategoriesNames.count {
                        
                        let eCategoryType = listOfLoadedCategoriesNames[i]
                        
                        var categoryCabTypesArr = [NSDictionary]()
                        
                        let cabCategoryItem = NSMutableDictionary()
                        cabCategoryItem["eCategoryType"] = eCategoryType
                        
                        if (eCategoryType == Utils.dailyRideCategoryType){
                            cabCategoryItem["vTitle"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DAILYRIDES_CATEGORY_TXT")
                            cabCategoryItem["vDescription"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBl_DAILYRIDES_DESCRIPTION_TXT")
                        }else if(eCategoryType == Utils.rentalCategoryType){
                            cabCategoryItem["vTitle"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENTAL_CATEGORY_TXT")
                            cabCategoryItem["vDescription"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENTAL_DESCRIPTION_TXT")
                        }
                        
                        for j in 0..<self.cabTypesArr.count {
                            
                            let tempItem = self.cabTypesArr[j]
                            let eRental = tempItem.get("eRental")
                            
                                //Add all vehicle types for DailyRide and if eRental yes than add to Rentals
                                if (eCategoryType == Utils.dailyRideCategoryType){
                                    categoryCabTypesArr += [tempItem]
                                }else if(eCategoryType == Utils.rentalCategoryType && eRental.uppercased() == "YES"){
                                    categoryCabTypesArr += [tempItem]
                                }
                        }
                        
                        cabCategoryItem["CabTypes"] = categoryCabTypesArr
                        cabCategoriesArr += [cabCategoryItem]
                    }
                    
                    self.listOfLoadedCategories = cabCategoriesArr
                    
                    self.cabTypesArr.removeAll()
                    
                    if(self.selectedCabCategoryType == ""){
                        self.selectedCabCategoryType = listOfLoadedCategoriesNames[0]
                        let tempCabTypesArr = (cabCategoriesArr[0] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                        self.cabTypesArr.append(contentsOf: tempCabTypesArr)
                    }else{
                        let index = listOfLoadedCategoriesNames.index(of: self.selectedCabCategoryType)
                        if(index != nil){
                            let tempCabTypesArr = (cabCategoriesArr[index!] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                            self.cabTypesArr.append(contentsOf: tempCabTypesArr)
                        }else{
                            let tempCabTypesArr = (cabCategoriesArr[0] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                            self.cabTypesArr.append(contentsOf: tempCabTypesArr)
                        }
                    }
                
//                    Utils.printLog(msgData: "listOfLoadedCategories::\(self.listOfLoadedCategories)")
                    
                    if(self.cabTypesArr.count < 1){
                        if(self.bookNowBtn != nil){
                            self.bookNowBtn.setButtonEnabled(isBtnEnabled: false)
                        }
                        
                        if(self.noCabTypeLbl != nil){
                            self.noCabTypeLbl.isHidden = false
                        }
                    }else{
                        if(self.bookNowBtn != nil){
                            self.bookNowBtn.setButtonEnabled(isBtnEnabled: true)
                        }
                        if(self.noCabTypeLbl != nil){
                            self.noCabTypeLbl.isHidden = true
                        }
                    }
                    
                    if(self.requestPickUpView == nil){
                        self.openRequestPickUpView()
                    }else{
                        self.cabTypeCollectionView.reloadData()
                    }
                    
//                    self.cabTypeCollectionView.reloadData()
                    
                    
                }else{
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Retry", key: "LBL_RETRY_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                        
                        if(btnClickedIndex == 0){
                            self.getVehicleTypesData(duration: duration, distance: distance)
                        }else{
                            self.destLocation = nil
                            self.destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_DESTINATION_BTN_TXT")
                            self.destHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Drop at", key: "LBL_DROP_AT")
                        }
                    })
                    
                }
                
            }else{
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Please try again.", key: "LBL_TRY_AGAIN_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Retry", key: "LBL_RETRY_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                    
                    if(btnClickedIndex == 0){
                        self.getVehicleTypesData(duration: duration, distance: distance)
                    }else{
                        
                        self.destLocation = nil
                        self.destLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_DESTINATION_BTN_TXT")
                        self.destHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Drop at", key: "LBL_DROP_AT")
                    }
                })
                
            }
            
            self.progressBarContainerView.isHidden = true
            if(self.linearProgressBar != nil){
                self.linearProgressBar.stopAnimation()
            }
        })
    
    }

    func myBtnTapped(sender: MyButton) {
        if(self.bookNowBtn != nil && sender == self.bookNowBtn){
            
            if(self.destLocation == nil || self.isRouteDrawnFailed == true){
                self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DEST_ROUTE_NOT_FOUND"))
                return
            }
            
            self.isTollChecked = false
            if(self.userProfileJson.get("ENABLE_TOLL_COST").uppercased() != "YES"){
                self.isTollChecked = true
            }
            
            if(self.eFlatTrip == true){
                self.isTollChecked = true
            }
            
            self.isSurgePriceChecked = false
            
            if (isRentalPackageSelected == false && self.selectedCabCategoryType == Utils.rentalCategoryType){
                self.openRentalPackageDetailsUV()
                return
            }
            
            self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CONFIRM_START_TRIP_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                
                if(btnClickedIndex == 0){
                    self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
                }
            })
        }else if(surgeAcceptBtn != nil && sender == surgeAcceptBtn){
            self.cancelSurgeView()
            if(self.eFlatTrip == true){
                self.isTollChecked = true
            }
            self.isSurgePriceChecked = true
            self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
        }
    }
    
    func openRentalPackageDetailsUV(){
        let rentalPackageDetailsUV = GeneralFunctions.instantiateViewController(pageName: "RentalPackageDetailsUV") as! RentalPackageDetailsUV
        rentalPackageDetailsUV.pickUpLocationAddress = self.pickUpAddress
        rentalPackageDetailsUV.selectedCabTypeName = self.selectedCabTypeName
        rentalPackageDetailsUV.selectedCabTypeId = self.selectedCabTypeId
        rentalPackageDetailsUV.vLogo = self.selectedCabTypeLogo
        self.pushToNavController(uv: rentalPackageDetailsUV)
    }
    
    func startTrip(tollPrice: String, tollPriceCurrencyCode: String, isTollSkipped: String){
        
        if(isSurgePriceChecked == false){
            self.checkSurgePrice()
            return
        }
        if(isTollChecked == false){
            checkTollPrice()
            return
        }
        
        let parameters = ["type":"StartHailTrip","UserType": Utils.appUserType, "iDriverId": GeneralFunctions.getMemberd(), "SelectedCarTypeID": selectedCabTypeId, "PickUpLatitude": "\(self.pickUpLocation.coordinate.latitude)", "PickUpLongitude": "\(self.pickUpLocation.coordinate.longitude)", "PickUpAddress": self.pickUpAddress, "DestLatitude": "\(self.destLocation.coordinate.latitude)", "DestLongitude": "\(self.destLocation.coordinate.longitude)", "DestAddress": self.destLbl.text!, "fTollPrice": tollPrice, "vTollPriceCurrencyCode": tollPriceCurrencyCode, "eTollSkipped": isTollSkipped,"iRentalPackageId" : self.selectedRentalPackageTypeId]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.contentView, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                
                if(dataDict.get("Action") == "1"){
                    
                    self.releaseAllTask()
                    
                    let window = Application.window
                    
                    let getUserData = GetUserData(uv: self, window: window!)
                    getUserData.getdata()
                    
                    
                }else{
                    if(dataDict.get(Utils.message_str) == "DO_RESTART" || dataDict.get("message") == "LBL_SERVER_COMM_ERROR" || dataDict.get("message") == "GCM_FAILED" || dataDict.get("message") == "APNS_FAILED"){
                        
                        self.releaseAllTask()
                        
                        let window = Application.window
                        
                        let getUserData = GetUserData(uv: self, window: window!)
                        getUserData.getdata()
                        
                        return
                    }
                    
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                        
                        if(btnClickedIndex == 0){
//                            self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
                        }
                    })
                    
                }
                
            }else{
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Please try again.", key: "LBL_TRY_AGAIN_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                    if(btnClickedIndex == 0){
//                        self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
                    }
                })
            }
            
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if(self.selectedCabTypeId == iVehicleTypeId){
//            openFareInfoView(cabTypeItem: self.cabTypesArr[indexPath.item])
//        }else{
//            self.selectedCabTypeId = iVehicleTypeId
//            collectionView.reloadData()
//        }
        
            selectedCabTypeIdIndex = indexPath.item
            let cabTypeItem = self.cabTypesArr[indexPath.item]
            let iVehicleTypeId = cabTypeItem.get("iVehicleTypeId")
            
            if(self.selectedCabTypeId == iVehicleTypeId){
                openFareInfoView(cabTypeItem: cabTypeItem)
            }else{
                self.selectedCabTypeId = iVehicleTypeId
                if self.selectedCabCategoryType == Utils.rentalCategoryType{
                    self.selectedCabTypeName = cabTypeItem.get("vRentalVehicleTypeName")
                }else{
                    self.selectedCabTypeName = cabTypeItem.get("vVehicleTypeName")
                }
                self.selectedCabTypeLogo = cabTypeItem.get("vLogo")
                self.selectedCabTypeId = iVehicleTypeId
                collectionView.reloadData()
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let screenWidth = Application.screenSize.width
        let totalCellWidth = (120 * cabTypesArr.count)
        
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + 0)) / 2;
        let rightInset = leftInset
        
        if(screenWidth < CGFloat(totalCellWidth)){
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }else{
            return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cabTypesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CabTypeCVCell", for: indexPath) as! CabTypeCVCell
        
        let tempDict = cabTypesArr[indexPath.item]
        let iVehicleTypeId = tempDict.get("iVehicleTypeId")
        
        
        var fareOfVehicleType = ""

        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            fareOfVehicleType = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "" : Configurations.convertNumToAppLocal(numStr: tempDict.get("RentalSubtotal"))
        }else{
            fareOfVehicleType = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "" : Configurations.convertNumToAppLocal(numStr: tempDict.get("SubTotal"))
        }
        
        if(self.selectedCabTypeId == iVehicleTypeId){
            
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                cell.cabTypeHoverImgView.isHidden = false
                cell.cabTypeImgView.isHidden = true
            })
            
            cell.cabTypeNameLbl.textColor = UIColor.UCAColor.AppThemeColor_1
            
            if(fareOfVehicleType == "" || self.destLocation == nil || self.isRouteDrawnFailed == true){
                cell.fareEstLbl.text = fareOfVehicleType
                
            }else{
                cell.fareEstLbl.addImage(originalText: Configurations.isRTLMode() ? " \(fareOfVehicleType)" : "\(fareOfVehicleType) ", image: UIImage(named: "ic_fare_detail")!.resize(toWidth: 15)!.resize(toHeight: 15)!, color: UIColor.UCAColor.AppThemeColor, position:  Configurations.isRTLMode() ? .left : .right)
            }
        }else{
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                cell.cabTypeImgView.isHidden = false
                cell.cabTypeHoverImgView.isHidden = true
            })
            
            cell.cabTypeNameLbl.textColor = UIColor(hex: 0x161718)
            cell.fareEstLbl.text = fareOfVehicleType
        }

            //        if(Configurations.isRTLMode()){
            //            var scalingTransform : CGAffineTransform!
            //            scalingTransform = CGAffineTransform(scaleX: -1, y: 1);
            //            cell.transform = scalingTransform
            //         }
            
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
//             cell.fareEstLbl.text = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "" : Configurations.convertNumToAppLocal(numStr: tempDict.get("RentalSubtotal"))
            cell.cabTypeNameLbl.text = tempDict.get("vRentalVehicleTypeName")
        }else{
//             cell.fareEstLbl.text = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "" : Configurations.convertNumToAppLocal(numStr: tempDict.get("SubTotal"))
            cell.cabTypeNameLbl.text = tempDict.get("vVehicleTypeName")
        }
    
        Utils.createRoundedView(view: cell.cabTypeImgView, borderColor: UIColor(hex: 0xcbcbcb), borderWidth: 1)
        Utils.createRoundedView(view: cell.cabTypeHoverImgView, borderColor: UIColor.UCAColor.AppThemeColor_1, borderWidth: 1)
        
        var vCarLogoImg = ""
        var vCarLogoHoverImg = ""
        if(UIScreen.main.scale < 2){
            vCarLogoImg = "1x_\(tempDict.get("vLogo"))"
            vCarLogoHoverImg = "1x_\(tempDict.get("vLogo1"))"
        }else if(UIScreen.main.scale < 3){
            vCarLogoImg = "2x_\(tempDict.get("vLogo"))"
            vCarLogoHoverImg = "2x_\(tempDict.get("vLogo1"))"
        }else{
            vCarLogoImg = "3x_\(tempDict.get("vLogo"))"
            vCarLogoHoverImg = "3x_\(tempDict.get("vLogo1"))"
        }
        
        var imgUrl = vVehicleImgPath + "\(iVehicleTypeId)/ios/\(vCarLogoImg)"
        
        var hoverImgUrl = vVehicleImgPath + "\(iVehicleTypeId)/ios/\(vCarLogoHoverImg)"
        
        if(tempDict.get("vLogo") == ""){
            imgUrl = "\(vVehicleDefaultImgPath)ic_car.png"
        }
        if(tempDict.get("vLogo1") == ""){
            hoverImgUrl = "\(vVehicleDefaultImgPath)hover_ic_car.png"
        }
        
        self.setCabTypeImage(imgView: cell.cabTypeHoverImgView, tintImgColor: UIColor.UCAColor.AppThemeTxtColor, imgUrl: hoverImgUrl, defaultImgUrl: "\(self.vVehicleDefaultImgPath)hover_ic_car.png", isCheckAgain: true)
        
        self.setCabTypeImage(imgView: cell.cabTypeImgView, tintImgColor: UIColor(hex: 0x999fa2), imgUrl: imgUrl, defaultImgUrl: "\(vVehicleDefaultImgPath)ic_car.png", isCheckAgain: true)
        
        cell.cabTypeImgView.backgroundColor = UIColor(hex: 0xffffff)
        cell.cabTypeHoverImgView.backgroundColor = UIColor(hex: 0xffffff)
        
//        cell.cabTypeImgView.backgroundColor = UIColor(hex: 0xebebeb)
//        cell.cabTypeHoverImgView.backgroundColor = UIColor.UCAColor.AppThemeColor
        
//        GeneralFunctions.setImgTintColor(imgView: cell.cabTypeHoverImgView, color: UIColor.UCAColor.AppThemeTxtColor)
//        GeneralFunctions.setImgTintColor(imgView: cell.cabTypeImgView, color: UIColor(hex: 0x999fa2))
        
        if(indexPath.item == 0){
            cell.leftSeperationTopView.isHidden = true
            cell.leftSeperationBottomView.isHidden = true
            
        }else{
            cell.leftSeperationTopView.isHidden = false
            cell.leftSeperationBottomView.isHidden = false
        }
        
        if(indexPath.item == (self.cabTypesArr.count - 1)){
            cell.rightSeperationTopView.isHidden = true
            cell.rightSeperationBottomView.isHidden = true
        }else{
            cell.rightSeperationTopView.isHidden = false
            cell.rightSeperationBottomView.isHidden = false
        }
        
        return cell
    }
    
    func setCabTypeImage(imgView:UIImageView, tintImgColor:UIColor, imgUrl:String, defaultImgUrl:String, isCheckAgain:Bool){
        imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeHolder.png"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            if(error != nil && isCheckAgain == true){
                self.setCabTypeImage(imgView: imgView, tintImgColor: tintImgColor, imgUrl: defaultImgUrl, defaultImgUrl: defaultImgUrl, isCheckAgain: false)
            }
//            GeneralFunctions.setImgTintColor(imgView: imgView, color: tintImgColor)
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func openFareInfoView(cabTypeItem:NSDictionary){

        var detailTxt = ""
        
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            detailTxt = self.generalFunc.getLanguageLabel(origValue: "Rental fares may vary as per packages you choose for selected vehicle type." , key: "LBL_RENT_PKG_DETAILS")
        }else{
            if(cabTypeItem.get("eFlatTrip").uppercased() == "YES"){
                detailTxt = self.generalFunc.getLanguageLabel(origValue: "This fare is based on your source to destination location. System will charge fixed fare depending on your location.", key: "LBL_GENERAL_NOTE_FLAT_FARE_EST")
                
            }else{
                detailTxt = self.generalFunc.getLanguageLabel(origValue: "This fare is based on our estimation. This may vary during trip and final fare.", key: "LBL_GENERAL_NOTE_FARE_EST")
            }
        }
        
        var detailTxtHeight = detailTxt.height(withConstrainedWidth: Application.screenSize.width - 20, font: UIFont(name: "Roboto-Light", size: 17)!)
        
        var rentalInfoTxt = ""
        
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            rentalInfoTxt = self.generalFunc.getLanguageLabel(origValue: "Rent a cab at flexible hourly packages and have a multiple stops." , key: "LBL_RENT_PKG_MSG")
        }
        
        let rentalInfoTxtHeight = rentalInfoTxt.height(withConstrainedWidth: Application.screenSize.width - 20, font: UIFont(name: "Roboto-Light", size: 17)!)
        
        let viewHeight = rentalInfoTxtHeight + detailTxtHeight + 415 + (GeneralFunctions.getSafeAreaInsets().bottom / 2)
        
//        let height = Application.screenSize.height > 480 ? 450 : (Application.screenSize.height - 60)
        
        var height = Application.screenSize.height > viewHeight ? viewHeight : Application.screenSize.height
        height = height - 68 // minus dynamic height labels height
        
        if(viewHeight > Application.screenSize.height){
            detailTxtHeight = height - 415 + 20
        }
        
        let fareDetailView = FareDetailView(frame: CGRect(x: 0, y: self.view.frame.height + height, width: Application.screenSize.width, height: height))
        
        let fareDetailBGView = UIView(frame: self.contentView.frame)
        
        self.fareDetailView = fareDetailView
        self.fareDetailBGView = fareDetailBGView
        
        fareDetailBGView.backgroundColor = UIColor.black
        fareDetailBGView.alpha = 0.4
        fareDetailBGView.isUserInteractionEnabled = true
        fareDetailView.setViewHandler { (isViewClose, view, isMoreDetailTapped) in
            
            fareDetailView.frame.origin.y = Application.screenSize.height + height
            fareDetailBGView.removeFromSuperview()
            fareDetailView.removeFromSuperview()
            self.view.layoutIfNeeded()
            

            if(isMoreDetailTapped){
                let fareBreakDownUv = GeneralFunctions.instantiateViewController(pageName: "FareBreakDownUV") as! FareBreakDownUV
                fareBreakDownUv.selectedCabTypeId = self.selectedCabTypeId
                fareBreakDownUv.pickUpLocation = self.pickUpLocation
                if(self.isRouteDrawnFailed == false){
                    fareBreakDownUv.destLocation = self.destLocation
                }
                fareBreakDownUv.selectedCabTypeName = cabTypeItem.get("vVehicleTypeName")
                if(cabTypeItem.get("eFlatTrip").uppercased() == "YES"){
                    fareBreakDownUv.eFlatTrip = true
                }
                self.pushToNavController(uv: fareBreakDownUv)
            }
        }
        
        let fareDetailBGTapGue = UITapGestureRecognizer()
        fareDetailBGTapGue.addTarget(self, action: #selector(self.fareDetailBGViewTapped))
        fareDetailBGView.addGestureRecognizer(fareDetailBGTapGue)
        
        self.view.addSubview(fareDetailBGView)
        self.view.addSubview(fareDetailView)
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        //                        self.requestPickUpView.center = CGPoint(x: 0, y: 310)
                        fareDetailView.frame.origin.y = self.view.frame.height - height
                        self.view.layoutIfNeeded()
        },  completion: { finished in
            
        })
    
        
        
        fareDetailView.doneBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DONE"))
        
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            fareDetailView.moreDetailsLbl.isHidden = true
            fareDetailView.rentalInfoLbl.text = rentalInfoTxt
            fareDetailView.rentalInfoLbl.fitText()
            fareDetailView.topFareView.constant = rentalInfoTxtHeight + 27
            fareDetailView.topNoteLbl.constant = 15
            fareDetailView.cabTypeNameLbl.text = cabTypeItem.get("vRentalVehicleTypeName")
        }else{
            fareDetailView.rentalInfoLbl.isHidden = true
            fareDetailView.topFareView.constant = 15
            fareDetailView.topNoteLbl.constant = 44
            fareDetailView.cabTypeNameLbl.text = cabTypeItem.get("vVehicleTypeName")
        }
        
        let vLogo = cabTypeItem.get("vLogo1")
        
        var vCarLogoHoverImg = ""
        if(UIScreen.main.scale < 2){
            vCarLogoHoverImg = "1x_\(vLogo)"
        }else if(UIScreen.main.scale < 3){
            vCarLogoHoverImg = "2x_\(vLogo)"
        }else{
            vCarLogoHoverImg = "3x_\(vLogo)"
        }
        
        var hoverImgUrl = vVehicleImgPath + "\(selectedCabTypeId)/ios/\(vCarLogoHoverImg)"
        
        if(vLogo == ""){
            hoverImgUrl = "\(vVehicleDefaultImgPath)hover_ic_car.png"
        }
        
        fareDetailView.cabTypeImgView.sd_setImage(with: URL(string: hoverImgUrl), placeholderImage: UIImage(named: "placeHolder.png"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
//            GeneralFunctions.setImgTintColor(imgView: fareDetailView.cabTypeImgView, color: UIColor.UCAColor.AppThemeColor)
        })
        
        fareDetailView.capacityHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Capacity", key: "LBL_CAPACITY")
        fareDetailView.capacityVLbl.text = Configurations.convertNumToAppLocal(numStr: cabTypeItem.get("iPersonSize") + " \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PEOPLE_TXT"))")
        
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            fareDetailView.fareHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Packages starting at", key: "LBL_PKG_STARTING_AT")
        }else{
            fareDetailView.fareHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Fare", key: "LBL_FARE_TXT")
        }
//        fareDetailView.noteLbl.text = self.generalFunc.getLanguageLabel(origValue: "This fare is based on our estimation. This may vary during trip and final fare.", key: "LBL_GENERAL_NOTE_FARE_EST")
//        fareDetailView.noteLbl.fitText()

        fareDetailView.noteLbl.text = detailTxt
//        fareDetailView.noteLbl.numberOfLines = Int(detailTxtHeight / 20)
        fareDetailView.noteLbl.numberOfLines = (Double(detailTxtHeight / 20).rounded() < Double(detailTxtHeight / 20)) ? Int(detailTxtHeight / 20) : Int(Double(detailTxtHeight / 20).rounded())
        
        fareDetailView.moreDetailsLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MORE_INFO")
        
        if self.selectedCabCategoryType == Utils.rentalCategoryType{
            fareDetailView.fareVLbl.text = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "--" : Configurations.convertNumToAppLocal(numStr: cabTypeItem.get("RentalSubtotal"))
        }else{
            fareDetailView.fareVLbl.text = (self.destLocation == nil || self.isRouteDrawnFailed == true) ? "--" : Configurations.convertNumToAppLocal(numStr: cabTypeItem.get("SubTotal"))
        }
    }
    
    func fareDetailBGViewTapped(){
        
        if(fareDetailView != nil){
            fareDetailView.frame.origin.y = Application.screenSize.height + fareDetailView.frame.height
            fareDetailView.removeFromSuperview()
        }
        
        if(fareDetailBGView != nil){
            fareDetailBGView.frame.origin.y = Application.screenSize.height + fareDetailView.frame.height
            fareDetailBGView.removeFromSuperview()
        }
    }

    func checkTollPrice(){
        
        let tollURL = "https://tce.cit.api.here.com/2/calculateroute.json?app_id=\(self.userProfileJson.get("TOLL_COST_APP_ID"))&app_code=\(self.userProfileJson.get("TOLL_COST_APP_CODE"))&waypoint0=\(self.pickUpLocation.coordinate.latitude),\(self.pickUpLocation.coordinate.longitude)&waypoint1=\(self.destLocation.coordinate.latitude),\(self.destLocation.coordinate.longitude)&mode=fastest;car"
        let exeWebServerUrl = ExeServerUrl(dict_data: [String:String](), currentView: self.view, isOpenLoader: true)
        
        exeWebServerUrl.executeGetProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("onError").uppercased() == "FALSE" || dataDict.get("onError") == "0"){
                    
                    self.isTollChecked = true
                    
                    let totalCost = dataDict.getObj("costs").get("totalCost")
                    let currency = dataDict.getObj("costs").get("currency")
                    
                    if(totalCost != "0.0"){
                        
                        let openTollBox = OpenTollBox(uv: self, containerView: self.view)
                        openTollBox.setViewHandler(handler: { (isContinueBtnTapped, isTollSkipped) in
                            if(isContinueBtnTapped){
                                
                                self.startTrip(tollPrice: totalCost, tollPriceCurrencyCode: currency, isTollSkipped: isTollSkipped == true ? "Yes" : "No")
                                
                            }else{
                                self.isTollChecked = false
                            }
                        })
                        
                        let selectedVehicleTypeItem = self.cabTypesArr[self.selectedCabTypeIdIndex]
                        openTollBox.show(tollPrice: "\(currency) \(totalCost)", currentFare: Configurations.convertNumToAppLocal(numStr: selectedVehicleTypeItem.get("SubTotal")))
                    }else{
                        
                        self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
                        
                    }
                    
                }else{
                    
                    self.isTollChecked = true
                    
                    self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
                    
                }
                
            }else{
                
                self.generalFunc.setError(uv: self)
            }
        }, url: tollURL)
        
    }
    
    func checkSurgePrice(){
//        let parameters = ["type":"checkSurgePrice","SelectedCarTypeID": self.selectedCabTypeId, "SelectedTime": ""]
        let parameters = ["type":"checkSurgePrice","SelectedCarTypeID": self.selectedCabTypeId, "SelectedTime": "", "PickUpLatitude": "\(self.pickUpLocation!.coordinate.latitude)", "PickUpLongitude": "\(self.pickUpLocation!.coordinate.longitude)", "DestLatitude": "\(self.destLocation != nil ? "\(self.destLocation!.coordinate.latitude)" : "")", "DestLongitude": "\(self.destLocation != nil ? "\(self.destLocation!.coordinate.longitude)" : "")", "iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType , "iRentalPackageId" : self.selectedRentalPackageTypeId]
        
        //        , "TimeZone": selectedTimeZone
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                self.checkFlatFareExist(dataDict: dataDict)
                
                
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    func checkFlatFareExist(dataDict:NSDictionary){
        
        if(dataDict.get("eFlatTrip").uppercased() == "YES"){
            self.eFlatTrip = true
            openSurgeConfirmDialog(dataDict: dataDict)
        }else{
            self.eFlatTrip = false
            if(dataDict.get("Action") == "1"){
                self.isSurgePriceChecked = true
                self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
            }else{
                self.openSurgeConfirmDialog(dataDict: dataDict)
            }
        }
    }
    
    func openSurgeConfirmDialog(dataDict:NSDictionary){
        let selectedVehicleTypeItem = self.cabTypesArr[selectedCabTypeIdIndex]

        surgePriceView = self.generalFunc.loadView(nibName: "SurgePriceView", uv: self, isWithOutSize: true)
        
        let width = Application.screenSize.width  > 390 ? 375 : Application.screenSize.width - 50
        
        var defaultHeight:CGFloat = 154
        surgePriceView.frame.size = CGSize(width: width, height: defaultHeight)
        
        surgePriceView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)

        surgePriceBGView = UIView()
        surgePriceBGView.backgroundColor = UIColor.black
        self.surgePriceBGView.alpha = 0
        surgePriceBGView.isUserInteractionEnabled = true
        
        let bgViewTapGue = UITapGestureRecognizer()
        surgePriceBGView.frame = self.contentView.frame
        
        surgePriceBGView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)
        
//        bgViewTapGue.addTarget(self, action: #selector(self.cancelSurgeView))
        
        surgePriceBGView.addGestureRecognizer(bgViewTapGue)
        
        surgePriceView.layer.shadowOpacity = 0.5
        surgePriceView.layer.shadowOffset = CGSize(width: 0, height: 3)
        surgePriceView.layer.shadowColor = UIColor.black.cgColor
        
        surgePriceView.alpha = 0
        self.view.addSubview(surgePriceBGView)
        self.view.addSubview(surgePriceView)
        
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.surgePriceBGView.alpha = 0.4
                        self.surgePriceView.alpha = 1
        },  completion: { finished in
            self.surgePriceBGView.alpha = 0.4
            self.surgePriceView.alpha = 1
        })
        
        let cancelSurgeTapGue = UITapGestureRecognizer()
        cancelSurgeTapGue.addTarget(self, action: #selector(self.cancelSurgeView))
        
        surgeLaterLbl.isUserInteractionEnabled = true
        surgeLaterLbl.addGestureRecognizer(cancelSurgeTapGue)
        
        
        self.surgePayAmtLbl.text = selectedVehicleTypeItem.get("SubTotal") == "" ? "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PAYABLE_AMOUNT"))" : "\(self.generalFunc.getLanguageLabel(origValue: "Approx payable amount", key: "LBL_APPROX_PAY_AMOUNT")): \(Configurations.convertNumToAppLocal(numStr: selectedVehicleTypeItem.get("SubTotal")))"
        self.surgeLaterLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TRY_LATER")
        
        if(dataDict.get("eFlatTrip").uppercased() == "YES"){
            self.eFlatTrip = true
            self.surgePayAmtLbl.isHidden = true
            self.surgePayAmtLbl.text = ""
            defaultHeight = defaultHeight - 20
            self.surgePriceVLbl.text = dataDict.get("Action") == "1" ? dataDict.get("fFlatTripPricewithsymbol") : "\(Configurations.convertNumToAppLocal(numStr: dataDict.get("fFlatTripPricewithsymbol"))) (\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_AT_TXT")) \(Configurations.convertNumToAppLocal(numStr: dataDict.get("SurgePrice"))))"
            self.surgePriceHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FIX_FARE_HEADER")
            self.surgeAcceptBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACCEPT_TXT"))
        }else{
            self.eFlatTrip = false
            self.surgePriceVLbl.text = Configurations.convertNumToAppLocal(numStr: dataDict.get("SurgePrice"))
            self.surgePriceHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str))
            self.surgeAcceptBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACCEPT_SURGE"))
        }
        
        let headerTxtHeight = self.surgePriceHLbl.text!.height(withConstrainedWidth: width - 20, font: UIFont(name: "Roboto-Light", size: 17)!)
        let priceTxtHeight = self.surgePriceVLbl.text!.height(withConstrainedWidth: width - 20, font: UIFont(name: "Roboto-Light", size: 26)!)
        let payAmtTxtHeight = self.surgePayAmtLbl.text!.height(withConstrainedWidth: width - 20, font: UIFont(name: "Roboto-Light", size: 16)!)
        
        self.surgePriceHLbl.fitText()
        self.surgePayAmtLbl.fitText()
        self.surgePriceVLbl.fitText()
        
        defaultHeight = defaultHeight + headerTxtHeight + priceTxtHeight + payAmtTxtHeight
        surgePriceView.frame.size = CGSize(width: width, height: defaultHeight)
        surgePriceView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)

        self.surgeAcceptBtn.clickDelegate = self
        
    }
    
   /*
    func openSurgeConfirmDialog(dataDict:NSDictionary){
        let selectedVehicleTypeItem = self.cabTypesArr[selectedCabTypeIdIndex]

        surgePriceView = self.generalFunc.loadView(nibName: "SurgePriceView", uv: self, isWithOutSize: true)
        
        let width = Application.screenSize.width  > 390 ? 375 : Application.screenSize.width - 50
        
        surgePriceView.frame.size = CGSize(width: width, height: 260)
        
        surgePriceView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)
        
        surgePriceBGView = UIView()
        surgePriceBGView.backgroundColor = UIColor.black
        surgePriceBGView.alpha = 0
        surgePriceBGView.isUserInteractionEnabled = true
        
        let bgViewTapGue = UITapGestureRecognizer()
        surgePriceBGView.frame = self.contentView.frame
        
        surgePriceBGView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)
        
        bgViewTapGue.addTarget(self, action: #selector(self.cancelSurgeView))
        
        surgePriceBGView.addGestureRecognizer(bgViewTapGue)
        
        surgePriceView.layer.shadowOpacity = 0.5
        surgePriceView.layer.shadowOffset = CGSize(width: 0, height: 3)
        surgePriceView.layer.shadowColor = UIColor.black.cgColor
        
        surgePriceView.alpha = 0
        self.view.addSubview(surgePriceBGView)
        self.view.addSubview(surgePriceView)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.surgePriceBGView.alpha = 0.4
                self.surgePriceView.alpha = 1
                
        }
        )
        
        let cancelSurgeTapGue = UITapGestureRecognizer()
        cancelSurgeTapGue.addTarget(self, action: #selector(self.cancelSurgeView))
        
        surgeLaterLbl.isUserInteractionEnabled = true
        surgeLaterLbl.addGestureRecognizer(cancelSurgeTapGue)
        
        self.surgePayAmtLbl.text = selectedVehicleTypeItem.get("SubTotal") == "" ? "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PAYABLE_AMOUNT"))" : "\(self.generalFunc.getLanguageLabel(origValue: "Approx payable amount", key: "LBL_APPROX_PAY_AMOUNT")): \(Configurations.convertNumToAppLocal(numStr: selectedVehicleTypeItem.get("SubTotal")))"
        self.surgeLaterLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TRY_LATER")
        self.surgePriceVLbl.text = Configurations.convertNumToAppLocal(numStr: dataDict.get("SurgePrice"))
        self.surgePriceHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str))
        self.surgeAcceptBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACCEPT_SURGE"))
        self.surgeAcceptBtn.clickDelegate = self
        
    }
 */
    
    @IBAction func unwindToTaxiHailScreen(_ segue:UIStoryboardSegue) {
   
        let rentalPackageDetailsUV = segue.source as! RentalPackageDetailsUV
        self.selectedRentalPackageTypeId = rentalPackageDetailsUV.selectedRentalPackageTypeId
        self.isRentalPackageSelected = true
        
        self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CONFIRM_START_TRIP_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
            
            if(btnClickedIndex == 0){
                
                self.startTrip(tollPrice: "", tollPriceCurrencyCode: "", isTollSkipped: "")
            }else{
                self.isRentalPackageSelected = false
                self.selectedRentalPackageTypeId = ""
            }
        })
    }
    
    
    func cancelSurgeView(){
        if(surgePriceView != nil){
            surgePriceView.removeFromSuperview()
        }
        
        if(surgePriceBGView != nil){
            surgePriceBGView.removeFromSuperview()
        }
        
    }
}
