//
//  DetailViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 18/05/22.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updateDataDelegate {
    func updateData() {
        detailExpense = getDetailExpenseFromMainId(id: mainExpenseId)
        tableView.reloadData()
        //Set Label
        
        let totalAmount = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: mainExpenseId)
        print(totalAmount.count)
        if totalAmount.count == 0{
            self.navigationController?.popViewController(animated: true)
        }else{
            
            setTotalLabel(amount: Int(totalAmount.first?.value(forKey: "expense_total") as! String)!)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailExpense.count
    }
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "details") as! DetailTableViewCell
        let detailImage = UIImage(systemName: detailExpense[indexPath.row].imageString)
        let detailCategory = detailExpense[indexPath.row].expenseCategory
        let detailAmount = convertNumberToExplainedString(numberPassed: checkBalanceType(category: detailCategory, balance:  Int(detailExpense[indexPath.row].expenseAmount)!))
        
        cell.detailImage.image = detailImage
        cell.detailLabel.text = String(detailCategory)
        cell.detailAmount.text = String(detailAmount)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        indexToPass = indexPath.row
        performSegue(withIdentifier: "editData", sender: self)
    }
    
    
    let coreDataObj = CoreDataController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dateFormatter = DateFormatter()
    var mainExpenseId: String = ""
    var detailExpense: [ExpenseDetailDisplay] = []
    var delegateToPass: updateDataDelegate?
    var indexToPass: Int = 0
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set Label
        let totalAmount = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: mainExpenseId).first?.value(forKey: "expense_total")
        setTotalLabel(amount: Int(totalAmount as! String)!)
        
        let detailDate = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: mainExpenseId).first?.value(forKey: "expense_date")
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: detailDate as! Date)
        
        dateFormatter.dateFormat = "MM"
        let month = convertNumberToMonths(month: Int(dateFormatter.string(from: detailDate as! Date))!)
        
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: detailDate as! Date)
        
        let finalDateString = "\(day) \(month) \(year)"
        navigationBar.title = finalDateString
        
        
        //Get Table Data
        detailExpense = getDetailExpenseFromMainId(id: mainExpenseId)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editData"{
            let targetNavigationController = segue.destination as! UINavigationController
            if let targetViewController = targetNavigationController.topViewController as? EditViewController{
                targetViewController.detailExpenseId = detailExpense[indexToPass].expenseDetailId
                targetViewController.detailPageDelegate = self
                targetViewController.mainPageDelegate = delegateToPass
            }
        }
    }
    
    func getDetailExpenseFromMainId(id: String) -> [ExpenseDetailDisplay]{
        var detailExpenses: [ExpenseDetailDisplay] = []
        
        //Get Main Expense ID
        let expenseId = id
        
        //Get Detail Expenses
        let detailExpensesObject = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_id", predicateValue: expenseId)
        
        //Looping to get each item and append into list
        for items in detailExpensesObject{
            let categoryCoreData = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Category", toPredicate: "expense_category_id", predicateValue: items.value(forKey: "expense_category_id") as! String)
            let detailId: String = items.value(forKey: "expense_detail_id") as! String
            let categoryName: String = categoryCoreData.first?.value(forKey: "expense_category") as! String
            let imageString: String = categoryCoreData.first?.value(forKey: "image_string") as! String
            let detailAmount: String = items.value(forKey: "expense_amount") as! String
            
            detailExpenses.append(ExpenseDetailDisplay(expenseDetailId: detailId, expenseCategory: categoryName, expenseAmount: detailAmount, imageString: imageString))
        }
        
        //Return
        return detailExpenses
    }
    
    func setTotalLabel(amount: Int){
        let formattedNumber = convertNumberToExplainedString(numberPassed: amount)
        totalLabel.text = formattedNumber
    }
    
    func convertNumberToExplainedString(numberPassed: Int)->String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let numberStringed: String = numberFormatter.string(from: abs(numberPassed) as NSNumber)!
        let posnegNotationUsed: String = numberPassed >= 0 ? "+" : "-"
        
        let numberExplained = posnegNotationUsed + " " + numberStringed + ".00"
        return numberExplained
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func convertNumberToMonths(month: Int) -> String{
        var monthName: String
        
        switch (month){
        case 1:
            monthName = "January"
        case 2:
            monthName = "February"
        case 3:
            monthName = "March"
        case 4:
            monthName = "April"
        case 5:
            monthName = "May"
        case 6:
            monthName = "June"
        case 7:
            monthName = "July"
        case 8:
            monthName = "August"
        case 9:
            monthName = "September"
        case 10:
            monthName = "October"
        case 11:
            monthName = "November"
        case 12:
            monthName = "December"
        default:
            monthName = "Not Found"
        }
        
        return monthName
    }
    func checkBalanceType(category: String, balance: Int) -> Int{
        var balanceTotal: Int = 0
        if category == "Income" || category == "1"{
            balanceTotal += balance
        }else{
            balanceTotal -= balance
        }
        return balanceTotal
    }
}
