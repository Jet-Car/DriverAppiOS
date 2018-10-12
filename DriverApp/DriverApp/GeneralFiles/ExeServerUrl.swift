//
//  ExeServerUrl.swift
//  DriverApp
//
//  Created by ADMIN on 24/12/16.
//  Copyright © 2016 BBCS. All rights reserved.
//

import UIKit

/**
 This class will communicate to server and pass required data to server and fetch response from server and then pass response in the format of string to caller in completion handler.
*/
class ExeServerUrl: NSObject {
    /**
     Response of webservice is passed to this handler.
    */
    typealias CompletionHandler = (_ response:String) -> Void
    
    /**
     Post parameters which are going to be pass to server. This will only applies to post connection made for application's server.
    */
    var dict_data:[String: String]?
    
    /**
     If set to true (defaults true), a loader is shown in a particular view.
    */
    var isOpenLoader = true
    
    /**
     Instance of loading dialog.
    */
    var loadingDialog:NBMaterialLoadingDialog!
   
    /**
     Instance of view hoalder for loading dialog.
    */
    var currentView:UIView!
    
    /**
     If set to true (defaults true), registration token (Used for push notification) will be generated and will be include in post parameters.
    */
    var isDeviceTokenGenerate = false
    
    /**
     This will holds post parameters. Internal purpose only.
    */
    var currentPostString = ""
    
    /**
     This will holds Response handler. Internal purpose only.
    */
    var currCompletionHandler:CompletionHandler!
    
    /**
     This will holds current URL request. Internal purpose only.
    */
    var currRequest:NSMutableURLRequest!
    
    /**
     This will holds current instance of post/get request. If variable 'isDeviceTokenGenerate' set to true then this must be supplied.
    */
    var currInstance:ExeServerUrl!
    
    /**
     This will holds current URL session task. Internal purpose only. By using this, we can cancel on going task.
    */
    var currentTask:URLSessionDataTask!
    
    /**
     Indicates that current task is killed or not (default set to false). If set to true then instance of request will not dispatch request to CompletionHandler.
    */
    var isTaskKilled = false
    
    /**
     A constructor - used when initializing a class
     - parameters:
        - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
        - currentView: View that holds loader.
        - isOpenLoader: Show Loading indictor or not for current request. This must be false if request is called from frequent task. Because frequent task           is performed in background without user interaction.
        - isDeviceTokenGenerate: Pass true if device token (Registration id - to be used for push notification) to generate for request or not. If true is pass then **currInstance* variable must be set.
    */
    init(dict_data: [String: String], currentView:UIView, isOpenLoader:Bool) {
        self.dict_data = dict_data
        self.isOpenLoader = isOpenLoader
        self.currentView = currentView
        super.init()
    }
    
    /**
     A constructor - used when initializing a class
     - parameters:
        - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
        - currentView: View that holds loader.
        - isOpenLoader: Show Loading indictor or not for current request. This must be false if request is called from frequent task. Because frequent task           is performed in background without user interaction.
        - isDeviceTokenGenerate: Pass true if device token (Registration id - to be used for push notification) to generate for request or not. If true is pass then **currInstance* variable must be set.
    */
    init(dict_data: [String: String], currentView:UIView, isOpenLoader:Bool, isDeviceTokenGenerate:Bool) {
        self.dict_data = dict_data
        self.isOpenLoader = isOpenLoader
        self.currentView = currentView
        self.isDeviceTokenGenerate = isDeviceTokenGenerate
        super.init()
    }
    
    /**
     A constructor - used when initializing a class
     - parameters:
        - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
        - currentView: View that holds loader.
    */
    init(dict_data: [String:String], currentView:UIView) {
        self.dict_data = dict_data
        self.currentView = currentView
        super.init()
    }
    
    /**
     This will create a singlton instance of this class.
    */
    static func getInstance(dict_data: [String:String], currentView:UIView, isOpenLoader:Bool, isDeviceTokenGenerate:Bool) -> ExeServerUrl{
        return ExeServerUrl(dict_data: dict_data, currentView: currentView, isOpenLoader: isOpenLoader, isDeviceTokenGenerate: isDeviceTokenGenerate)
    }

    /**
     This will set true/false value to variable 'isDeviceTokenGenerate'.
     - Parameters:
        - isDeviceTokenGenerate: If set to true (defaults true), registration token (Used for push notification) will be generated and will be include in post parameters.
    */
    func setDeviceTokenGenerate(isDeviceTokenGenerate:Bool){
        self.isDeviceTokenGenerate = isDeviceTokenGenerate
    }
    
