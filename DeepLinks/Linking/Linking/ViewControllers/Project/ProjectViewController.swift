//
//  ProjectViewController.swift
//  Linking
//
//  Created by Glny Gl on 1.11.2018.
//  Copyright © 2018 Glny Gl. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseDatabase

class ProjectViewController: BaseViewController {
    
    @IBOutlet weak var projectTableView: UITableView!
    
    var project = [ProjectModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseReference  = Database.database().reference()
        
        projectTableView.delegate = self
        projectTableView.dataSource = self
        
        SVProgressHUD.show()
        databaseReference.child("Project").observe(.childAdded, with: { (snapshot) in
            if let data  = snapshot.value as? [String : Any] {
                let id = data["ID"] as? String
                let name = data["Name"] as? String
                let type = data["Type"] as? String
                let links = data["Links"] as? [String]
                let project = ProjectModel.init(id ?? "", name ?? "", type ?? "", links ?? [""])
                self.project.append(project)
                self.project = self.project.sorted { (lhs: ProjectModel, rhs: ProjectModel) -> Bool in
                    return lhs.name ?? "" < rhs.name ?? ""
                }
                self.projectTableView.reloadData()
                SVProgressHUD.dismiss()
            }
        })
        
        let addButtonItem = UIBarButtonItem(image: UIImage(named: "Add"), style: .done, target: self, action: #selector(addProject))
        self.navigationItem.rightBarButtonItem  = addButtonItem
        self.navigationItem.title = "Projects"
        
    }
    
    @objc func addProject(){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let addProjectViewController = mainStoryboard.instantiateViewController(withIdentifier: "AddProjectViewController") as! AddProjectViewController
        addProjectViewController.control = true
        self.present(addProjectViewController, animated: true, completion: nil)
    }
    
    func deleteCell(_ indexPath: IndexPath, _ id: String) {
        let deleteAlert = UIAlertController(title: "", message: "Do you really want to delete this project?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default) {(action) in
                                        let databaseReference  = Database.database().reference()
                                        databaseReference.child("Project").child(id).removeValue()
                                        self.project.remove(at: indexPath.row)
                                        self.projectTableView.reloadData()
                                        print("deleted")
        }
        let noAction = UIAlertAction(title: "No",
                                     style: .default) {(action) in
                                        print("canceled")
                                        
        }
        deleteAlert.view.tintColor = UIColor(red:0.82, green:0.00, blue:0.00, alpha:1.0)
        deleteAlert.addAction(yesAction)
        deleteAlert.addAction(noAction)
        present(deleteAlert, animated: true)
    }
    
    func editCell(_ value: ProjectModel, _ index: IndexPath){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let addProjectViewController = mainStoryboard.instantiateViewController(withIdentifier: "AddProjectViewController") as! AddProjectViewController
        addProjectViewController.delegate = self
        addProjectViewController.control = false
        addProjectViewController.project = value
        addProjectViewController.index = index.row
        self.present(addProjectViewController, animated: true, completion: nil)
    }
    
}

extension ProjectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.project.count == 0 {
            SVProgressHUD.dismiss()
            return 0
        }
        else {
          return self.project.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as! ProjectTableViewCell
        
        cell.projectNameLabel.text = self.project[indexPath.row].name
        if self.project[indexPath.row].type == "Android" {
            cell.projectImage.image = UIImage(named: "Android")
        }else if self.project[indexPath.row].type == "iOS"{
            cell.projectImage.image = UIImage(named: "iOS")
        }else{
            cell.projectImage.image = UIImage(named: "Both")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let linkViewController = mainStoryboard.instantiateViewController(withIdentifier: "LinkViewController") as! LinkViewController
        linkViewController.project = self.project[indexPath.row]
        linkViewController.id = self.project[indexPath.row].id
        self.navigationController?.pushViewController(linkViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { action, indexPath in
            self.editCell(self.project[indexPath.row], indexPath)
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            if let id = self.project[indexPath.row].id{
                 self.deleteCell(indexPath,id)
            }
        }
        editAction.backgroundColor = UIColor(red:0.67, green:0.70, blue:0.73, alpha:1.0)
        deleteAction.backgroundColor = UIColor(red:0.82, green:0.00, blue:0.00, alpha:1.0)
        return [deleteAction, editAction]
    }
    
}

extension ProjectViewController: ProjectProtocol {
    func refreshProject(_ model: ProjectModel, _ index: Int) {
        self.project[index] = model
        self.projectTableView.reloadData()
    }
    
}

