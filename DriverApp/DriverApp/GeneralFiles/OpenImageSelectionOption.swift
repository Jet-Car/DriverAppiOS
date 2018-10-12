//
//  OpenImageSelectionOption.swift
//  DriverApp
//
//  Created by ADMIN on 16/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos


class OpenImageSelectionOption: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, CropViewControllerDelegate, UIDocumentMenuDelegate {
    
    typealias ImageUploadCompletionHandler = (_ isImageUpload:Bool) -> Void
    typealias ImageSelectedCompletionHandler = (_ isImageSelected:Bool) -> Void
    
    var uv:UIViewController!
    
    let generalFunc = GeneralFunctions()
    
    var overlayView:UIView!
    var selectionAreaView:UIView!
    
    var loadingDialog:NBMaterialLoadingDialog!
    
    var imageUploadCompletionHandler:ImageUploadCompletionHandler!
    var imageSelectedCompletionHandler:ImageSelectedCompletionHandler!
    
    var isDocumentUpload = false
    var isUFXServicePhotoChoose = false
    var isChooseCategory = false
    
    var dict_data: [String: String]!
    var selectedFileData:Data!
    
    var fileData:String!
    var fileName = NSString()
    var fileExtension:String!
    
    var cameraTapGue = UITapGestureRecognizer()
    var gallaryTapGue = UITapGestureRecognizer()
    var docPickerTapGue = UITapGestureRecognizer()
    var closeTapGue = UITapGestureRecognizer()
    
    init(uv: UIViewController) {
        self.uv = uv
        super.init()
    }
    
    init(uv: UIViewController, dict_data: [String: String]) {
        self.uv = uv
        self.dict_data = dict_data
        super.init()
    }
    
    func setDataParams(dict_data: [String: String]){
        self.dict_data = dict_data
    }
    
    func setImageSelectionHandler(imageSelectedCompletionHandler:@escaping ImageSelectedCompletionHandler){
        self.imageSelectedCompletionHandler = imageSelectedCompletionHandler
    }
    func setImageUploadHandler(imageUploadCompletionHandler:@escaping ImageUploadCompletionHandler){
        self.imageUploadCompletionHandler = imageUploadCompletionHandler
    }
    