    /**
     This will create a post connection to application's server.
     - Parameters:
        - completionHandler: Response of current request is dispatched to this handler.
    */
    func executePostProcess(completionHandler: @escaping CompletionHandler) {
        
        isTaskKilled = false
        
        var firstParam = true
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, isCancelable: false, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
            }
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: CommonUtils.webservice_path)! as URL)
        
        request.httpMethod = "POST"
        
        var postString = ""
        
        for (key, value) in dict_data! {
            if(firstParam == true){
                postString = "\(key)=\(value)"
                firstParam = false
            }else{
                postString = "\(postString)&\(key)=\(value)"
            }
        }
        
        postString = postString + "&Platform=IOS"

        if(isDeviceTokenGenerate == false){
            continuePostProcess(postString: postString, request: request, completionHandler: completionHandler)
        }else{
            self.currentPostString = postString
            self.currRequest = request
            self.currCompletionHandler = completionHandler
            
            NotificationCenter.default.addObserver(currInstance!, selector: #selector(currInstance!.apnIdReceivedCallback(sender:)), name: NSNotification.Name(rawValue: Utils.apnIDNotificationKey), object: nil)
            
            GeneralFunctions.registerRemoteNotification()
        }
        
    }
    
    /**
     When registration token is generated this function will be called and process will continue. (For Internal use only)
     - Parameters:
        - sender: Holds data of notification along with NSNotification instance.
    */
    func apnIdReceivedCallback(sender: NSNotification){
        let userInfo = sender.userInfo
        let apnId_str = userInfo!["body"] as! String
//        let fcmDeviceToken = userInfo!["FCMToken"] as! String
        
        GeneralFunctions.saveValue(key: Utils.deviceTokenKey, value: apnId_str as AnyObject)
        GeneralFunctions.removeObserver(obj: self)
        GeneralFunctions.removeObserver(obj: currInstance!)
        
        currentPostString = currentPostString + "&vDeviceToken=\(apnId_str)"
//        &vFirebaseDeviceToken=\(fcmDeviceToken)
        continuePostProcess(postString: self.currentPostString, request: self.currRequest, completionHandler: self.currCompletionHandler)
    }
    
    /**
     This will create a post connection to server and pass data to server. Internal use only.
    */
    private func continuePostProcess(postString:String, request: NSMutableURLRequest, completionHandler: @escaping CompletionHandler){
        
        /**
         A general parameters that needs to be pass along with existing parameters.
        */
        let postString = postString + "&tSessionId=\(GeneralFunctions.getSessionId())&GeneralMemberId=\(GeneralFunctions.getMemberd())&GeneralUserType=\(Utils.appUserType)&GeneralDeviceType=\(Utils.deviceType)&GeneralAppVersion=\(Utils.applicationVersion())&vTimeZone=\(DateFormatter().timeZone.identifier)&vUserDeviceCountry=\(Utils.getDeviceCountryCode())"
        
        Utils.printLog(msgData: "postString:\(postString)")
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            
            var dataString = ""
            
            if(data == nil){
                dataString = ""
            }else{
                dataString =  String(data: data!, encoding: String.Encoding.utf8)!
            }
            
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
                if(self.isTaskKilled == false){
                    completionHandler(dataString.trim())
                }
            }
            
        })
        
        task.resume()
        
        self.currentTask = task
    }
    
    /**
     This will create a get request to particular url. All direct url like calling google's direction api etc must use this function.
     - Parameters:
        - completionHandler: Response of current request will be passed to this handler.
        - url: Request url from which data needs.
    */
    func executeGetProcess(completionHandler: @escaping CompletionHandler, url:String) {
        
        isTaskKilled = false
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                /**
                 Create and show loader for this request.
                */
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, isCancelable: false, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
            }
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)! as URL)

        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            var dataString = ""
            
            if(data == nil){
                dataString = ""
            }else{
                dataString =  String(data: data!, encoding: String.Encoding.utf8)!
            }
            
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
                if(self.isTaskKilled == false){
                    completionHandler(dataString.trim())
                }
            }
            
        })
        
        task.resume()
        
        self.currentTask = task
        
    }
    
    /**
     By using this fuction, we are able to upload image or any file as multipart data along with parameters to server.
     - Parameters:
        - fileData: instance of data which needs to be uploaded on server.
        - completionHandler: Response of current request will be passed to this handler.
    */
    func uploadImage(fileData:Data?, fileName:String, completionHandler: @escaping CompletionHandler){
        let boundary = GeneralFunctions.generateBoundaryString()
        
        let request = NSMutableURLRequest(url: NSURL(string: CommonUtils.webservice_path)! as URL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

//        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        if(fileData==nil)  {
            DispatchQueue.main.async() {
                completionHandler("")
            }
            return
        }
        
        /**
         A general parameters that needs to be pass along with existing parameters.
        */
        dict_data?["tSessionId"] = "\(GeneralFunctions.getSessionId())"
        dict_data?["GeneralMemberId"] = "\(GeneralFunctions.getMemberd())"
        dict_data?["GeneralUserType"] = "\(Utils.appUserType)"
        dict_data?["GeneralDeviceType"] = "\(Utils.deviceType)"
        dict_data?["GeneralAppVersion"] = "\(Utils.applicationVersion())"
        dict_data?["vTimeZone"] = "\(DateFormatter().timeZone.identifier)"
        
        request.httpBody = GeneralFunctions.createBodyWithParameters(dict_data, filePathKey: "vImage", imageDataKey: fileData!, boundary: boundary, fileName: fileName)
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                /**
                 Create and show loader for this request.
                */
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, isCancelable: false, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
            }
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            
            var dataString = ""
            
            if(data == nil){
                dataString = ""
            }else{
                dataString =  String(data: data!, encoding: String.Encoding.utf8)!
            }
            
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
                completionHandler(dataString.trim())
            }
            
        })
        
        task.resume()

        
        self.currentTask = task
    }
    
    /**
     This function will cancel current request. If called then current request will not dispatche its response.
    */
    func cancel(){
        self.isTaskKilled = true
        if(currentTask != nil){
            self.currentTask.cancel()
        }
    }

}
