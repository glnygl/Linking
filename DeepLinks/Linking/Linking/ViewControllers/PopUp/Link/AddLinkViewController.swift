//
//  AddLinkViewController.swift
//  Linking
//
//  Created by Glny Gl on 1.11.2018.
//  Copyright © 2018 Glny Gl. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol LinkProtocol {
    func refreshLink(_ model: ProjectModel)
}

class AddLinkViewController: BaseViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var project: ProjectModel?
    var links: [String]?
    var delegate: LinkProtocol?
    var control: Bool?
    var index: Int?
    
    let databaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.giveRadius()
        
        self.linkTextView.delegate = self
        
        self.linkTextView.text = "Enter Link"
        self.linkTextView.textColor = UIColor.white
        self.linkTextView.returnKeyType = .done
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hidePopUp))
        tapGesture.cancelsTouchesInView = false
        self.backgroundView.addGestureRecognizer(tapGesture)
        
        if control == false {
            self.linkTextView.text = self.project?.links?[index ?? 0]
            self.saveButton.setTitle("Change", for: .normal)
        }
    }
    
    @objc func hidePopUp(){
        dismiss(animated: true, completion: nil)
    }
    
    func giveRadius() {
        self.popUpView.layer.cornerRadius = 40
        self.popUpView.clipsToBounds = true
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.clipsToBounds = true
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.clipsToBounds = true
        self.linkTextView.layer.cornerRadius = 5
        self.linkTextView.clipsToBounds = true
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if control == true {
        
            let value = databaseReference.child("Project").child(self.project?.id ?? "")
                    if self.links == [""]{
                        value.updateChildValues(["Links": [self.linkTextView.text]])
                    } else {
                        self.links?.append(self.linkTextView.text)
                        value.updateChildValues(["Links": self.links as Any])
                        self.project?.links = self.links
                        delegate?.refreshLink(self.project ?? ProjectModel.init("","","",[""]))
                    }
        }else {
            let value = databaseReference.child("Project").child(self.project?.id ?? "")
            self.project?.links?[index ?? 0] = self.linkTextView.text
                value.updateChildValues(["Links": self.project?.links as Any])
        }
        hidePopUp()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
         hidePopUp()
    }
    
}

extension AddLinkViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Link" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.linkTextView.text = "Enter Link"
        self.linkTextView.textColor = UIColor.white
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
}
