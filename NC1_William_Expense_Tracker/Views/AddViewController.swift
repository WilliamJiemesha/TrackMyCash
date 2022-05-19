//
//  AddViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 29/04/22.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, changeNewDataValuesDelegate {
    
    //Variable initialization
    var currentAmount: String = ""
    var currentCategoryId: String = ""
    var currentDate: String = ""
    var currentNote: String = ""
    var delegatePassed: updateDataDelegate?
    let coreDataObj = CoreDataController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let labelTitles: [String] = ["Amount", "Category", "Date"]
    var labelContents: [String] = []
    //    let labelTitles: [String] = ["Amount", "Category", "Date", "Note"] <-- Previous format, don't delete for safekeeping.
    
    
    //IB Outlets
    @IBOutlet weak var addTableView: UITableView!
    
    //IB Actions
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let expenseDetails = coreDataObj.selectAllCoreData(delegate: appDelegate, entityName: "Expense_Detail")
        
//        let expenseDetailId: String = String(expenseDetails.count + 1)
        
        var highestId = 0
        if expenseDetails.count != 0{
            print(expenseDetails)
            for items in expenseDetails{
                let currValue: String = items.value(forKey: "expense_detail_id") as! String
                if Int(currValue)! > highestId{
                    highestId = Int(currValue)!
                }
            }
        }
        
        let expenseDetailId: String = String(highestId + 1)
        
        
        
        let toSelectDateFormatter = DateFormatter()
        toSelectDateFormatter.dateFormat = "dd-MM-yyyy"
        let expenseDataForDate = selectExpenseDate(date: toSelectDateFormatter.date(from: currentDate)!)
        var expenseIdForDate: String
        if expenseDataForDate.count == 0{
            let newExpenseId = String(coreDataObj.selectAllCoreData(delegate: appDelegate, entityName: "Expense").count + 1)
            expenseIdForDate = newExpenseId
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"

            insertExpenseManually(entityName: "Expense", expenseId: newExpenseId, expenseDate: dateFormatter.date(from: currentDate)!, expenseTotal: String(checkBalanceType(category: currentCategoryId, balance: Int(currentAmount)!)))
            
        } else {
            expenseIdForDate = expenseDataForDate.first?.value(forKey: "expense_id") as! String
            let initialTotal = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: "expense_id", predicateValue: expenseIdForDate)
            let allTotal = Int(initialTotal.first?.value(forKey: "expense_total") as! String)! + checkBalanceType(category: currentCategoryId, balance: Int(currentAmount)!)
            coreDataObj.updateMultipleWhereAndCoreData(delegate: appDelegate, entityName: "Expense", toPredicate: ["expense_id"], predicateValue: [expenseIdForDate], valueToChange: "expense_total", value: String(allTotal))
        }
        
        coreDataObj.insertToCoreData(delegate: appDelegate, entityName: "Expense_Detail", value: [expenseDetailId, expenseIdForDate, currentCategoryId, currentAmount, currentNote], key: ["expense_detail_id", "expense_id", "expense_category_id", "expense_amount", "expense_note"])
        delegatePassed?.updateData()
        dismiss(animated: true)
    }
    
    //On page load functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setDefaultValues()
    }
    
    //Table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customAddCell") as! CustomAddTableViewCell

        cell.titleLabel.text = labelTitles[indexPath.row]
        if indexPath.row == 0{
            cell.detailLabel.text = convertToThousands(numberPassed: Int(labelContents[indexPath.row]) ?? 0)
        }else{
            cell.detailLabel.text = labelContents[indexPath.row]
        }

        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        switch(indexPath.row){
        case 0:
            performSegue(withIdentifier: "addAmountSegue", sender: self)
            break
        case 1:
            performSegue(withIdentifier: "addCategorySegue", sender: self)
            break
        case 2:
            performSegue(withIdentifier: "addDateSegue", sender: self)
            break
//        case 3:
//            performSegue(withIdentifier: "addNoteSegue", sender: self)
//            break <-- Previous format, don't delete for safekeeping
        default:
            break
        }
    }
    
    //Override prepare, to run commands before opening next page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier){
        case "addAmountSegue":
            if let targetViewController = segue.destination as? AmountViewController{
                targetViewController.delegatePassed = self
            }
            break
        case "addDateSegue":
            if let targetViewController = segue.destination as? DateViewController{
                targetViewController.delegatePassed = self
            }
            break
        case "addNoteSegue":
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
    
    //Supporting functions
    func convertToThousands(numberPassed: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let numberConverted = numberFormatter.string(from: numberPassed as NSNumber)
        return numberConverted!
    }

    func getCategoryName(categoryId: String) -> String {
        let categoryName = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Category", toPredicate: "expense_category_id", predicateValue: categoryId)
        return categoryName.first?.value(forKey: "expense_category") as! String
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
    
    //Functions to access core data, made for specific use that library cannot handle
    func insertExpenseManually(entityName: String, expenseId: String, expenseDate: Date, expenseTotal: String){
        let appDelegate = appDelegate
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {return}
        let entityData = NSManagedObject(entity: entity, insertInto: context)
        
        entityData.setValue(expenseId, forKey: "expense_id")
        entityData.setValue(expenseDate, forKey: "expense_date")
        entityData.setValue(expenseTotal, forKey: "expense_total")
        
        do{
            try context.save()
        }catch{
            print("Error saving data")
        }
    }
    func selectExpenseDate(date: Date) -> [NSManagedObject]{
        let appDelegate = appDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        let predicateCoreData = NSPredicate(format: "expense_date = %@", date as CVarArg)
        fetchRequest.predicate = predicateCoreData
        let result = try! context.fetch(fetchRequest) as! [NSManagedObject]

        return result

    }
    
    //Functions to set default values before any user inputs
    func setDefaultValues(){
        currentAmount = "0"
        currentCategoryId = "0"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        currentDate = dateFormatter.string(from: Date())
        currentNote = "Note"
        
        refreshLabelContents()
    }
    
    //Functions to refresh page data
    func refreshLabelContents(){
        labelContents = [currentAmount, getCategoryName(categoryId: currentCategoryId), currentDate]
//        labelContents = [currentAmount, getCategoryName(categoryId: currentCategoryId), currentDate, currentNote] <-- Previous format, don't delete for safekeeping.
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
        addTableView.reloadData()
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
