//
//  DecodableContainerTests.swift
//  Hyperspace_Example
//
//  Created by Will McGinty on 12/5/17.
//  Copyright © 2017 Bottle Rocket Studios. All rights reserved.
//

import XCTest
@testable import Hyperspace
import Result

class DecodingTests: XCTestCase {
    
    // MARK: - Properties
    
    private static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    // MARK: - Tests
    
    func test_DecodingDecodableContainer_AutomaticallyDecodesChildElement() {
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(MockDecodableContainer.self, from: objectJSON)
            let child = container.element
            XCTAssertEqual(child.title, "Title")
            XCTAssertEqual(child.subtitle, "Subtitle")
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_DecodingDecodableContainer_AutomaticallyDecodesChildElements() {
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(MockArrayDecodableContainer.self, from: objectJSON)
            let children = container.element
            
            for index in children.startIndex..<children.endIndex {
                let child = children[index]
                XCTAssertEqual(child.title, "Title \(index)")
                XCTAssertEqual(child.subtitle, "Subtitle \(index)")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_RequestDefaultsContainer_AutomaticallyDecodesChildElement() {
        let function: RequestTransformBlock<MockObject, AnyError> = RequestDefaults.dataTransformer(for: JSONDecoder(), withContainerType: MockDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let mockObject = function(serviceSuccess)
        XCTAssertNotNil(mockObject.value)
    }
    
    func test_RequestDefaultsContainer_AutomaticallyDecodesChildElements() {
        let function: RequestTransformBlock<[MockObject], AnyError> = RequestDefaults.dataTransformer(for: JSONDecoder(), withContainerType: MockArrayDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let mockObject = function(serviceSuccess)
        XCTAssertNotNil(mockObject.value)
    }
    
    func test_RequestDefaultsContainer_ThrowsErrorForChildElement() {
        let function: RequestTransformBlock<MockObject, AnyError> = RequestDefaults.dataTransformer(for: JSONDecoder(), withContainerType: MockDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let mockObject = function(serviceSuccess)
        XCTAssertNotNil(mockObject.error)
    }
    
    func test_RequestDefaultsContainer_ThrowsErrorForChildElements() {
        let function: RequestTransformBlock<[MockObject], AnyError> = RequestDefaults.dataTransformer(for: JSONDecoder(), withContainerType: MockArrayDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let mockObject = function(serviceSuccess)
        XCTAssertNotNil(mockObject.error)
    }
    
    func test_AnyRequestWithDefaultJSONDecoder_SuccessfullyDecodes() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, decoder: JSONDecoder())
        let objectJSON = loadedJSONData(fromFileNamed: "Object")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithImplicitJSONDecoder_SuccessfullyDecodes() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL)
        let objectJSON = loadedJSONData(fromFileNamed: "Object")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithISOJSONDecoder_SuccessfullyDecodes() {
        let decoder = JSONDecoder()
        
        if #available(iOS 10.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            decoder.dateDecodingStrategy = .formatted(DecodingTests.iso8601DateFormatter)
        }
        
        let request = AnyRequest<MockDate>(method: .get, url: RequestTestDefaults.defaultURL, decoder: decoder)
        let objectJSON = loadedJSONData(fromFileNamed: "DateObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithImplicitJSONDecoder_DecodeFails() {
        let request = AnyRequest<MockDate>(method: .get, url: RequestTestDefaults.defaultURL)
        let objectJSON = loadedJSONData(fromFileNamed: "DateObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNil(result.value)
    }
    
    func test_AnyRequestWithDecodableContainer_SuccessfullyDecodesChildElement() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, containerType: MockDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }

    func test_AnyRequestWithDecodableContainer_SuccessfullyDecodesChildElements() {
        let request = AnyRequest<[MockObject]>(method: .get, url: RequestTestDefaults.defaultURL, containerType: MockArrayDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithDecodableContainer_FailsToDecodesChildElement() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, containerType: MockDecodableContainer.self)
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNil(result.value) //Should fail because RootKeyArray json contains [MockObject], not a single MockObject
    }
    
    func test_AnyRequestWithRootDecodableKey_SuccessfullyDecodesChildElement() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, rootDecodingKey: "root_key")
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithRootDecodableKey_SuccessfullyDecodesChildElements() {
        let request = AnyRequest<[MockObject]>(method: .get, url: RequestTestDefaults.defaultURL, rootDecodingKey: "root_key")
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyArray")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithRootDecodableKey_SuccessfullyDecodesChildElementWhenExtraJSONPresent() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, rootDecodingKey: "root_key")
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObjectPlus")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNotNil(result.value)
    }
    
    func test_AnyRequestWithRootDecodableKey_FailsWithIncorrectKey() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, rootDecodingKey: "incorrectkey")
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyObject")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNil(result.value)
        
        let decodeError = result.error!.error as! DecodingError
        guard case let .valueNotFound(missingType, context) = decodeError else {
            return XCTFail("Decoding should fail with a .valueNotFound error")
        }
        
        XCTAssert(missingType == MockObject.self)
        XCTAssertTrue(context.codingPath.isEmpty)
        XCTAssertEqual(context.debugDescription, "No value found at root key \"incorrectkey\".")
    }
    
    func test_AnyRequestWithRootDecodableKey_FailsWithIncorrectType() {
        let request = AnyRequest<MockObject>(method: .get, url: RequestTestDefaults.defaultURL, rootDecodingKey: "root_key")
        let objectJSON = loadedJSONData(fromFileNamed: "RootKeyIncorrectType")
        let serviceSuccess = NetworkServiceSuccess(data: objectJSON, response: HTTP.Response(code: 200, data: objectJSON))
        let result = request.transformSuccess(serviceSuccess)
        XCTAssertNil(result.value)
        
        let decodeError = result.error!.error as! DecodingError
        guard case let DecodingError.keyNotFound(codingKey, context) = decodeError else {
            return XCTFail("Decoding should fail with a .keyNotFound error")
        }
        
        XCTAssertEqual(codingKey.stringValue, "title")
        XCTAssertTrue(context.codingPath.isEmpty)
        XCTAssertEqual(context.debugDescription, "No value associated with key CodingKeys(stringValue: \"title\", intValue: nil) (\"title\").")
    }
    
    func test_AnyDecodable_testFunctionalJSONDecoding() {
        let mixedJSON = loadedJSONData(fromFileNamed: "MixedTypeObject")
        let dictionary = try! JSONDecoder().decode([String: AnyDecodable].self, from: mixedJSON)
        
        XCTAssertEqual(dictionary["boolean"]?.value as! Bool, true)
        XCTAssertEqual(dictionary["integer"]?.value as! Int, 1)
        XCTAssertEqual(dictionary["double"]?.value as! Double, 3.14159265358979323846, accuracy: 0.001)
        XCTAssertEqual(dictionary["string"]?.value as! String, "string")
        XCTAssertEqual(dictionary["array"]?.value as! [Int], [1, 2, 3])
        XCTAssertEqual(dictionary["nested"]?.value as! [String: String], ["a": "alpha", "b": "bravo", "c": "charlie"])
    }
    
    // swiftlint:disable syntactic_sugar
    func test_AnyDecodable_testEqualityOfUnderlyingType() {
        XCTAssertEqual(AnyDecodable(Optional<Int>.none), AnyDecodable(Optional<Int>.none))
        
        XCTAssertEqual(AnyDecodable(true), AnyDecodable(true))
        XCTAssertNotEqual(AnyDecodable(true), AnyDecodable(false))
        
        XCTAssertEqual(AnyDecodable(2), AnyDecodable(2))
        XCTAssertNotEqual(AnyDecodable(2), AnyDecodable(4))
        
        XCTAssertEqual(AnyDecodable(Int8(2)), AnyDecodable(Int8(2)))
        XCTAssertNotEqual(AnyDecodable(Int8(2)), AnyDecodable(Int8(3)))
        
        XCTAssertEqual(AnyDecodable(Int16(2)), AnyDecodable(Int16(2)))
        XCTAssertNotEqual(AnyDecodable(Int16(2)), AnyDecodable(Int16(7)))
        
        XCTAssertEqual(AnyDecodable(Int32(2)), AnyDecodable(Int32(2)))
        XCTAssertNotEqual(AnyDecodable(Int32(2)), AnyDecodable(Int32(3)))
        
        XCTAssertEqual(AnyDecodable(Int64(2)), AnyDecodable(Int64(2)))
        XCTAssertNotEqual(AnyDecodable(Int64(2)), AnyDecodable(Int64(6)))
        
        XCTAssertEqual(AnyDecodable(UInt(2)), AnyDecodable(UInt(2)))
        XCTAssertNotEqual(AnyDecodable(UInt(2)), AnyDecodable(UInt(7)))
        
        XCTAssertEqual(AnyDecodable(UInt8(2)), AnyDecodable(UInt8(2)))
        XCTAssertNotEqual(AnyDecodable(UInt8(2)), AnyDecodable(UInt8(8)))
        
        XCTAssertEqual(AnyDecodable(UInt16(2)), AnyDecodable(UInt16(2)))
        XCTAssertNotEqual(AnyDecodable(UInt16(2)), AnyDecodable(UInt16(8)))
        
        XCTAssertEqual(AnyDecodable(UInt32(2)), AnyDecodable(UInt32(2)))
        XCTAssertNotEqual(AnyDecodable(UInt32(2)), AnyDecodable(UInt32(6)))
        
        XCTAssertEqual(AnyDecodable(UInt64(2)), AnyDecodable(UInt64(2)))
        XCTAssertNotEqual(AnyDecodable(UInt64(2)), AnyDecodable(UInt64(4)))
        
        XCTAssertEqual(AnyDecodable(Float(2.0)), AnyDecodable(Float(2.0)))
        XCTAssertNotEqual(AnyDecodable(Float(2.0)), AnyDecodable(Float(5.0)))
        
        XCTAssertEqual(AnyDecodable(Double(2.0)), AnyDecodable(Double(2.0)))
        XCTAssertNotEqual(AnyDecodable(Double(2.0)), AnyDecodable(Double(5.0)))
        
        XCTAssertEqual(AnyDecodable("string"), AnyDecodable("string"))
        XCTAssertNotEqual(AnyDecodable("string"), AnyDecodable("a string"))
        
        XCTAssertEqual(AnyDecodable([AnyDecodable(1), AnyDecodable(2), AnyDecodable(3)]), AnyDecodable([AnyDecodable(1), AnyDecodable(2), AnyDecodable(3)]))
        XCTAssertNotEqual(AnyDecodable([AnyDecodable(1), AnyDecodable(2), AnyDecodable(3)]), AnyDecodable([AnyDecodable(1), AnyDecodable(2), AnyDecodable(4)]))
        
        XCTAssertEqual(AnyDecodable(["val": AnyDecodable(1)]), AnyDecodable(["val": AnyDecodable(1)]))
        XCTAssertNotEqual(AnyDecodable(["val": AnyDecodable(1)]), AnyDecodable(["val": AnyDecodable(2)]))
    }
    
    func test_AnyDecodable_testDescriptionOfUnderlyingType() {
        
        let nilDecodable = AnyDecodable(Optional<Int>.none)
        let mock = MockObject(title: "t", subtitle: "s")
        let nonStringConvertible = AnyDecodable(mock)
    
        let obj = NSObject()
        let stringConvertible = AnyDecodable(obj)
        
        XCTAssertEqual(nilDecodable.description, String(describing: nil as Any?))
        XCTAssertEqual(nonStringConvertible.description, String(describing: mock))
        XCTAssertEqual(stringConvertible.description, obj.description)
    }
    // swiftlint:enable syntactic_sugar

}
