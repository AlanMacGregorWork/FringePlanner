//
//  ViewDataIsEmptyTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/12/2024.
//

import Testing
@testable import FringePlanner

@Suite("ViewDataIsEmpty Tests")
struct ViewDataIsEmptyTests {
    @Suite("Model Tests")
    struct ModelTests {
        @Test("EmptyData Supports ViewDataIsEmpty")
        func emptyData() {
            #expect(EmptyData().isEmpty == true)
        }
        
        @Test("ConditionalData Supports ViewDataIsEmpty")
        func conditionalData() {
            #expect(ConditionalData<TextData, EmptyData>(option: .first(TextData(text: "text"))).isEmpty == false)
            #expect(ConditionalData<EmptyData, TextData>(option: .first(EmptyData())).isEmpty == true)
            #expect(ConditionalData<TextData, EmptyData>(option: .second(EmptyData())).isEmpty == true)
            #expect(ConditionalData<EmptyData, TextData>(option: .second(TextData(text: "text"))).isEmpty == false)
        }
    }
    
    @Suite("Result Builder Tests")
    struct ResultBuilderTests {
        @Test("Build If: Boolean value should show/hide content", arguments: [true, false])
        func testBuildIf(show: Bool) {
            if show {
                #expect(buildIf(shouldShowText: true).option == .first(TextData(text: "test item")))
                #expect(!buildIf(shouldShowText: true).isEmpty, "Content should not be empty")
            } else {
                #expect(buildIf(shouldShowText: false).option == .second(EmptyData()))
                #expect(buildIf(shouldShowText: false).isEmpty, "Content should be empty")
            }
        }
        
        @FringeDataResultBuilder
        private func buildIf(shouldShowText: Bool) -> ConditionalData<TextData, EmptyData> {
            if shouldShowText {
                TextData(text: "test item")
            }
        }
    }
}
