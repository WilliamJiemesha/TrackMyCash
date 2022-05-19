//
//  CategoryViewController.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 03/05/22.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //Variable initialization
    var delegatePassed: changeNewDataValuesDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreDataObj = CoreDataController()
    var categoryStorage: [Category] = []
    
    //On page load function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let categoryCoreData = coreDataObj.selectAllCoreData(delegate: appDelegate, entityName: "Expense_Category")
        for items in categoryCoreData{
            categoryStorage.append(Category(categoryId: items.value(forKey: "expense_category_id") as! String, categoryName: items.value(forKey: "expense_category") as! String, imageString: items.value(forKey: "image_string") as! String))
        }
        
    }
    
    //Table Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryStorage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoriesTableViewCell
        
        let categoryName: String = categoryStorage[indexPath.row].categoryName
        let imageString: String = categoryStorage[indexPath.row].imageString
        
        if categoryName == "Income"{
            cell.categoryName.text = categoryName + " (+)"
        }else{
            cell.categoryName.text = categoryName + " (-)"
        }
        cell.categoryName.accessibilityTraits = .adjustable
        
        cell.categoryImage.image = UIImage(systemName: imageString)
        cell.categoryImage.tintColor = .tintColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        delegatePassed?.changeCategoryValue(categoryId: categoryStorage[indexPath.row].categoryId)
        self.navigationController?.popViewController(animated: true)
    }
    
    //Supporting functions
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
