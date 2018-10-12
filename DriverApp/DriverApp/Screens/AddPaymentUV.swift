//
//  AddPaymentUV.swift
//  DriverApp
//
//  Created by ADMIN on 19/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class AddPaymentUV: UIViewController, MyBtnClickDelegate, UIWebViewDelegate {
    
    var PAGE_HEIGHT:CGFloat = 667

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var creditCardNumView: UIView!
    @IBOutlet weak var creditCardTxtField: MyTextField!
    @IBOutlet weak var expiryView: UIView!
    @IBOutlet weak var monthTxtField: MyTextField!
    @IBOutlet weak var yearTxtField: MyTextField!
    @IBOutlet weak var cvvView: UIView!
    @IBOutlet weak var cvvTxtField: MyTextField!
    @IBOutlet weak var configCardBtn: MyButton!
    
    let generalFunc = GeneralFunctions()
    
    var paymentUv:PaymentUV!
    var payMentMethod = ""
    
    var PAGE_MODE = "ADD"
    var isPageLoad = false
    
    var required_str = ""
    var invalid_str = ""
    
    var loadingDialog:NBMaterialLoadingDialog!
    var payMayaToken = ""
    var cntView:UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.addBackBarBtn()
        
        cntView = self.generalFunc.loadView(nibName: "AddPaymentScreenDesign", uv: self, contentView: scrollView)
        
        
        cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
        
        self.scrollView.addSubview(cntView)
        self.scrollView.bounces = false
        
        if payMentMethod == "Adyen"
        {
            self.addTokenToServer(token: "")
        }
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
//        if(isPageLoad == false){
//            
//            cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
//            
//            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
//            
//            setData()
//            
//            isPageLoad = true
//        }
    }
    
    func setData(){
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: self.PAGE_MODE == "ADD" ? "LBL_ADD_CARD" : "LBL_CHANGE_CARD")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: self.PAGE_MODE == "ADD" ? "LBL_ADD_CARD" : "LBL_CHANGE_CARD")
        
        
        creditCardNumView.layer.shadowOpacity = 0.5
        creditCardNumView.layer.shadowOffset = CGSize(width: 0, height: 3)
        creditCardNumView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        expiryView.layer.shadowOpacity = 0.5
        expiryView.layer.shadowOffset = CGSize(width: 0, height: 3)
        expiryView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        cvvView.layer.shadowOpacity = 0.5
        cvvView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cvvView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        self.creditCardTxtField.textFieldType = "CARD"
        self.creditCardTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "Card Number", key: "LBL_CARD_NUMBER_TXT"))
        self.monthTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_EXP_MONTH_HINT_TXT"))
        self.yearTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_EXP_YEAR_HINT_TXT"))
        self.cvvTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "CVV", key: "LBL_CVV"))
        
        self.cvvTxtField.maxCharacterLimit = 5
        self.creditCardTxtField.maxCharacterLimit = 20
        self.monthTxtField.maxCharacterLimit = 2
        self.yearTxtField.maxCharacterLimit = 4
        
        self.configCardBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: self.PAGE_MODE == "ADD" ? "LBL_ADD_CARD" : "LBL_CHANGE_CARD"))
        
        required_str = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT")
        invalid_str =  self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVALID")
        
        self.configCardBtn.clickDelegate = self

        self.creditCardTxtField.getTextField()!.keyboardType = .numberPad
        self.monthTxtField.getTextField()!.keyboardType = .numberPad
        self.yearTxtField.getTextField()!.keyboardType = .numberPad
        self.cvvTxtField.getTextField()!.keyboardType = .numberPad
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.configCardBtn){
            checkData()
        }
    }
    func checkData(){
        
        let monthNum = Utils.getText(textField: self.monthTxtField.getTextField()!).isNumeric() ? GeneralFunctions.parseFloat(origValue: 0, data: Utils.getText(textField: self.monthTxtField.getTextField()!)) : 0
        
        let cardNoEntered = Utils.checkText(textField: creditCardTxtField.getTextField()!) ? (STPCardValidator.validationState(forNumber: Utils.getText(textField: self.creditCardTxtField.getTextField()!), validatingCardBrand: true) == .valid ? true : Utils.setErrorFields(textField: self.creditCardTxtField.getTextField()!, error: invalid_str)) : Utils.setErrorFields(textField: self.creditCardTxtField.getTextField()!, error: required_str)
        
        let monthEntered = Utils.checkText(textField: monthTxtField.getTextField()!) ? ((Utils.getText(textField: self.monthTxtField.getTextField()!).isNumeric() == false || Utils.getText(textField: self.monthTxtField.getTextField()!).count < 2) ? Utils.setErrorFields(textField: self.monthTxtField.getTextField()!, error: invalid_str) : ( monthNum > 12 ? Utils.setErrorFields(textField: self.monthTxtField.getTextField()!, error: invalid_str) : true)) : Utils.setErrorFields(textField: self.monthTxtField.getTextField()!, error: required_str)

        let yearEntered = Utils.checkText(textField: yearTxtField.getTextField()!) ? ((Utils.getText(textField: self.yearTxtField.getTextField()!).isNumeric() == false || Utils.getText(textField: self.yearTxtField.getTextField()!).count < 4 || Utils.getText(textField: self.yearTxtField.getTextField()!).count > 4) ? Utils.setErrorFields(textField: self.yearTxtField.getTextField()!, error: invalid_str) : true) : Utils.setErrorFields(textField: self.yearTxtField.getTextField()!, error: required_str)

        let cvvEntered = Utils.checkText(textField: cvvTxtField.getTextField()!) ? ((Utils.getText(textField: self.cvvTxtField.getTextField()!).isNumeric() == false || Utils.getText(textField: self.cvvTxtField.getTextField()!).count < 2 || Utils.getText(textField: self.cvvTxtField.getTextField()!).count > 4) ? Utils.setErrorFields(textField: self.cvvTxtField.getTextField()!, error: invalid_str) : true) : Utils.setErrorFields(textField: self.cvvTxtField.getTextField()!, error: required_str)

        if (cardNoEntered == false || cvvEntered == false || monthEntered == false || yearEntered == false) {
            return;
        }
        
        if self.payMentMethod == "Paymaya"
        {
            self.gemneratePaymayaToken()
        }else
        {
            self.generateToken()
        }
    }
    
    // FOR STRIPE
    func generateToken(){
        let cardParams = STPCardParams()
        cardParams.number = Utils.getText(textField: self.creditCardTxtField.getTextField()!)
        cardParams.expMonth = UInt(Int(Utils.getText(textField: self.monthTxtField.getTextField()!))!)
        cardParams.expYear = UInt(Int(Utils.getText(textField: self.yearTxtField.getTextField()!))!)
        cardParams.cvc = Utils.getText(textField: self.cvvTxtField.getTextField()!)
        
        
         let loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.contentView, isCancelable: false, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
             if error != nil {
                // show the error to the user
//                self.generalFunc.setError(uv: self)
                if let Msg = error?.localizedDescription{
                    let errorMsg = Msg.replace("\\", withString: "")
                    self.generalFunc.setError(uv: self, title: "", content:  errorMsg)
                }else{
                    self.generalFunc.setError(uv: self)
                }
            } else if let token = token {
                
                self.addTokenToServer(token: token.tokenId)
            }
            
            loadingDialog.hideDialog()
        }
    }
    
    // FOR PAYMAYA
    func gemneratePaymayaToken()
    {
        let dic = ["number":(Utils.getText(textField: self.creditCardTxtField.getTextField()!)).replace(" ", withString: ""),"expMonth":(Utils.getText(textField: self.monthTxtField.getTextField()!)), "expYear":(Utils.getText(textField: self.yearTxtField.getTextField()!)), "cvc":Utils.getText(textField: self.cvvTxtField.getTextField()!)]
        let cardParams = PMSDKCard.init(dictionary: dic)
        
        print(dic)
        loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.contentView, isCancelable: false, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
        
        
        PayMayaSDK.sharedInstance().createPaymentToken(from: cardParams){ (results) in
            let result = results.0
            DispatchQueue.main.async {
                self.loadingDialog.hideDialog()
              
            }
            if result?.status == PMSDKPaymentTokenStatus.created
            {
                
                var tokenObj = PMSDKPaymentToken.init()
                tokenObj = (result?.paymentToken)!
                
                self.payMayaToken = tokenObj.identifier
                
                DispatchQueue.main.async {
                    self.addTokenToServer(token: tokenObj.identifier)
                }
                
            }else
            {
                self.generalFunc.setError(uv: self)
            }
        }
    }
    
    // FOR ALL PAYMENT GATEWAY
    func addTokenToServer(token:String){
        var maskedCreditCardNo = ""
        var paymayaToken = token
        var stripeToken = token
        if self.payMentMethod == "Paymaya"
        {
            stripeToken = ""
        }
        else
        {
            paymayaToken = ""
        }
        
        let creditCardNo = Utils.getText(textField: self.creditCardTxtField.getTextField()!).replace(" ", withString: "")
        
        for i in 0 ..< creditCardNo.count {
            if(i < ((creditCardNo.count) - 4)){
                maskedCreditCardNo = maskedCreditCardNo + "X"
            }else{
                maskedCreditCardNo = maskedCreditCardNo + creditCardNo.charAt(i: i)
            }
        }
        
        let parameters = ["type":"GenerateCustomer","iUserId": GeneralFunctions.getMemberd(), "vStripeToken": stripeToken, "UserType": Utils.appUserType, "CardNo": maskedCreditCardNo, "vPaymayaToken":paymayaToken]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    if self.payMentMethod == "Paymaya" || self.payMentMethod == "Adyen"
                    {
                        self.webView.isHidden = false
                        
                        DispatchQueue.main.async {
                
                            self.activityIndicator.startAnimating()
                        }
                        
                        self.webView.loadRequest(URLRequest(url: URL(string: dataDict.get(Utils.message_str))!))
                        
                        self.webView.delegate = self
                        
                    }else
                    {
                        GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                        
                        self.paymentUv!.setData()
                        self.closeCurrentScreen()
                    }
               
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }

    // FOR PAYMAYA
    func customerVerified()
    {
        let parameters = ["type":"UpdateCustomerToken","iUserId": GeneralFunctions.getMemberd(), "vPaymayaToken": self.payMayaToken, "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            //            print("Response:\(response)")
            if(response != ""){
                self.navigationItem.setHidesBackButton(false, animated:true);
                self.view.isUserInteractionEnabled = true
                let dataDict = response.getJsonDataDict()
                
                
                if(dataDict.get("Action") == "1"){
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    self.paymentUv!.setData()
                    self.closeCurrentScreen()
                    
                }else{
                    
                    self.generalFunc.setAlertMessage(uv: nil, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                        
                        self.customerVerified()
                    })
                    
                }
                
            }else{
                self.generalFunc.setAlertMessage(uv: nil, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TRY_AGAIN_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                    self.customerVerified()
                })
            }
        })
    }
    
    // FOR PAYAMAYA & ADYEN
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url : URL? = request.url
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        print("URL : \(String(describing: url))")
        
        let urlString : String = url!.absoluteString
        
        if (urlString.contains(find: "PAYMENT_SUCCESS") || urlString.contains(find: "success") || urlString.contains(find: "success.php"))
        {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            self.navigationItem.setHidesBackButton(true, animated:false);
            self.view.isUserInteractionEnabled = false
            self.customerVerified()
            
        }else if (urlString.contains(find: "PAYMENT_FAILURE") || urlString.contains(find: "failure") || urlString.contains(find: "failure.php"))
        {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            self.generalFunc.setAlertMessage(uv: nil, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_REQUEST_FAILED_PROCESS"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                
                self.closeCurrentScreen()
            })
           
        }else
        {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
        }
    }
}
