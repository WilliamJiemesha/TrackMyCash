//
//  ViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 26/04/22.
//

import UIKit
import CoreData
import Charts
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updateDataDelegate {
    
    //Variable Initialization
    let coreDataObj = CoreDataController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mainExpense: [ExpenseStructure] = []
    var detailExpense: [[ExpenseDetailToDisplay]] = []
    var totalBalance: Int = 0
    let dateFormatter = DateFormatter()
    let chartColorOption = ["#F09D51", "#175933", "#DC7D8A", "#7B4B94", "#561D25", "#30343F", "#E4D9FF", "#475841", "#786F52", "#FFADC6", "#058ED9", "#A6A57A", "#FAFF81", "#7A7D7D", "#5863F8", "#150811"]
    let lightChartColorOption = ["#7B4B94", "#2A6041", "#175933", "#753E0A", "#7A04C3"]
    var mainExpenseIdToSend: String = ""
    //IB Outlets
//    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var thisMonthBalanceLabel: UILabel!
    
    //On page load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let categoriesCount = coreDataObj.selectAllCoreData(delegate: appDelegate, entityName: "Expense_Category").count
        if categoriesCount == 0{
            fillCategories()
        }
        updateData()
        appDelegate.orientationLock = .portrait
    }
    
    //Table Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainExpense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customExpenseCell", for: indexPath) as! OuterDailyExpenseTableViewCell
        cell.accessoryType = .disclosureIndicator
        
        var accessibilityText: String = ""
        
        let day = mainExpense[indexPath.row].expenseDate
        dateFormatter.dateFormat = "dd"
        let dayString = dateFormatter.string(from: day as Date)
        
        let month = mainExpense[indexPath.row].expenseDate
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: month as Date)
        
        let year = mainExpense[indexPath.row].expenseDate
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: year as Date)
        
        cell.expenseDate.text = dayString
        cell.expenseMonth.text = convertNumberToMonths(month: Int(monthString)!)
        cell.expenseYear.text = yearString
        
        let totalAmount: Int = Int(mainExpense[indexPath.row].expenseTotal)!
        cell.expenseAmount.text = convertNumberToExplainedString(numberPassed: totalAmount)
        
        if Int(totalAmount) < 0 {
            cell.expenseAmount.textColor = UIColor(named: "RedAmountColor")
        } else {
            cell.expenseAmount.textColor = UIColor(named: "GreenAmountColor")
        }
 
        accessibilityText += " \(dayString) \(convertNumberToMonths(month: Int(monthString)!)) \(yearString) \(totalAmount < 0 ? "Minus" : "") \(convertNumberToExplainedString(numberPassed: totalAmount) )"
        
