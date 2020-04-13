//
//  User.swift
//  ToDoListFire
//
//  Created by Eugene St on 10.04.2020.
//  Copyright © 2020 Eugene St. All rights reserved.
//

import Foundation
import Firebase

struct ModelUser {
  let uid: String
  let email: String
  
  init(user: User) {
    self.uid = user.uid
    self.email = user.email!
  }
}
