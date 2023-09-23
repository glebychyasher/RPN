//
//  isDelimeter.swift
//  TA1 ver2
//
//  Created by Глеб Зобнин on 12.09.2023.
//

import Foundation
func isDelimeter(_ char: Character) -> Bool {
    if char == " " || char == "\t" {
        return true
    }
    return false
}
