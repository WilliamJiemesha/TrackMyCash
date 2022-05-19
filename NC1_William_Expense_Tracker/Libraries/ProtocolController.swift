//
//  ProtocolControllers.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 02/05/22.
//

import Foundation
protocol changeNewDataValuesDelegate{
    func changeAmountValue(amount: String)
    func changeDateValue(date: String)
    func changeNoteValue(note: String)
    func changeCategoryValue(categoryId: String)
}
protocol updateDataDelegate{
    func updateData()
}
