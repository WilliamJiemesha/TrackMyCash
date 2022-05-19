//
//  AmountViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 30/04/22.
//

import UIKit

class AmountViewController: UIViewController {
    
    //Variable initialization
    var delegatePassed: changeNewDataValuesDelegate?
    
    //IB Outlet
    @IBOutlet weak var amountTextField: UITextField!
    
    //IB Action
    @IBAction func doneButtonClicked(_ sender: Any) {
        delegatePassed?.changeAmountValue(amount: amountTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0")
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onAmountTextFieldChanged(_ sender: Any) {
        amountTextField.text = convertToThousands(numberPassed: Int(amountTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0)
        print("in")
    }
    
    //On page load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    //Supporting Function
    func convertToThousands(numberPassed: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let numberConverted = numberFormatter.string(from: numberPassed as NSNumber)
        return numberConverted!
    }
    
    //Object Functions
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        amountTextField.resignFirstResponder()
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
