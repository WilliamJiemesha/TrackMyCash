//
//  EditViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 19/05/22.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, changeNewDataValuesDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customAddCell") as! CustomAddTableViewCell

        cell.titleLabel.text = labelTitles[indexPath.row]
        if indexPath.row == 0{
            cell.detailLabel.text = convertToThousands(numberPassed: Int(labelContents[indexPath.row]) ?? 0)
        }else{
            if indexPath.row == 1 {
                cell.isUserInteractionEnabled = false
            }
            cell.detailLabel.text = labelContents[indexPath.row]
        }

        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        switch(indexPath.row){
        case 0:
            performSegue(withIdentifier: "editAmountSegue", sender: self)
            break
        case 1:
//            performSegue(withIdentifier: "addCategorySegue", sender: self)
            break
        case 2:
            performSegue(withIdentifier: "editDateSegue", sender: self)
            break
//        case 3:
//            performSegue(withIdentifier: "addNoteSegue", sender: self)
//            break <-- Previous format, don't delete for safekeeping
        default:
            break
        }
    }
    func setDefaultValues(){
        let data = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_detail_id", predicateValue: detailExpenseId)
        
        currentAmount = data.first?.value(forKey: "expense_amount") as! String
        currentCategoryId = data.first?.value(forKey: "expense_category_id") as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateFromMain = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: data.first?.value(forKey: "expense_id") as! String).first?.value(forKey: "expense_date")
        currentDate = dateFormatter.string(from: dateFromMain as! Date)
        currentNote = "Note"
        
        refreshLabelContents()
    }
    
    //Functions to refresh page data
    func refreshLabelContents(){
        labelContents = [currentAmount, getCategoryName(categoryId: currentCategoryId), currentDate]
//        labelContents = [currentAmount, getCategoryName(categoryId: currentCategoryId), currentDate, currentNote] <-- Previous format, don't delete for safekeeping.
    }
    func getCategoryName(categoryId: String) -> String {
        let categoryName = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Category", toPredicate: "expense_category_id", predicateValue: categoryId)
        return categoryName.first?.value(forKey: "expense_category") as! String
    }
    
    //Variable initialization
    var currentAmount: String = ""
    var currentCategoryId: String = ""
    var currentDate: String = ""
    var currentNote: String = ""
    let labelTitles: [String] = ["Amount", "Category"]
    var labelContents: [String] = []
    let coreDataObj = CoreDataController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var detailExpenseId: String = ""
    
    var initialAmount: Int = 0
    
    @IBOutlet weak var editTableView: UITableView!
    var mainPageDelegate: updateDataDelegate?
    var detailPageDelegate: updateDataDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultValues()
        initialAmount = Int(currentAmount)!
        // Do any additional setup after loading the view.
    }
    
    //Override prepare, to run commands before opening next page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier){
        case "editAmountSegue":
            if let targetViewController = segue.destination as? AmountViewController{
                targetViewController.delegatePassed = self
            }
            break
        case "editDateSegue":
            if let targetViewController = segue.destination as? DateViewController{
                targetViewController.delegatePassed = self
            }
            break
        case "editNoteSegue":
            if let targetViewController = segue.destination as? NoteViewController{
                targetViewController.delegatePassed = self
            }
            break
        case "addCategorySegue":
            if let targetViewController = segue.destination as? CategoryViewController{
                targetViewController.delegatePassed = self
            }
            break
        default:
            break
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        coreDataObj.updateMultipleWhereAndCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: ["expense_detail_id"], predicateValue: [detailExpenseId], valueToChange: "expense_amount", value: currentAmount)
        
//        coreDataObj.updateMultipleWhereAndCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: ["expense_detail_id"], predicateValue: [detailExpenseId], valueToChange: "expense_date", value: currentDate)
        
        let mainExpenseId = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_detail_id", predicateValue: detailExpenseId).first?.value(forKey: "expense_id") as! String
        
        let amountToEdit: Int = initialAmount - Int(currentAmount)!
        print(mainExpenseId)
        let finalAmount = Int((coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: mainExpenseId).first?.value(forKey: "expense_total") as! String))! + amountToEdit
        coreDataObj.updateMultipleWhereAndCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: ["expense_id"], predicateValue: [mainExpenseId], valueToChange: "expense_total", value: String(finalAmount))
        
        detailPageDelegate?.updateData()
        mainPageDelegate?.updateData()
        dismiss(animated: true)
    }
    @IBAction func deleteButton(_ sender: Any) {
        let data = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_detail_id", predicateValue: detailExpenseId)
        let expenseId = data.first?.value(forKey: "expense_id")
        let detailCategory = data.first?.value(forKey: "expense_category_id") as! String
        let detailAmount = checkBalanceType(category: detailCategory, balance: Int(data.first?.value(forKey: "expense_amount") as! String)!)
        coreDataObj.deleteData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: ["expense_detail_id"], predicateValue: [detailExpenseId])
        if coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_id", predicateValue: expenseId as! String).count == 0{
            coreDataObj.deleteData(delegate: appDelegate, entityName: "Expense", toPredicate: ["expense_id"], predicateValue: [expenseId as! String])
        }else{
            let firstAmount = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: expenseId as! String)
            coreDataObj.updateMultipleWhereAndCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: ["expense_id"], predicateValue: [expenseId as! String], valueToChange: "expense_total", value: String(Int(Int(firstAmount.first?.value(forKey: "expense_total") as! String)! - detailAmount)))
        }
        detailPageDelegate?.updateData()
        mainPageDelegate?.updateData()
        dismiss(animated: true)
    }
    
    func getDetailContent(detailId: String) -> NSManagedObject{
        return (coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_detail_id", predicateValue: detailId).first)!
    }
    func convertToThousands(numberPassed: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let numberConverted = numberFormatter.string(from: numberPassed as NSNumber)
        return numberConverted!
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

    //Protocol Functions to run when user finished with inputs on other page
    func changeAmountValue(amount: String){
        currentAmount = amount
        resetTable()
    }
    
    func changeDateValue(date: String){
        currentDate = date
        resetTable()
    }
    
    func changeNoteValue(note: String){
        currentNote = note
        resetTable()
    }
    
    func changeCategoryValue(categoryId: String){
        currentCategoryId = categoryId
        resetTable()
    }
    
    func resetTable(){
        refreshLabelContents()
        editTableView.reloadData()
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
