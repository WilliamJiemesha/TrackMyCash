//
//  NoteViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 30/04/22.
//

import UIKit

class NoteViewController: UIViewController {
    
    //Variable initialization
    var delegatePassed: changeNewDataValuesDelegate?
    
    //IB Outlet
    @IBOutlet weak var noteTextView: UITextView!
    
    //IB Action
    @IBAction func doneButtonClicked(_ sender: Any) {
        let note = noteTextView.text ?? "Note"
        delegatePassed?.changeNoteValue(note: note)
        self.navigationController?.popViewController(animated: true)
    }
    
    //On page load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextView.clearsOnInsertion = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