//        //If views on stackview doesn't get removed, the items from previous generation for some reason cannot be removed automatically and needs to be removed manually using removeFromSuperView()
//        for views in cell.descriptionStackView.subviews{
//            views.removeFromSuperview()
//        }
//        for secondItem in detailExpense[indexPath.row]{
//            let horizontalStackView = UIStackView()
//            horizontalStackView.axis = .horizontal
//
//            let imageCategory = UIImageView()
//            imageCategory.image = UIImage(systemName: secondItem.imageString)
//            imageCategory.contentMode = .scaleAspectFit
//            imageCategory.tintColor = .tintColor
//            NSLayoutConstraint.activate([imageCategory.widthAnchor.constraint(equalToConstant: 50)])
//
//            let labelDescription = UILabel()
//            labelDescription.text = secondItem.expenseCategory
//            labelDescription.font = UIFont.systemFont(ofSize: 12)
//            labelDescription.textAlignment = .left
//
//            let labelAmount = UILabel()
//            let detailAmount = Int(secondItem.expenseAmount)
//            labelAmount.text = convertNumberToExplainedString(numberPassed: checkBalanceType(category: secondItem.expenseCategory, balance:  detailAmount!))
//            labelAmount.font = UIFont.systemFont(ofSize: 12)
//            labelAmount.textAlignment = .right
//
//            horizontalStackView.distribution = .fill
//            horizontalStackView.alignment = .firstBaseline
//
//            horizontalStackView.addArrangedSubview(imageCategory)
//            horizontalStackView.addArrangedSubview(labelDescription)
//            horizontalStackView.addArrangedSubview(labelAmount)
//
//            cell.descriptionStackView.addArrangedSubview(horizontalStackView)
//            accessibilityText += " \(secondItem.expenseCategory) \(checkBalanceType(category: secondItem.expenseCategory, balance: detailAmount!) < 0 ? "Minus" : "") \(convertNumberToExplainedString(numberPassed: checkBalanceType(category: secondItem.expenseAmount, balance: detailAmount!)))"
//        }
        cell.accessibilityLabel = accessibilityText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        mainExpenseIdToSend = mainExpense[indexPath.row].expenseId
        print("somethings")
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    //Override prepare, to run commands before opening next page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buttonAddSegue"{
            let targetNavigationController = segue.destination as! UINavigationController
            if let targetViewController = targetNavigationController.topViewController as? AddViewController{
                targetViewController.delegatePassed = self
            }
        } else if segue.identifier == "detailSegue"{
            if let targetViewController = segue.destination as? DetailViewController {
                targetViewController.mainExpenseId = mainExpenseIdToSend
                targetViewController.delegateToPass = self
            }
        }
        
    }
    
    //Functions to fill database with default value either needed or as example for testing
    //Needed
    func fillCategories(){
        let categoryNames = ["Food and Beverage", "Income", "Auto and Transportation", "Shopping", "Entertainment", "Health and Fitness", "Investments", "Personal Care", "Fees and Charges", "Education", "Gift and Donation", "Taxes", "Kids", "Utilities", "Travel", "Business and Services"]
        let categoryImageString = ["drop.fill", "dollarsign.circle.fill", "car.fill", "cart.fill", "play.rectangle.fill", "heart.fill", "bitcoinsign.circle.fill", "mustache.fill", "creditcard.fill", "graduationcap.fill", "gift.fill", "rectangle.fill.badge.minus", "face.smiling.fill", "opticaldiscdrive.fill", "airplane", "case.fill"]
        for index in 0...categoryNames.count - 1{
            coreDataObj.insertToCoreData(delegate: appDelegate, entityName: "Expense_Category", value: [String(index), categoryNames[index], categoryImageString[index]], key: ["expense_category_id", "expense_category", "image_string"])
        }
    }
    
    //Example for testing
    func fillExpenses(){
        for index in 1...5{
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let expenseToFill = ExpenseStructure(expenseId: String(index), expenseDate: dateFormatter.date(from: "0\(index)-04-2022")! as NSDate, expenseTotal: String(index*50000))
            insertExpenseManually(entityName: "Expense", expenseId: expenseToFill.expenseId, expenseDate: expenseToFill.expenseDate as Date, expenseTotal: expenseToFill.expenseTotal)
            for secondIndex in 0...15{
                let detailExpenseToFill = ExpenseDetailStructure(expenseCategoryId: "\(secondIndex)", expenseAmount: String(index*50000/16), expenseNote: "lagi pengen", expenseId: String(index), expenseDetailId: String(secondIndex))
                coreDataObj.insertToCoreData(delegate: appDelegate, entityName: "Expense_Detail", value: [detailExpenseToFill.expenseDetailId, detailExpenseToFill.expenseId, detailExpenseToFill.expenseAmount, detailExpenseToFill.expenseCategoryId, detailExpenseToFill.expenseNote], key: ["expense_detail_id", "expense_id", "expense_amount", "expense_category_id", "expense_note"])
            }
        }
    }
    
    //Supporting Functions
    func convertNumberToExplainedString(numberPassed: Int)->String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        let numberStringed: String = numberFormatter.string(from: abs(numberPassed) as NSNumber)!
        let posnegNotationUsed: String = numberPassed >= 0 ? "+" : "-"
        
        let numberExplained = posnegNotationUsed + " " + numberStringed + ".00"
        return numberExplained
    }
    
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
    
    func hexToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //Functions to refresh page data
    func updateData(){
        mainExpense = []
        detailExpense = []
        refreshTableData()
        refreshTotalBalanceLabel()
//        updateChartData()
        expensesTableView.reloadData()
    }
    
    func refreshTableData(){
        //Get Expense Datas
        let mainExpenseData = coreDataObj.selectAllCoreData(delegate: appDelegate, entityName: "Expense")
        
        var expenseData: [ExpenseStructure] = []
        for items in mainExpenseData{
            expenseData.append(ExpenseStructure(expenseId: items.value(forKey: "expense_id") as! String, expenseDate: items.value(forKey: "expense_date") as! NSDate, expenseTotal: items.value(forKey: "expense_total") as! String))
        }
        expenseData = expenseData.sorted(by: {$0.expenseDate as Date > $1.expenseDate as Date})
        mainExpense = expenseData
        
        //Get Expense Details Data
        for mainItems in mainExpense{
            let id = mainItems.expenseId
            let details = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Detail", toPredicate: "expense_id", predicateValue: id)
            var detailsToInsert: [ExpenseDetailToDisplay] = []
            for items in details{
                let categoriesContainer = coreDataObj.selectOneWhereCoreData(delegate: appDelegate, entityName: "Expense_Category", toPredicate: "expense_category_id", predicateValue: items.value(forKey: "expense_category_id") as! String)
                let detailId = items.value(forKey: "expense_detail_id") as! String
                let categoryName = categoriesContainer.first?.value(forKey: "expense_category") as! String
                let categoryImageString = categoriesContainer.first?.value(forKey: "image_string") as! String
                let detailExpenseAmount = items.value(forKey: "expense_amount") as! String
                let detailExpenseNote = items.value(forKey: "expense_note") as! String
                
                dateFormatter.dateFormat = "dd-MM-yyyy"
                detailsToInsert.append(ExpenseDetailToDisplay(expenseDetailId: detailId, expenseCategory: categoryName, expenseAmount: detailExpenseAmount, expenseDate: dateFormatter.string(from: mainItems.expenseDate as Date), expenseNote: detailExpenseNote, imageString: categoryImageString))
            }
            detailExpense.append(detailsToInsert)
        }
    }
    
    func refreshTotalBalanceLabel(){
        totalBalance = 0
        for items in mainExpense{
            totalBalance += Int(items.expenseTotal)!
        }
        balanceLabel.text = "Rp. " + convertNumberToExplainedString(numberPassed: totalBalance)
        balanceLabel.accessibilityLabel = (totalBalance < 0 ? "Minus" : "") + convertNumberToExplainedString(numberPassed: totalBalance)
        
        dateFormatter.dateFormat = "MM"
        
        var totalBalanceThisMonth = 0
        let thisMonth = dateFormatter.string(from: Date())
        for items in mainExpense{
            let expenseMonth = dateFormatter.string(from: items.expenseDate as Date)
            if expenseMonth == thisMonth{
                totalBalanceThisMonth += Int(items.expenseTotal)!
            }
        }
        thisMonthBalanceLabel.text = "Rp. " + convertNumberToExplainedString(numberPassed: totalBalanceThisMonth)
        thisMonthBalanceLabel.accessibilityLabel = (totalBalanceThisMonth < 0 ? "Minus" : "") + convertNumberToExplainedString(numberPassed: totalBalanceThisMonth)
    }
    
