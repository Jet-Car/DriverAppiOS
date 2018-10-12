//
//  PaymentUV.swift
//  DriverApp
//
//  Created by ADMIN on 19/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class PaymentUV: UIViewController, MyBtnClickDelegate, CreditCardFormDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLbl: MyLabel!
    @IBOutlet weak var subHeaderLbl: MyLabel!
    @IBOutlet weak var configCardBtn: MyButton!
    @IBOutlet weak var cardNumTxtField: MyTextField!
    @IBOutlet weak var demoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // SITE_TYPE = Demo
    @IBOutlet weak var notesLbl: MyLabel!
    @IBOutlet weak var notesDescLbl: UILabel!
    @IBOutlet weak var cardTypeHLbl: UILabel!
    @IBOutlet weak var cardTypeVLbl: UILabel!
    @IBOutlet weak var cardNumLbl: UILabel!
    @IBOutlet weak var cardNumVLbl: UILabel!
    @IBOutlet weak var expiryLbl: UILabel!
    @IBOutlet weak var expiryVLbl: UILabel!
    @IBOutlet weak var cvvLbl: UILabel!
    @IBOutlet weak var cvvVlbl: UILabel!
    @IBOutlet weak var cardDetailAreaView: UIView!
    @IBOutlet weak var demoHintCarddetailView: UIView!
    @IBOutlet weak var cardDetailAreaViewHeight: NSLayoutConstraint!
    
    let generalFunc = GeneralFunctions()
    
    var cntView:UIView!
    
    var PAGE_HEIGHT:CGFloat = 600
    
    var isFirstLaunch = true
    
    var userProfileJson:NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = -1
        
        if(isFirstLaunch){
            
            
            self.scrollView.bounces = false
            
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
            
            isFirstLaunch = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cntView = self.generalFunc.loadView(nibName: "PaymentScreenDesign", uv: self, contentView: scrollView)
        self.scrollView.backgroundColor = UIColor(hex: 0xF2F2F4)
        self.scrollView.addSubview(cntView)
        
        self.addBackBarBtn()
        
        setData()
    }
    
    
    func setData(){
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CARD_PAYMENT_DETAILS")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CARD_PAYMENT_DETAILS")
        
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        self.userProfileJson = userProfileJson
        
        headerView.layer.shadowOpacity = 0.5
        //        headerView.layer.shadowRadius = 1.1
        headerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        headerView.layer.shadowColor = UIColor(hex: 0xc0c0c1).cgColor
        headerView.backgroundColor = UIColor.UCAColor.AppThemeColor
        
        let vCreditCard = userProfileJson.get("vCreditCard")
        var vStripeCusId = userProfileJson.get("vStripeCusId")
        
        if userProfileJson.get("APP_PAYMENT_METHOD") == "Braintree"
        {
            vStripeCusId = userProfileJson.get("vBrainTreeCustId")
        }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Paymaya"
        {
            vStripeCusId = userProfileJson.get("vPaymayaCustId")
        }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Omise"
        {
            vStripeCusId = userProfileJson.get("vOmiseCustId")
        }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Adyen"
        {
            vStripeCusId = userProfileJson.get("vAdyenToken")
        }
        
        if(vStripeCusId == ""){
            headerLbl.text = self.generalFunc.getLanguageLabel(origValue: "No Card Available", key: "LBL_NO_CARD_AVAIL_HEADER_NOTE")
            configCardBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_CARD"))
            subHeaderLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NO_CARD_AVAIL_NOTE")
            self.cardNumTxtField.isHidden = true
            
            
        }else{
            headerLbl.isHidden = true
            subHeaderLbl.isHidden = true
            configCardBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CHANGE"))
            
            self.cardNumTxtField.isHidden = false
            
            self.cardNumTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CARD_NUMBER_HEADER_TXT"))
            self.cardNumTxtField.setText(text: vCreditCard)
            self.cardNumTxtField.setEnable(isEnabled: false)
            
            if userProfileJson.get("vBrainTreeCustEmail") != "" && userProfileJson.get("APP_PAYMENT_METHOD") == "Braintree"
            {
                self.cardNumTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PAYPAL_EMAIL_TXT"))
                self.cardNumTxtField.setText(text: userProfileJson.get("vBrainTreeCustEmail"))
            }
            
        }
        
        configCardBtn.setCustomColor(textColor: UIColor.UCAColor.paymentConfigBtnTextColor, bgColor: UIColor.UCAColor.paymentConfigBtnBGColor, pulseColor: UIColor.UCAColor.paymentConfigBtnPulseColor)
        
        headerLbl.textColor = UIColor.UCAColor.AppThemeTxtColor
        subHeaderLbl.textColor = UIColor.UCAColor.AppThemeTxtColor
        
        configCardBtn.clickDelegate = self
        
        cardDetailAreaView.layer.shadowOpacity = 0.5
        cardDetailAreaView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardDetailAreaView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        if(userProfileJson.get("SITE_TYPE").uppercased() == "DEMO"){
            cardDetailAreaView.isHidden = false
            
            self.notesDescLbl.text = self.generalFunc.getLanguageLabel(origValue: "Since this is the demo version, please use below dummy credit/debit card for testing. The actual payment will not be deducted.", key: "LBL_DEMO_CARD_DESC")
            
            
            let noteHeight = self.generalFunc.getLanguageLabel(origValue: "Since this is the demo version, please use below dummy credit/debit card for testing. The actual payment will not be deducted.", key: "LBL_DEMO_CARD_DESC").height(withConstrainedWidth: Application.screenSize.width - 25, font: UIFont(name: "Roboto-Light", size: 16)!)
            
            PAGE_HEIGHT = PAGE_HEIGHT + noteHeight
        }else{
            cardDetailAreaView.isHidden = true
            
            PAGE_HEIGHT = PAGE_HEIGHT - self.cardDetailAreaViewHeight.constant
            
            
            self.notesDescLbl.text = self.generalFunc.getLanguageLabel(origValue: "Your card information is secured with our payment gateway. All transactions are performed under the standard security and all performed transactions are confidential. Your information will not be shared to third party.", key: "LBL_CARD_INFO_SECURE_NOTE")
            
            
            let noteHeight = self.generalFunc.getLanguageLabel(origValue: "Your card information is secured with our payment gateway. All transactions are performed under the standard security and all performed transactions are confidential. Your information will not be shared to third party.", key: "LBL_CARD_INFO_SECURE_NOTE").height(withConstrainedWidth: Application.screenSize.width - 25, font: UIFont(name: "Roboto-Light", size: 16)!)
            
            PAGE_HEIGHT = PAGE_HEIGHT + noteHeight
        }
        
        self.notesLbl.text = self.generalFunc.getLanguageLabel(origValue: "NOTES", key: "LBL_NOTES")

        self.notesDescLbl.fitText()
        
        self.cardTypeHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Card Type", key: "LBL_CARD_TYPE") + ":"
        self.cardNumLbl.text = self.generalFunc.getLanguageLabel(origValue: "Card Number", key: "LBL_CARD_NUMBER_TXT") + ":"
        self.expiryLbl.text = self.generalFunc.getLanguageLabel(origValue: "Expiry", key: "LBL_EXPIRY") + ":"
        self.cvvLbl.text = self.generalFunc.getLanguageLabel(origValue: "CVV", key: "LBL_CVV") + ":"
        
        self.cardNumVLbl.text = "4111 1111 1111 1111"
        self.expiryVLbl.text = "12/2023"
        self.cvvVlbl.text = "123"
        self.cardTypeVLbl.text = "VISA"
        
        if userProfileJson.get("APP_PAYMENT_METHOD") == "Paymaya"
        {
            if userProfileJson.get("PAYMAYA_ENVIRONMENT_MODE") == "Sandbox"
            {
                PayMayaSDK.sharedInstance().setPaymentsAPIKey(userProfileJson.get("PAYMAYA_PUBLISH_KEY"), for: PayMayaEnvironment.sandbox)
            }else
            {
                PayMayaSDK.sharedInstance().setPaymentsAPIKey(userProfileJson.get("PAYMAYA_PUBLISH_KEY"), for: PayMayaEnvironment.production)
            }
            
        }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Stripe"
        {
            STPPaymentConfiguration.shared().publishableKey = userProfileJson.get("STRIPE_PUBLISH_KEY")
        }
        
    }

    func myBtnTapped(sender: MyButton) {
        if(sender == self.configCardBtn){
            
//            let addPaymentUv = GeneralFunctions.instantiateViewController(pageName: "AddPaymentUV") as! AddPaymentUV
//            addPaymentUv.PAGE_MODE = self.cardNumTxtField.isHidden ? "ADD" : "EDIT"
//            addPaymentUv.paymentUv = self
//            
//            self.pushToNavController(uv: addPaymentUv)
            
            if userProfileJson.get("APP_PAYMENT_METHOD") == "Stripe" ||  userProfileJson.get("APP_PAYMENT_METHOD") == "Paymaya" || userProfileJson.get("APP_PAYMENT_METHOD") == "Adyen"
            {
                if userProfileJson.get("APP_PAYMENT_METHOD") == "Adyen"
                {
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: userProfileJson.get("ADEYN_CHARGE_MESSAGE")), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedId) in
                        if(btnClickedId == 0){
                            
                            self.checkUserStatus()
                        }
                    })
                    
                }else{
                    checkUserStatus()
                }
                
            }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Braintree"
            {
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: userProfileJson.get("BRAINTREE_CHARGE_MESSAGE")), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedId) in
                    if(btnClickedId == 0){
                        
                        let request =  BTDropInRequest()
                        
                        let dropIn = BTDropInController(authorization: self.userProfileJson.get("BRAINTREE_TOKEN_KEY"), request: request){
                                (controller, result, error) in
                            
                            if (error != nil) {
                                print("ERROR")
                            } else if (result?.isCancelled == true) {
                                print("CANCELLED")
                            } else if let result = result {
                                
                                self.addBrainTreeNonceToServer(nonce:result.paymentMethod?.nonce ?? "")
                                print(result.paymentMethod?.nonce ?? "")
                                print(result.paymentDescription)
                                print(result.paymentOptionType)
                                
                            }
                            controller.dismiss(animated: true, completion: nil)
                        }
                        self.present(dropIn!, animated: true, completion: nil)
                        
                    }
                })
                
            }else if userProfileJson.get("APP_PAYMENT_METHOD") == "Omise"
            {
                let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissCreditCardForm))
                
                let creditCardView = CreditCardFormController.makeCreditCardForm(withPublicKey: userProfileJson.get("OMISE_PUBLIC_KEY"))
                creditCardView.delegate = self
                creditCardView.handleErrors = true
                creditCardView.navigationItem.rightBarButtonItem = closeButton
                
                let navigation = UINavigationController(rootViewController: creditCardView)
                present(navigation, animated: true, completion: nil)
            }
            
        }
    }
    
    /* FOR Stripe, Paymaya, Adyen Payment GateWay. */
    func checkUserStatus(){
        let parameters = ["type":"checkUserStatus","iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            //            print("Response:\(response)")
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    let addPaymentUv = GeneralFunctions.instantiateViewController(pageName: "AddPaymentUV") as! AddPaymentUV
                    addPaymentUv.PAGE_MODE = self.cardNumTxtField.isHidden ? "ADD" : "EDIT"
                    addPaymentUv.payMentMethod = self.userProfileJson.get("APP_PAYMENT_METHOD")
                    addPaymentUv.paymentUv = self
                    
                    self.pushToNavController(uv: addPaymentUv)
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }

     /* FOR BrainTree Payment gateway  */
    func addBrainTreeNonceToServer(nonce:String){
        let maskedCreditCardNo = ""
        
        let parameters = ["type":"GenerateCustomer","iUserId": GeneralFunctions.getMemberd(), "paymentMethodNonce": nonce, "UserType": Utils.appUserType, "CardNo": maskedCreditCardNo]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")))
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    
                    self.setData()
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    /* FOR Omise Payment gateway  */
    @objc func dismissCreditCardForm() {
        dismiss(animated: true, completion: nil)
    }
    
    func creditCardForm(_ controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
        dismissCreditCardForm()
        
        let tokenId = token.tokenId ?? ""
        self.addOmiseTokenToServer(token: tokenId)
        
    }
    
    func creditCardForm(_ controller: CreditCardFormController, didFailWithError error: Error) {
        dismissCreditCardForm()
        
        self.generalFunc.setError(uv: self)
        // Only important if we set `handleErrors = false`.
        // You can send errors to a logging service, or display them to the user here.
    }
    
    func addOmiseTokenToServer(token:String){
        let maskedCreditCardNo = ""
        
        let parameters = ["type":"GenerateCustomer","iUserId": GeneralFunctions.getMemberd(), "vOmiseToken": token, "UserType": Utils.appUserType, "CardNo": maskedCreditCardNo]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")))
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    
                    self.setData()
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
}