    func show(imageUploadCompletionHandler:@escaping ImageUploadCompletionHandler){
        
        self.imageUploadCompletionHandler = imageUploadCompletionHandler
        
        if(isChooseCategory == true){
            let chooseDocumentOptionView = self.generalFunc.loadView(nibName: "ChooseDocumentOptionView")
            chooseDocumentOptionView.frame = CGRect(x:0, y: self.uv.view.frame.height - 100, width: Application.screenSize.width, height: 100)
            
            let overlayView = UIView()
            overlayView.frame = CGRect(x:0, y: 0, width: self.uv.view.frame.width, height: self.uv.view.frame.height)
            
            overlayView.backgroundColor = UIColor.black
            overlayView.alpha = 0.4
            self.overlayView = overlayView
            
            self.uv.view.addSubview(overlayView)
            
            chooseDocumentOptionView.layer.shadowOpacity = 0.5
            chooseDocumentOptionView.layer.shadowOffset = CGSize(width: 0, height: 3)
            chooseDocumentOptionView.layer.shadowColor = UIColor.black.cgColor
            
            self.selectionAreaView = chooseDocumentOptionView
            self.uv.view.addSubview(chooseDocumentOptionView)
            
            (chooseDocumentOptionView.subviews[0].subviews[0] as! MyLabel).text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CHOOSE_CATEGORY")
      
            cameraTapGue.addTarget(self, action: #selector(self.cameraTapped))
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[0].isUserInteractionEnabled = true
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[0].addGestureRecognizer(cameraTapGue)
            
            gallaryTapGue.addTarget(self, action: #selector(self.gallaryTapped))
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[1].isUserInteractionEnabled = true
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[1].addGestureRecognizer(gallaryTapGue)
            
            docPickerTapGue.addTarget(self, action: #selector(self.docPickerTapped))
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[2].isUserInteractionEnabled = true
            chooseDocumentOptionView.subviews[0].subviews[1].subviews[2].addGestureRecognizer(docPickerTapGue)
            
            closeTapGue.addTarget(self, action: #selector(self.closeSlectionView))
            chooseDocumentOptionView.subviews[1].isUserInteractionEnabled = true
            chooseDocumentOptionView.subviews[1].addGestureRecognizer(closeTapGue)
        }else{
            let chooseImageOptionView = self.generalFunc.loadView(nibName: "ChooseImageOptionView")
            chooseImageOptionView.frame = CGRect(x:0, y: self.uv.view.frame.height - 80, width: Application.screenSize.width, height: 80)
            
            let overlayView = UIView()
            overlayView.frame = CGRect(x:0, y: 0, width: self.uv.view.frame.width, height: self.uv.view.frame.height)
            
            overlayView.backgroundColor = UIColor.black
            overlayView.alpha = 0.4
            self.overlayView = overlayView
            
            self.uv.view.addSubview(overlayView)

            chooseImageOptionView.layer.shadowOpacity = 0.5
            chooseImageOptionView.layer.shadowOffset = CGSize(width: 0, height: 3)
            chooseImageOptionView.layer.shadowColor = UIColor.black.cgColor
            
            self.selectionAreaView = chooseImageOptionView
            self.uv.view.addSubview(chooseImageOptionView)
            
            (chooseImageOptionView.subviews[0] as! MyLabel).text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CHOOSE_CATEGORY")
            
            cameraTapGue.addTarget(self, action: #selector(self.cameraTapped))
            chooseImageOptionView.subviews[1].isUserInteractionEnabled = true
            chooseImageOptionView.subviews[1].addGestureRecognizer(cameraTapGue)
            
            gallaryTapGue.addTarget(self, action: #selector(self.gallaryTapped))
            chooseImageOptionView.subviews[2].isUserInteractionEnabled = true
            chooseImageOptionView.subviews[2].addGestureRecognizer(gallaryTapGue)
            
            closeTapGue.addTarget(self, action: #selector(self.closeSlectionView))
            chooseImageOptionView.subviews[3].isUserInteractionEnabled = true
            chooseImageOptionView.subviews[3].addGestureRecognizer(closeTapGue)
        }
    }
    
    func closeSlectionView(){
        if(self.overlayView == nil || self.selectionAreaView == nil){
            return
        }
        self.overlayView!.removeFromSuperview()
        self.selectionAreaView!.removeFromSuperview()
    }
    
    func cameraTapped(){
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
//            imagePickerController.allowsEditing = true
            self.uv.present(imagePickerController, animated: true, completion: nil)
        }else{
            generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOT_SUPPORT_CAMERA_TXT"))
        }
        
    }
    
    func gallaryTapped(){
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
//            imagePickerController.allowsEditing = true
            Configurations.setAppThemeNavBar()
            self.uv.present(imagePickerController, animated: true, completion: nil)
        }else{
            generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOT_SUPPORT_GALLARY_TXT"))
        }
    }
    
    func docPickerTapped(){
        let types: [String] = [(kUTTypeContent as String), (kUTTypeImage as String), (kUTTypeJPEG as String), (kUTTypePNG as String), (kUTTypePDF as String)]
        let documentMenuVC = UIDocumentMenuViewController(documentTypes: types, in: .import)
        documentMenuVC.delegate = self
        documentMenuVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        UINavigationBar.appearance().backgroundColor = UIColor.UCAColor.documentPickerNavColor
        UIBarButtonItem.appearance().tintColor = UIColor.UCAColor.documentPickerNavColor
        
        self.uv.present(documentMenuVC, animated: true, completion: nil)
    }
    
    //MARK - DocumentPickerView Delegate & Datasource Methods
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.uv
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            DispatchQueue.main.async {

                self.fileName = ""
                self.fileName = (url.lastPathComponent as NSString)

                Utils.printLog(msgData: "FileName::\(self.fileName)::FileExtension\(self.fileName.pathExtension)")

                if(self.fileName.pathExtension == "numbers" || self.fileName.pathExtension == "key" || self.fileName.pathExtension == "pages" || self.fileName.pathExtension == "txt"){
                    self.closeSlectionView()
                    self.fileName = ""
                    self.generalFunc.setAlertMessage(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DOC_UPLOAD_ERROR_"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    })
                }else{
                    if(self.isDocumentUpload == true){
                        let dataTake = NSData(contentsOf: url) as Data?
                        
                        Utils.printLog(msgData: "DataTake::\(String(describing: dataTake))")

                        if(self.imageSelectedCompletionHandler != nil){
                            self.imageSelectedCompletionHandler(true)
                        }
                        self.requestUploadDocument(data: dataTake!)
                    }
                }
            }
        }
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        Utils.printLog(msgData: "WillBeginSendingToApplication")
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        Utils.printLog(msgData: "We're done sending the document.")
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.uv.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        Configurations.setAppThemeNavBar()
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        Configurations.setAppThemeNavBar()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        var selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = selectedImage.correctlyOrientedImage()
        
        var imgExtension : String!
        
        if picker.sourceType == UIImagePickerControllerSourceType.camera {
            self.fileName = String(format:"doc_img.png") as NSString
        }else {
            let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
            imgExtension = ((assetPath.absoluteString?.components(separatedBy: ("ext="))[1])?.lowercased())!
            self.fileName = String(format:"doc_img.%@", imgExtension) as NSString
        }
        
        picker.dismiss(animated: true, completion: {
            if(self.isDocumentUpload == true){
                if(self.imageSelectedCompletionHandler != nil){
                    self.imageSelectedCompletionHandler(true)
                }
                
                DispatchQueue.main.async() {
                    self.requestUploadDocument(data: UIImageJPEGRepresentation(selectedImage, 1.0)!)
                }
                
            }else if(self.isUFXServicePhotoChoose == true){
                
                self.selectedFileData = UIImageJPEGRepresentation(selectedImage, 1.0)!
                
                
                if(self.imageSelectedCompletionHandler != nil){
                    self.imageSelectedCompletionHandler(true)
                }
                
                self.closeSlectionView()
                
            }else{
                if(selectedImage.size.width < Utils.ImageUpload_MINIMUM_WIDTH || selectedImage.size.height < Utils.ImageUpload_MINIMUM_HEIGHT){
                    self.generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MIN_RES_IMAGE"))
                    return
                }
                
                if(self.imageSelectedCompletionHandler != nil){
                    self.imageSelectedCompletionHandler(true)
                }
                
                DispatchQueue.main.async() {
                    let cropViewController = CropViewController(image: selectedImage)
                    cropViewController.delegate = self
                    cropViewController.customAspectRatio = CGSize(width: 1024, height: 1024)
                    
                    cropViewController.aspectRatioLockEnabled = true
                    cropViewController.aspectRatioPickerButtonHidden = true
                    cropViewController.resetAspectRatioEnabled = false
                    cropViewController.showActivitySheetOnDone = false
                    
                    cropViewController.cancelButtonTitle = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT")
                    cropViewController.doneButtonTitle = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DONE")
                    self.uv.present(cropViewController, animated: true, completion: nil)
                }
                
                
//                DispatchQueue.main.async() {
//
//                    let fileData = UIImageJPEGRepresentation(selectedImage.correctlyOrientedImage().cropTo(size: CGSize(width: Utils.ImageUpload_DESIREDWIDTH, height: Utils.ImageUpload_DESIREDHEIGHT)), 1.0)!
//                    self.requestUploadImage(fileData: fileData, fileName: "UserImage.png")
//                }
            }
            
        })
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true, completion: {
            DispatchQueue.main.async() {
                if(image.size.width < Utils.ImageUpload_MINIMUM_WIDTH || image.size.height < Utils.ImageUpload_MINIMUM_HEIGHT){
                    self.generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MIN_RES_IMAGE"))
                    return
                }else{
                    let fileData = UIImageJPEGRepresentation(image.correctlyOrientedImage().cropTo(size: CGSize(width: Utils.ImageUpload_DESIREDWIDTH, height: Utils.ImageUpload_DESIREDHEIGHT)), 1.0)!
                    self.requestUploadImage(fileData: fileData, fileName: "UserImage.png")
                }
            }
        })
    }
    
    func requestUploadImage(fileData:Data, fileName:String){
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        let SITE_TYPE_DEMO_MSG = userProfileJson.get("SITE_TYPE_DEMO_MSG")
        
        //        if let SITE_TYPE = GeneralFunctions.getValue(key: Utils.SITE_TYPE_KEY) as? String{
        //            if(SITE_TYPE == "Demo"){
        //                self.generalFunc.setError(uv: self.uv, title: "", content: SITE_TYPE_DEMO_MSG)
        //                return
        //            }
        //        }
        
        if let SITE_TYPE = GeneralFunctions.getValue(key: Utils.SITE_TYPE_KEY) as? String{
            if(SITE_TYPE == "Demo" && userProfileJson.get("vEmail") == "driver@gmail.com"){
                self.generalFunc.setError(uv: self.uv, title: "", content: SITE_TYPE_DEMO_MSG)
                return
            }
        }
        
        myImageUploadRequest(image: fileData, fileName: fileName)
    }
    
    func myImageUploadRequest(image:Data, fileName:String){
        let myUrl = URL(string: CommonUtils.webservice_path)
        
        let request = NSMutableURLRequest(url:myUrl!);
        request.httpMethod = "POST"
        
        let parameters = [
            "type"  : "uploadImage",
            "MemberType"    : Utils.appUserType,
            "iMemberId"    : GeneralFunctions.getMemberd()
        ]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.uv.view, isOpenLoader: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.uploadImage(fileData:image, fileName: fileName, completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    
                    self.closeSlectionView()
                    
                    if(self.imageUploadCompletionHandler != nil){
                        self.imageUploadCompletionHandler(true)
                    }
                }else{
                    self.generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self.uv)
            }
        })
    }
    
