//
//  isOperator.swift
//  TA1 ver2
//
//  Created by Глеб Зобнин on 12.09.2023.
//

import Foundation

func isOperator(_ char: Character) -> Bool {
    if ("+-/*()#".firstIndex(of: char) != nil) {
        return true
    }
    return false
}
