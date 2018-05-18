//
//  LoginViewModel.swift
//  HealthcareApp
//
//  Created by mac on 5/16/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginViewModelDelegate: class {
    
    func stateChanged(to state: LoginViewModel.State)
}

@objcMembers class LoginViewModel: NSObject {
    
    @objc enum State: Int {
        case initial
        case waiting
        case invalid
        case authenticated
    }
    
    @objc dynamic var buttonText: String = "Login"
    @objc dynamic var username: String = ""
    
    var savingInfoSwitch: Bool = false
    
    var registered: Bool = false {
        didSet {
            if registered {
                handledRegistered()
            }else {
                handleUnRegistered()
            }
        }
    }
    
    weak var delegate: LoginViewModelDelegate?
    
    var state: State {
        didSet{
            delegate?.stateChanged(to: state)
        }
    }
    
    override init() {
        self.state = .initial
        registered = (UserSettings.storedUserName() != nil)
        super.init()
        savingInfoSwitch = isSavingIDSwitchOn() ?? false
        if registered {
            handledRegistered()
        }else {
            handleUnRegistered()
        }
        
        if savingInfoSwitch {
            username = getSavedID()!
        } else {
            username = ""
        }
    }
    
    func handledRegistered(){
        buttonText = "Login"
    }
    
    func handleUnRegistered(){
        buttonText = "Register"
    }
    
    func getSavedID() -> String? {
        return UserDefaults.standard.object(forKey: "savedID") as? String
    }
    
    func isSavingIDSwitchOn() -> Bool?{
        return UserDefaults.standard.object(forKey: "isSavingInfoOn") as? Bool
    }
    
    func setSavingIDSwitch(isOn: Bool){
        savingInfoSwitch = isOn
        UserDefaults.standard.set(isOn, forKey: "isSavingInfoOn")
    }
    
    func setSavedID(_ str: String) {
        UserDefaults.standard.set(str, forKey: "savedID")
    }
    
    func login(username: String, password: String){
        state = .waiting
        if !registered {
            // user is signing up
            UserSettings.saveLogin(username: username, password: password)
            state = .waiting
            state = .initial
            registered = true
            if(savingInfoSwitch){
                setSavedID(username)
            } else {
                setSavedID("")
            }
        }else {
            // user is trying to log in
            if UserSettings.login(username: username, password: password){
                state = .authenticated
                if(savingInfoSwitch) {
                    setSavedID(username)
                } else {
                    setSavedID("")
                }
            }else {
                state = .invalid
            }
        }
    }
}