    func requestUploadDocument(data:Data){
        self.selectedFileData = data
        //        myDocUploadRequest(image: image)
        
        closeSlectionView()
    }
    
    func myDocUploadRequest(fileData:Data, fileName:String){
        let myUrl = URL(string: CommonUtils.webservice_path)
        
        let request = NSMutableURLRequest(url:myUrl!);
        request.httpMethod = "POST"
        
        Utils.printLog(msgData: "SelectedFileName::\(fileName)")
        
        let exeWebServerUrl = ExeServerUrl(dict_data: dict_data, currentView: self.uv.view, isOpenLoader: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.uploadImage(fileData: fileData, fileName: fileName, completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    self.closeSlectionView()
                    
                    if(self.imageUploadCompletionHandler != nil){
                        self.imageUploadCompletionHandler(true)
                    }
                }else{
                    self.generalFunc.setError(uv: self.uv, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self.uv)
            }
        })
    }
}

extension Data {
    var format: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xff:
            ext = ".jpeg"
            break
        case 0x25:
            ext = ".pdf"
            break
        case 0x46:
            ext = ".txt"
            break
        case 0x47:
            ext = ".gif"
            break
        case 0x89:
            ext = ".png"
            break
        case 0x49, 0x4d:
            ext = ".tiff"
            break
        default:
            ext = ".doc"
        }
        return ext
    }
}
