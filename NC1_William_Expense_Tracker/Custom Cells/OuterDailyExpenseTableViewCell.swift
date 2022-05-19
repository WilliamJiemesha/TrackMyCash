//
//  OuterDailyExpenseTableViewCell.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 26/04/22.
//

import UIKit

class OuterDailyExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var expenseDate: UILabel!
    @IBOutlet weak var expenseMonth: UILabel!
    @IBOutlet weak var expenseYear: UILabel!
    @IBOutlet weak var expenseAmount: UILabel!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
