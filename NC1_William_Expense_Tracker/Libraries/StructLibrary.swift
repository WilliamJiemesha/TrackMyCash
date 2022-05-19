//
//  StructLibrary.swift
//  NC1_William_Expense_Tracker
//
//  Created by William on 28/04/22.
//

import Foundation

struct ExpenseStructure{
    var expenseId: String
    var expenseDate: NSDate
    var expenseTotal: String
}
struct ExpenseDetailStructure{
    var expenseCategoryId: String
    var expenseAmount: String
    var expenseNote: String
    var expenseId: String
    var expenseDetailId: String
}
struct ExpenseDetailToDisplay{
    var expenseDetailId: String
    var expenseCategory: String
    var expenseAmount: String
    var expenseDate: String
    var expenseNote: String
    var imageString: String
}

struct ExpenseDetailDisplay{
    var expenseDetailId: String
    var expenseCategory: String
    var expenseAmount: String
    var imageString: String
}
 
struct Category{
    var categoryId: String
    var categoryName: String
    var imageString: String
}

