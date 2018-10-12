//
//  OpenTollBox.swift
//  PassengerApp
//
//  Created by ADMIN on 29/07/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class OpenTollBox: NSObject, MyBtnClickDelegate, MyLabelClickDelegate {
    typealias CompletionHandler = (_ isContinueBtnTapped:Bool, _ isTollSkipped:Bool) -> Void
    
    var uv:UIViewController!
    var containerView:UIView!
    
    var currentInst:OpenTollBox!
    
    let generalFunc = GeneralFunctions()
    
    var tollDesignView:TollDesignView!
    var tollDesignBGView:UIView!
    
    var handler:CompletionHandler!
    
    init(uv:UIViewController, containerView:UIView){
        self.uv = uv
        self.containerView = containerView	
        super.init()
    }
    
    func setViewHandler(handler: @escaping CompletionHandler){
        self.handler = handler
    }
    
    func show(tollPrice:String, currentFare:String){
        let width = Application.screenSize.width - 50
        let height = 390 + self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TOLL_PRICE_DESC").height(withConstrainedWidth: width - 30, font: UIFont(name: "Roboto-Light", size: 17)!) + (self.generalFunc.getLanguageLabel(origValue: "Total toll price:", key: "LBL_TOLL_PRICE_TOTAL").height(withConstrainedWidth: width - 30, font: UIFont(name: "Roboto-Light", size: 17)!)) - 40
        
        tollDesignView = TollDesignView(frame: CGRect(x:0, y:0, width: width, height: height))
        
        tollDesignView.frame.size = CGSize(width: width, height: height)
        
        tollDesignView.center = CGPoint(x: Application.screenSize.width / 2, y: self.containerView.frame.height / 2)
        
        let bgView = UIView()
        
        bgView.frame = CGRect(x:0, y:0, width:Application.screenSize.width, height: self.containerView.frame.height)
        
        bgView.center = CGPoint(x: Application.screenSize.width / 2, y: self.containerView.frame.height / 2)
        
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.80
        bgView.isUserInteractionEnabled = true
        
        self.tollDesignBGView = bgView
        
        self.tollDesignView.tollDescriptionLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TOLL_PRICE_DESC")
        self.tollDesignView.tollDescriptionLbl.fitText()
        
        var priceStr = currentFare
        if(priceStr != ""){
            priceStr = "\(self.generalFunc.getLanguageLabel(origValue: "Current Fare", key: "LBL_CURRENT_FARE")): \(priceStr)\n+\n"
        }
        
        self.tollDesignView.priceLbl.text = priceStr + self.generalFunc.getLanguageLabel(origValue: "Total toll price:", key: "LBL_TOLL_PRICE_TOTAL") + ": " + tollPrice
        self.tollDesignView.priceLbl.fitText()
        
        
        //        self.view.addSubview(bgView)
        //        self.view.addSubview(bookingFinishView)
        
        //        let currentWindow = Application.window
        //
        //        if(currentWindow != nil){
        //            currentWindow?.addSubview(bgView)
        //            currentWindow?.addSubview(enableLocationView)
        //        }else{
        self.uv.view.addSubview(bgView)
        self.uv.view.addSubview(tollDesignView)
        //        }
        bgView.alpha = 0
        self.tollDesignView.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                bgView.alpha = 0.80
                self.tollDesignView.alpha = 1
                
        }
        )
        Utils.createRoundedView(view: tollDesignView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        tollDesignView.ignoreTollRouteLbl.text = self.generalFunc.getLanguageLabel(origValue: "Ignore toll route", key: "LBL_IGNORE_TOLL_ROUTE")
        
        tollDesignView.layer.shadowOpacity = 0.5
        tollDesignView.layer.shadowOffset = CGSize(width: 0, height: 3)
        tollDesignView.layer.shadowColor = UIColor.black.cgColor
        
        tollDesignView.continueBtn.clickDelegate = self
        tollDesignView.cancelLbl.setClickDelegate(clickDelegate: self)
        
        tollDesignView.ignoreTollChkBox.boxType = .square
        tollDesignView.ignoreTollChkBox.offAnimationType = .bounce
        tollDesignView.ignoreTollChkBox.onAnimationType = .bounce
        tollDesignView.ignoreTollChkBox.onCheckColor = UIColor.UCAColor.AppThemeTxtColor
        tollDesignView.ignoreTollChkBox.onFillColor = UIColor.UCAColor.AppThemeColor
        tollDesignView.ignoreTollChkBox.onTintColor = UIColor.UCAColor.AppThemeColor
        tollDesignView.ignoreTollChkBox.tintColor = UIColor.UCAColor.AppThemeColor_1
        
    }
        
    func closeView(){
        tollDesignView.frame.origin.y = Application.screenSize.height + 2500
        tollDesignView.removeFromSuperview()
        tollDesignBGView.removeFromSuperview()
    }
    
    func myBtnTapped(sender: MyButton) {
        if(self.tollDesignView != nil && sender == self.tollDesignView.continueBtn){
            
            if(self.handler != nil){
                self.handler(true, tollDesignView.ignoreTollChkBox.on)
            }
            
            closeView()
        }
    }
    
    func myLableTapped(sender: MyLabel) {
        if(self.tollDesignView != nil && sender == self.tollDesignView.cancelLbl){
            
            if(self.handler != nil){
                self.handler(false, tollDesignView.ignoreTollChkBox.on)
            }
            closeView()
        }

    }
}
