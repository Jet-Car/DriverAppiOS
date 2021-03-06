//
//  UpdateFreqTask.swift
//  DriverApp
//
//  Created by ADMIN on 25/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

@objc protocol OnTaskRunCalledDelegate:class
{
    func onTaskRun(currInst:UpdateFreqTask)
}

class UpdateFreqTask: NSObject {
    
    var interval:CGFloat?
    
    //    var onTaskRunCalled:OnTaskRunCalledDelegate!
    weak var onTaskRunCalled:OnTaskRunCalledDelegate?
    
    var isFirstRun = true
    var isAvoidFirstRun = false
    var isKilled = false
    
    var currInst:UpdateFreqTask!
    
    var freqTimer:Timer!
    
    init(interval:CGFloat) {
        self.interval = interval
        super.init()
    }
    
    func setTaskRunListener(onTaskRunCalled:OnTaskRunCalledDelegate){
        self.onTaskRunCalled = onTaskRunCalled
    }
    
    func startRepeatingTask(){
        isKilled = false
        isFirstRun = true
        //        onTaskRun()
                
        DispatchQueue.main.async() {
            self.start()
        }
    }
    
    func start(){
        if(self.freqTimer != nil){
            self.freqTimer.invalidate()
            self.freqTimer = nil
        }
        
        
        self.freqTimer =  Timer.scheduledTimer(timeInterval: Double(self.interval!), target: self.currInst, selector: #selector(self.currInst.onTaskRun), userInfo: nil, repeats: true)
        //            self.freqTimer = Timer(fireAt: Date(), interval: 25.0, target: self.currInst, selector: #selector(self.currInst.onTaskRun), userInfo: nil, repeats: true)
        self.freqTimer.fire()
    }
    
    func onTaskRun(){
        
        if(isKilled == true){
            return
        }
        
        if(isFirstRun == true && isAvoidFirstRun == false){
            isFirstRun = false
            DispatchQueue.main.async  {
                self.callDelegate()
                
            }
        }else{
            self.isAvoidFirstRun = false
            
            if(self.isKilled != true){
                DispatchQueue.main.async  {
                    self.callDelegate()
                    
                }
//                self.callDelegate()
            }
            
            //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(interval!) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            //                if(self.isKilled != true){
            //                    self.callDelegate()
            //                }
            //            })
        }
        
    }
    
    func callDelegate(){
        onTaskRunCalled?.onTaskRun(currInst: currInst)
//        onTaskRun()
    }
    
    func stopRepeatingTask(){
        self.isKilled = true
        if(freqTimer != nil){
            freqTimer.invalidate()
        }
    }
    
}