//    func updateChartData()  {
//        var pieColumns: [String] = []
//        var pieContents: [Double] = []
//
//        for eachDetail in detailExpense{
//            for items in eachDetail{
//                if !(pieColumns.contains(items.expenseCategory)){
//                    pieColumns.append(items.expenseCategory)
//                    pieContents.append(Double(items.expenseAmount)!)
//                }else{
//                    let indexInArray: Int = pieColumns.firstIndex(of: items.expenseCategory)!
//                    pieContents[indexInArray] = pieContents[indexInArray] + Double(items.expenseAmount)!
//                }
//            }
//        }
//
//        var entries = [PieChartDataEntry]()
//        for (index, value) in pieContents.enumerated() {
//            let entry = PieChartDataEntry()
//            entry.y = value
//            entry.label = pieColumns[index]
//            entries.append(entry)
//        }
//
//        let set = PieChartDataSet(entries: entries, label: "")
//        set.drawValuesEnabled = false
//
//        var colors: [UIColor] = []
//        for rep in 0..<pieContents.count {
//            colors.append(hexToUIColor(hex: chartColorOption[rep]))
//        }
//        set.colors = colors
//
//
//        let data = PieChartData(dataSet: set)
//        pieChartView.drawEntryLabelsEnabled = false
//        pieChartView.drawCenterTextEnabled = false
//
//        if mainExpense.count != 0{
//            pieChartView.data = data
//        }
//
//        pieChartView.noDataText = "Start adding expenses by clicking the + button"
//        pieChartView.noDataTextAlignment = .center
//
//        pieChartView.isUserInteractionEnabled = false
//
//        pieChartView.holeRadiusPercent = 0.2
//        pieChartView.transparentCircleColor = UIColor.clear
//    }
//
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
    
}

