//
//  DateViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 30/04/22.
//

import UIKit

class DateViewController: UIViewController {
    
    //Variable Initialization
    var delegatePassed: changeNewDataValuesDelegate?
    
    //IB Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //IB Actions
    @IBAction func doneButtonClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        delegatePassed?.changeDateValue(date: dateFormatter.string(from: datePicker.date))
        self.navigationController?.popViewController(animated: true)
    }
    
    //On page load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
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
