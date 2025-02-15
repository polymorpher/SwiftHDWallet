//
//  PrivateKeyTests.swift
//  HDWalletKit_Tests
//
//  Created by Pavlo Boiko on 4/18/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import XCTest
@testable import HDWalletKit

class PrivateKeyTests: XCTestCase {
    
    func testBitcoin() async {
        let address = "1MVEQHYUv1bWiYJB77NNEEEdbmNFEoW5q6"
        let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        
        let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        let uncompressedPk = "5HvdNYs1baLY7vpnmb2osg5gZHvAFxDiBoCujs2vfTjC442rzSK"
        let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
        for pk in [hexPk, compressedPk, uncompressedPk] {
            await testImportFromPK(coin: .bitcoin, privateKey: pk, address: address, raw: rawPk)
        }
    }
    
    func testBitcoinCash() async {
        let address = "1MVEQHYUv1bWiYJB77NNEEEdbmNFEoW5q6"
        let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        
        let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        let uncompressedPk = "5HvdNYs1baLY7vpnmb2osg5gZHvAFxDiBoCujs2vfTjC442rzSK"
        let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
        for pk in [hexPk, compressedPk, uncompressedPk] {
            await testImportFromPK(coin: .bitcoin, privateKey: pk, address: address, raw: rawPk)
        }
    }
    
    // TODO: Dogecoin and Litecoin tests fail
//    func testDogecoin() async {
//         let address = "DHhBBVF46Wzc8pR6swZD9GoDdX8x7MDgvw"
//         let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
//
//         let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
//         let uncompressedPk = "6KetuZozmLRbBFKM474EcBNFo5w6zuRRWM661hjFZzobJoLuNCh"
//         let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
//        for pk in [hexPk, compressedPk, uncompressedPk] {
//            await testImportFromPK(coin: .bitcoin, privateKey: pk, address: address, raw: rawPk)
//        }
//    }
//
//    func testLitecoin() async {
//        let address = "Lbre6AY3tc8X2GJ2tKERVvcCA4S2EzF6wJ"
//        let rawPk = "857cfceb9726ba7165fdcda93c056d35a8ba9b90a8c77fac524a309d832de107"
//
//        let hexPk = "857cfceb9726ba7165fdcda93c056d35a8ba9b90a8c77fac524a309d832de107"
//        let uncompressedPk = "6v8opvTbpSE2WwTv4rhEvSVK1jqGTXKRkWk484gxmc4TtQzDu53"
//        let compressedPk = "T7XTgWxQgNLVh9PoE2LcSsVxWG43E4pLF4H2nBHP9skHfjshodfM"
//        for pk in [hexPk, compressedPk, uncompressedPk] {
//            await testImportFromPK(coin: .bitcoin, privateKey: pk, address: address, raw: rawPk)
//        }
//    }
    
    func testHarmony() async {
        let address = "one1a50tun737ulcvwy0yvve0pvu5skq0kjargvhwe"
        let rawPk = "e2f88b4974ae763ca1c2db49218802c2e441293a09eaa9ab681779e05d1b7b94"
        
        let hexPk = "e2f88b4974ae763ca1c2db49218802c2e441293a09eaa9ab681779e05d1b7b94"
        await testImportFromPK(coin: .harmony, privateKey: hexPk, address: address, raw: rawPk)
    }
    
    func testImportFromPK(coin: Coin, privateKey: String, address: String, raw: String) async {
        guard let pk = await PrivateKey(pk: privateKey, coin: coin) else {
            XCTFail("pk is nil for coin: \(coin.scheme)")
            return
        }
        XCTAssertEqual(pk.publicKey.address, address)
        XCTAssertEqual(pk.raw, Data(hex: raw))
    }
    
}

