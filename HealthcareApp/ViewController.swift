//
//  ViewController.swift
//  HealthcareApp
//
//  Created by mac on 5/16/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var saveIDSwitch: UISwitch!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    let viewModel = LoginViewModel()
    var observations: [NSKeyValueObservation] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.hidesWhenStopped = true
        viewModel.delegate = self
        saveIDSwitch.setOn(viewModel.savingInfoSwitch, animated: true)
        setupBindings()
        loginButton.setTitle(viewModel.buttonText, for: .normal)
        usernameField.text = viewModel.username
    }
    
    func setupBindings(){
        
        observations.append(viewModel.observe(\.buttonText, options: [.new]) { [weak self] _, change in
            guard let text = change.newValue else { return }
            self?.loginButton.setTitle(text, for: .normal)
        })
        
        observations.append(viewModel.observe(\.username, options: [.new]) { [weak self] _, change in
            guard let text = change.newValue else { return }
                self?.usernameField.text = text
        })
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        viewModel.setSavingIDSwitch(isOn: saveIDSwitch.isOn)
        guard let username = usernameField.text,
            let password = passwordField.text else {
                return
        }

        viewModel.login(username: username, password: password)
 
    }
}

extension ViewController: LoginViewModelDelegate {
    
    struct Route {
        static let login = "LoginSegue"
    }
    
    func stateChanged(to state: LoginViewModel.State) {
        switch state {
        case .initial:
            setInitialState()
        case .waiting:
            setWaitingState()
        case .invalid:
            setInvalidState()
        case .authenticated:
            setAuthenticatedState()
        }
    }
    
    func setAuthenticatedState(){
        performSegue(withIdentifier: Route.login, sender: nil)
    }
    
    func switchToLogin(){
        loginButton.setTitle(viewModel.buttonText, for: .normal)
    }
    
    func setInvalidState(){
        activityIndicator.stopAnimating()

        let ac = UIAlertController(title: "Error", message: "Could Not Log In", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "Ok", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
    }
    
    func setInitialState(){
        activityIndicator.stopAnimating()
    }
    
    func setWaitingState(){
        activityIndicator.startAnimating()
        switchToLogin()
        activityIndicator.stopAnimating()
    }
}

