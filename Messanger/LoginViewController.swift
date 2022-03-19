//
//  ViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 1.01.2022.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    //Mark: Outlet
    
    //Label
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabelOutlet: UILabel!
    @IBOutlet weak var dontHaveAccountLabelOutlet: UILabel!
    @IBOutlet weak var loginHeaderLabel: UILabel!
    
    //Textfield
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Button
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var reSendEmailButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    

    //View
    @IBOutlet weak var resendLineView: UIView!
    var isLogin : Bool =  true
    
    
    //Mark View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUIFor(login: isLogin)
        setupTetxField()
        //setupBackgroungTab()
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if isDataInteraptedFor(type: isLogin ?  "login" : "register") {
            
            isLogin ? loginUser() : registerUser()
            
        }
        else {
        ProgressHUD.showFailed("All fields required")
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        if isDataInteraptedFor(type: "Password"){
           resetPassword()
        }
        else {
        ProgressHUD.showFailed("email is required")
        }
    }
    
    @IBAction func reSendEmailAction(_ sender: Any) {
        if isDataInteraptedFor(type: "Password"){
           resendVerifcationEmail()
        }
        else {
        ProgressHUD.showFailed("email is required")
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    //Mark : Setup
    
    private func setupTetxField(){
        emailTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
    }
    
    private func updateUIFor(login:Bool){
        loginButton.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal )
        signUpButton.setTitle(login ? "SignUp": "Login" , for: .normal)
        dontHaveAccountLabelOutlet.text = login ? "Don't have an account" : "Have an account"
        
        UIView.animate(withDuration:0.5){
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabelOutlet.isHidden = login
            self.resendLineView.isHidden  = login
        }
        
    }
    
    private func setupBackgroungTab(){
        let bgGesture = UIGestureRecognizer(target: self, action: #selector(endEditing))
        
        view.addGestureRecognizer(bgGesture)
    }
    
   @objc func endEditing(){
        view.endEditing(false)
    }
    
    @objc func textFieldChange(_ textField: UITextField){
        
        switch textField {
        case emailTextField:
            emailLabelOutlet.text = emailTextField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = passwordTextField.hasText ? "Password" : ""
        default:
            repeatPasswordLabelOutlet.text = repeatPasswordTextField.hasText ? "Repeat Password" : ""
        }
    }
    
    
    private func isDataInteraptedFor(type: String) -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "register":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
          return  emailTextField.text != nil
            
            
            
        }
    }
    
    private func resetPassword(){
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email")
            } else {
                ProgressHUD.showFailed(error.debugDescription)
            }
            
        }
    }
    
    private func resendVerifcationEmail(){
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("Email sent again")
            }
            else {
                ProgressHUD.showFailed(error.debugDescription)
            }
        }
    }
    
    private func registerUser(){
        
        if passwordTextField.text == repeatPasswordTextField.text {
            
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                if error == nil {
                   ProgressHUD.showSuccess("Verification email sent")
                    self.reSendEmailButton.isHidden = false
                } else {
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
            
            
        } else {
           ProgressHUD.showError("The Passwords don't match")
        }
        
    }
    
    private func loginUser(){
        
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            if error == nil {
                if isEmailVerified {
                    
                    self.goToMainPage()
                    print("user has logged in with email" , User.currentUser?.email)
                    
                }else {
                    ProgressHUD.showFailed("Please verify email")
                    self.reSendEmailButton.isHidden = false
                }
                
            } else {
                ProgressHUD.showFailed(error.debugDescription)
            }
            
        }
    }
    
    private func goToMainPage(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
}

