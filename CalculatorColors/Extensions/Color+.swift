//
//  Color+.swift
//  CalculatorColors
//
//  Created by Daniel Spady on 2021-03-08.
//

import SwiftUI

extension Color {
    
    static func normalized(hex: String) -> String? {
        var normalizedHex = hex
        
        if hex.hasPrefix("#") == false {
            normalizedHex.insert("#", at: normalizedHex.startIndex)
        }
        
        guard normalizedHex.count > 6, normalizedHex.count < 10 else { return nil }
        return normalizedHex.padding(toLength: 9, withPad: "F", startingAt: 0)
    }
    
    static func opacityString(forHex hex: String) -> String {
        guard let opacity = redGreenBlueOpacity(forHex: hex)?.3 else { return "" }
        return "\(Int(opacity * 100))%"
    }
    
    static func redGreenBlueOpacity(forHex hex: String)
      -> (Double, Double, Double, Double)? {
        
        guard let adjustedHex = normalized(hex: hex) else { return nil }
        
        let red, green, blue, opacity: Double
        let start = adjustedHex.index(adjustedHex.startIndex, offsetBy: 1)
        let hexString = String(adjustedHex[start...])
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        red = Double((hexNumber & 0xff000000) >> 24) / 255
        green = Double((hexNumber & 0x00ff0000) >> 16) / 255
        blue = Double((hexNumber & 0x0000ff00) >> 8) / 255
        opacity = Double(hexNumber & 0x000000ff) / 255
        
        return (red, green, blue, opacity)
    }
    
    init?(hex: String) {
        guard let adjustedHex = Color.normalized(hex: hex),
              let (red, green, blue, opacity) = Color.redGreenBlueOpacity(forHex: adjustedHex)
        else { return nil }
        
        self.init(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(values: (red: Double, green: Double, blue: Double, opacity: Double)) {
        self.init(
            .displayP3,
            red: values.red,
            green: values.green,
            blue: values.blue,
            opacity: values.opacity
        )
    }
}
