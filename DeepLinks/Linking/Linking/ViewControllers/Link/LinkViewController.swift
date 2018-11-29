//
//  LinkViewController.swift
//  Linking
//
//  Created by Glny Gl on 1.11.2018.
//  Copyright © 2018 Glny Gl. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD

class LinkViewController: BaseViewController {
    
    @IBOutlet weak var linkTableView: UITableView!
    
    var project: ProjectModel?
    var links: [String]?
    var id: String?
    var array: [String]?
    
    let databaseReference  = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTableView.delegate = self
        linkTableView.dataSource = self
        
        let addButtonItem = UIBarButtonItem(image: UIImage(named: "Add"), style: .done, target: self, action: #selector(addLink))
        self.navigationItem.rightBarButtonItem  = addButtonItem
        self.navigationItem.title = "Links"
        
        SVProgressHUD.show()
        databaseReference.child("Project").child(id ?? "").observe(.value, with: { (snapshot) in
            if let data  = snapshot.value as? [String : Any] {
                let links = data["Links"] as? [String]
                self.links = links
                self.linkTableView.reloadData()
                SVProgressHUD.dismiss()
            }
        })
        
    }
    
    @objc func addLink(){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let addLinkViewController = mainStoryboard.instantiateViewController(withIdentifier: "AddLinkViewController") as! AddLinkViewController
        
        self.databaseReference.child("Project").child(self.project?.id ?? "").observe(.value, with: { (snapshot) in
            if let data  = snapshot.value as? [String : Any] {
                self.links = data["Links"] as? [String]
                addLinkViewController.links = self.links
            }
        })
        addLinkViewController.project = self.project
        addLinkViewController.delegate = self
        addLinkViewController.control = true
        self.present(addLinkViewController, animated: true, completion: nil)
    }
    
    func editCell(_ index: IndexPath){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let addLinkViewController = mainStoryboard.instantiateViewController(withIdentifier: "AddLinkViewController") as! AddLinkViewController
        addLinkViewController.control = false
        addLinkViewController.index = index.row
        addLinkViewController.project = self.project
        self.present(addLinkViewController, animated: true, completion: nil)
    }
    
    func deleteCell(_ indexPath: IndexPath, _ id: String) {
        let deleteAlert = UIAlertController(title: "", message: "Do you really want to delete this link?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default) {(action) in
                                        print("deleted")
                                        ////// DELETE LINK
                                        self.databaseReference.child("Project").child(self.project?.id ?? "").observe(.value, with: { (snapshot) in
                                            if let data  = snapshot.value as? [String : Any] {
                                                self.array = data["Links"] as? [String]
                                                self.array?.remove(at: indexPath.row)
                                                self.links = self.array
                                                self.linkTableView.reloadData()
                                            }
                                        })
                                       
                                       //  value.updateChildValues([["Links": self.links ?? [""]])
                                        
                                        
                                        //                                                var value = self.databaseReference.child("Project").child(self.project?.id ?? "").child("Links").child("\(indexPath.row)")
                                        //                                                value.removeValue()
                                        //
                                        
//                                          var value = self.databaseReference.child("Project").child(self.project?.id ?? "")
//                                           value.updateChildValues(["Links": self.links ?? [""]])
                            
                                        //   print("Links \(self.links)")
                                        
                                        
                                        //                                        var value = self.databaseReference.child("Project").child(self.project?.id ?? "").child("Links").child("\(indexPath.row)")
                                        //                                        value.removeValue()
                                        //                                        print(value)
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
}

extension LinkViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.links?[0] == "" {
            return 0
        } else {
            return self.links?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkTableViewCell", for: indexPath) as! LinkTableViewCell
        cell.linkLabel.text = self.links?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "atasun://garantipay-ile-50-TL-bonus")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        print("selected")
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { action, indexPath in
            self.editCell(indexPath)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            if let id = self.project?.id{
                self.deleteCell(indexPath,id)
            }
        }
        editAction.backgroundColor = UIColor(red:0.67, green:0.70, blue:0.73, alpha:1.0)
        deleteAction.backgroundColor = UIColor(red:0.82, green:0.00, blue:0.00, alpha:1.0)
        return [deleteAction, editAction]
    }
}

extension LinkViewController: LinkProtocol {
    func refreshLink(_ model: ProjectModel) {
        self.project = model
        self.linkTableView.reloadData()
    }
}


