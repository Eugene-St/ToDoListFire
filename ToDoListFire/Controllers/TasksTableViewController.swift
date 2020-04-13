//
//  TasksTableViewController.swift
//  ToDoListFire
//
//  Created by Eugene St on 09.04.2020.
//  Copyright © 2020 Eugene St. All rights reserved.
//

import UIKit
import Firebase

class TasksTableViewController: UITableViewController {
  
  private var user: ModelUser!
  private var reference: DatabaseReference!
  private var tasks = [Task]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let currentUser = Auth.auth().currentUser else { return }
    user = ModelUser(user: currentUser)
    reference = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    reference.observe(.value) { [weak self] (snapshot) in
      
      var _tasks = [Task]()
      
      snapshot.children.forEach { item in
        let task = Task(snapshot: item as! DataSnapshot)
        _tasks.append(task)
      }
      
      self?.tasks = _tasks
      self?.tableView.reloadData()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    reference.removeAllObservers()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    cell.backgroundColor = .clear
    cell.textLabel?.textColor = .white
    let taskTitle = tasks[indexPath.row].title
    cell.textLabel?.text = taskTitle
    return cell
  }
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
    alertController.addTextField()
    
    let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
      guard let textField = alertController.textFields?.first, textField.text != "" else { return }
      
      let task = Task(title: textField.text!, userID: (self?.user.uid)!)
      let taskReference = self?.reference.child(task.title.lowercased())
      taskReference?.setValue(task.convertToDictionary())
      
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    alertController.addAction(save)
    alertController.addAction(cancel)
    
    present(alertController, animated: true)
  }
  
  @IBAction func signOut(_ sender: UIBarButtonItem) {
    do {
      try Auth.auth().signOut()
    } catch {
      print(error.localizedDescription)
    }
    dismiss(animated: true, completion: nil)
  }
}
