//
//  ConverterTests.swift
//  HDWalletKit_Tests
//
//  Created by Pavlo Boiko on 10/10/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import XCTest
@testable import HDWalletKit

class ConverterTests: XCTestCase {
    
    func testEthereumConverter() {
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("100000000000000")!), 0.0001)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000")!), 0.001)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("10000000000000000")!), 0.01)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("100000000000000000")!), 0.1)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000000")!), 1)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("10000000000000000000")!), 10)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("100000000000000000000")!), 100)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000000000")!), 1000)
        
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("0xDE0B6B3A7640000", radix: 16)!), 1)
        
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000")!), 0.001)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("10000000000000000")!), 0.01)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("100000000000000000")!), 0.1)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000000")!), 1)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("10000000000000000000")!), 10)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("100000000000000000000")!), 100)
        XCTAssertEqual(try! WeiEtherConverter.toEther(wei: Wei("1000000000000000000000")!), 1000)
        
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "0.0001")!).description, "100000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "0.001")!).description, "1000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "0.01")!).description, "10000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "0.1")!).description, "100000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "1")!).description, "1000000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "10")!).description, "10000000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "100")!).description, "100000000000000000000")
        XCTAssertEqual(try! WeiEtherConverter.toWei(ether: Ether(string: "1000")!).description, "1000000000000000000000")
        
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 1), 1000000000)
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 10), 10000000000)
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 15), 15000000000)
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 30), 30000000000)
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 60), 60000000000)
        XCTAssertEqual(WeiEtherConverter.toWei(GWei: 99), 99000000000)
    }
    
    func testEthereumTokensConvert() {
        XCTAssertEqual(try! WeiEtherConverter.toToken(balance: "0x2d79883d2000", decimals: 12, radix: 16).description, "50")
        XCTAssertEqual(try! WeiEtherConverter.toToken(balance: "50000000000000", decimals: 12, radix: 10).description, "50")
    }
    
    func testHarmonyConverter() {
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("100000000000000")!), 0.0001)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000")!), 0.001)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("10000000000000000")!), 0.01)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("100000000000000000")!), 0.1)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000000")!), 1)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("10000000000000000000")!), 10)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("100000000000000000000")!), 100)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000000000")!), 1000)
        
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("0xDE0B6B3A7640000", radix: 16)!), 1)
        
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000")!), 0.001)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("10000000000000000")!), 0.01)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("100000000000000000")!), 0.1)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000000")!), 1)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("10000000000000000000")!), 10)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("100000000000000000000")!), 100)
        XCTAssertEqual(try! AttoOneConverter.toOne(atto: Atto("1000000000000000000000")!), 1000)
        
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "0.0001")!).description, "100000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "0.001")!).description, "1000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "0.01")!).description, "10000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "0.1")!).description, "100000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "1")!).description, "1000000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "10")!).description, "10000000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "100")!).description, "100000000000000000000")
        XCTAssertEqual(try! AttoOneConverter.toAtto(one: One(string: "1000")!).description, "1000000000000000000000")
        
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 1), 1000000000)
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 10), 10000000000)
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 15), 15000000000)
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 30), 30000000000)
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 60), 60000000000)
        XCTAssertEqual(AttoOneConverter.toAtto(GAtto: 99), 99000000000)
    }
    
    func testHarmonyConvert() {
        XCTAssertEqual(try! AttoOneConverter.toToken(balance: "0x2d79883d2000", decimals: 12, radix: 16).description, "50")
        XCTAssertEqual(try! AttoOneConverter.toToken(balance: "50000000000000", decimals: 12, radix: 10).description, "50")
    }
}
