//
//  LoginViewController.swift
//  ToDoListFire
//
//  Created by Eugene St on 09.04.2020.
//  Copyright © 2020 Eugene St. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  private let segueIdentifier = "taskSegue"
  private var reference: DatabaseReference!
  
  @IBOutlet weak var warningLabel: UILabel!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    reference = Database.database().reference(withPath: "users")
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    warningLabel.alpha = 0
    Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
      if user != nil {
        self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
      }
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    emailTextField.text = nil
    passwordTextField.text = nil
  }
  
  @objc func keyboardDidShow(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    
    (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + keyboardFrameSize.height)
    
    (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrameSize.height, right: 0)
    
    
  }
  
  @objc func keyboardDidHide() {
    (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
  }
  
  private func displayWarning(withText text: String) {
    warningLabel.text = text
    
    UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
      self?.warningLabel.alpha = 1
    }) { [weak self] complete in
      self?.warningLabel.alpha = 0
    }
  }
  
  @IBAction func loginPressed(_ sender: UIButton) {
    guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
      displayWarning(withText: "Info is incorrect")
      emailTextField.text = nil
      passwordTextField.text = nil
      return
    }
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
      if error != nil {
        self?.displayWarning(withText: "Error occurred")
        return
      }
      
      if user != nil {
        self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
        return
      }
      
      self?.displayWarning(withText: "No such user")
    }
    
  }
  
  @IBAction func registerPressed(_ sender: UIButton) {
    guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
      displayWarning(withText: "Info is incorrect")
      return
    }
    
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
      guard error == nil, user != nil else {
        print(error!.localizedDescription)
        return
      }
      
      let userReference = self?.reference.child((user?.user.uid)!)
      userReference?.setValue(["email": user?.user.email])
    }
  }
}

