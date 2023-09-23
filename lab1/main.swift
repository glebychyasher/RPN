//
//  main.swift
//  TA1 ver2
//
//  Created by Глеб Зобнин on 12.09.2023.
//
while true {
    print("Введите выражение: ")
    let expression = readLine()
    if expression == "end" {
        break
    }
    let mather = Mather(expression: expression ?? "0")
    if let result = mather.Calc(){
        if mather.postfixExpression != "e" {
            print("Постфиксная форма: " + mather.postfixExpression)
            print("Итого: " + String(result))
        }
    }
}


