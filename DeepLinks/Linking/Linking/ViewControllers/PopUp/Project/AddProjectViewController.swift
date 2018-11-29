//
//  AddViewController.swift
//  Linking
//
//  Created by Glny Gl on 1.11.2018.
//  Copyright © 2018 Glny Gl. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import ActionSheetPicker_3_0

protocol ProjectProtocol {
    func refreshProject(_ model: ProjectModel, _ index: Int)
}

class AddProjectViewController: BaseViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var projectTypeButton: UIButton!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var projectType = ["iOS", "Android", "Both"]
    var control: Bool?
    var project: ProjectModel?
    var delegate: ProjectProtocol?
    var index: Int?
    
    let databaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        giveRadius()
        setTabGesture()
        
        self.projectNameTextField.setValue(UIColor.init(red:1.00, green:1.00, blue:1.00, alpha:1.0), forKeyPath: "placeholderLabel.textColor")
        
        if control == false {
            self.projectNameTextField.text = self.project?.name
            self.projectTypeButton.setTitle(self.project?.type, for: .normal)
            self.saveButton.setTitle("Change", for: .normal)
        }
        
    }
    
    func giveRadius() {
        self.popUpView.layer.cornerRadius = 40
        self.popUpView.clipsToBounds = true
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.clipsToBounds = true
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.clipsToBounds = true
        self.projectTypeButton.layer.cornerRadius = 5
        self.projectTypeButton.clipsToBounds = true
    }
    
    func setTabGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hidePopUp))
        tapGesture.cancelsTouchesInView = false
        self.backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func projectTypeButtonPressed(_ sender: UIButton) {
        setPicker(sender)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if control == true {
            let value = databaseReference.child("Project").childByAutoId()
            value.setValue(["ID": value.key ?? "", "Name": self.projectNameTextField.text ?? "", "Type": self.projectTypeButton.title(for: .normal) ?? "", "Links": [""]])
        }else {
            let value = databaseReference.child("Project").child(self.project?.id ?? "")
            value.setValue(["ID": value.key ?? "", "Name": self.projectNameTextField.text ?? "", "Type": self.projectTypeButton.title(for: .normal) ?? "", "Links": self.project?.links ?? ""])
            
            SVProgressHUD.show()
            databaseReference.child("Project").child(self.project?.id ?? "").observe(.value, with: { (snapshot) in
                if let data  = snapshot.value as? [String : Any] {
                    let id = data["ID"] as? String
                    let name = data["Name"] as? String
                    let type = data["Type"] as? String
                    let links = data["Links"] as? [String]
                    let model = ProjectModel.init(id ?? "", name ?? "", type ?? "", links ?? [""])
                    print("Modelllllllll \(model)")
                    self.delegate?.refreshProject(model , self.index ?? 0)
                    SVProgressHUD.dismiss()
                }
            })
           
          // delegate?.refreshProject(self.project ?? ProjectModel.init("","","",[""]), self.project?.id ?? "")
        }
        hidePopUp()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hidePopUp()
    }
    
    
    
    func setPicker(_ sender: UIButton) {
        let cancelButton:UIButton =  UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor(red:0.72, green:0.05, blue:0.04, alpha:1.0), for: .normal)
        cancelButton.frame = CGRect(x: 0, y: 0, width: 55, height: 32)
        
        let doneButton:UIButton =  UIButton(type: .custom)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor(red:0.72, green:0.05, blue:0.04, alpha:1.0), for: .normal)
        doneButton.frame = CGRect(x: 0, y: 0, width: 55, height: 32)
        
        let actionSheetPicker = ActionSheetStringPicker(title: "", rows: projectType, initialSelection: 0, doneBlock: {
            picker, values, indexes in
            
            self.projectTypeButton.setTitle(indexes as? String, for: .normal)
            
            return
            
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        actionSheetPicker?.setCancelButton(UIBarButtonItem(customView: cancelButton))
        actionSheetPicker?.setDoneButton(UIBarButtonItem(customView: doneButton))
        actionSheetPicker?.show()
    }
    
    
    @objc func hidePopUp(){
        dismiss(animated: true, completion: nil)
    }
    
}
