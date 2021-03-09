//
//  ColorTests.swift
//  CalculatorColorsTests
//
//  Created by Daniel Spady on 2021-03-08.
//

import XCTest
import Combine
import SwiftUI
@testable import CalculatorColors

class ColorTests: XCTestCase {
    
    var viewModel: CalculatorViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        viewModel = CalculatorViewModel()
    }

    override func tearDownWithError() throws {
        subscriptions = []
    }
    
    func testCorrectNameReceived() {
        // Given
        let expected = "006636AA 66%"
        var result = ""

        viewModel.$name
          .sink(receiveValue: { result = $0 })
          .store(in: &subscriptions)

        // When
        viewModel.hexText = "\(ColorList.rwGreen.rawValue)AA"

        // Then
        XCTAssert(result == expected, "Name expected to be \(expected) but was \(result)")
    }
    
    func testBackSpace() {
        // Given
        let expected = "#0080F"
        var result = ""

        viewModel.$hexText
          .dropFirst()
          .sink(receiveValue: { result = $0 })
          .store(in: &subscriptions)

        // When
        viewModel.process(CalculatorViewModel.Constant.backspace)

        // Then
        XCTAssert(result == expected, "Hex was expected to be \(expected) but was \(result)")
    }
    
    func testCorrectColorReceived() {
        // Given
        let expected = Color(hex: ColorList.rwGreen.rawValue)!
        var result: Color = .clear

        viewModel.$color
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        // When
        viewModel.hexText = ColorList.rwGreen.rawValue

        // Then
        XCTAssert(result == expected, "Color expected to be \(expected) but was \(result)")
    }

    func testProcessBackspaceReceivesCorrectColor() {
        // Given
        let expected = Color.white
        var result = Color.clear

        viewModel.$color
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        // When
        viewModel.process(CalculatorViewModel.Constant.backspace)

        // Then
        XCTAssert(result == expected, "Hex was expected to be \(expected) but was \(result)")
    }

    func testWhiteColorReceivedForBadData() {
        // Given
        let expected = Color.white
        var result = Color.clear
        
        viewModel.$color
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        // When
        viewModel.hexText = "abc"

        // Then
        XCTAssert(result == expected, "Color expected to be \(expected) but was \(result)")
    }
}
