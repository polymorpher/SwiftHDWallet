//
//  File.swift
//  File
//
//  Created by Ronald Mannak on 8/4/21.
//

import XCTest
@testable import HDWalletKit

class DerivationPathTests: XCTestCase {
    func testDerivationPath() {
        
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        XCTAssertEqual(mnemonic, "abandon amount liar amount expire adjust cage candy arch gather drum buyer")
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        
        let privateKey = PrivateKey(seed: seed, coin: .ethereum)
        // BIP44 key derivation
        // m/44'
        let purpose = privateKey.derived(at: .hardened(44))

        // m/44'/60'
        let coinType = purpose.derived(at: .hardened(60))

        // m/44'/60'/0'
        let account = coinType.derived(at: .hardened(0))

        // m/44'/60'/0'/0
        let change = account.derived(at: .notHardened(0))

        let derivatedPrivateKey = try! privateKey.privateKey(at: "m/44'/60'/0'/0")
        
        XCTAssertEqual(change.get(), derivatedPrivateKey.get())
        XCTAssertEqual(change.publicKey.address, derivatedPrivateKey.publicKey.address)
        XCTAssertNotEqual(privateKey.get(), derivatedPrivateKey.get())
        XCTAssertNotEqual(privateKey.publicKey.address, derivatedPrivateKey.publicKey.address)
    }
}
