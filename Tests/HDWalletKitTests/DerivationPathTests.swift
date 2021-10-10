//
//  File.swift
//  File
//
//  Created by Ronald Mannak on 8/4/21.
//

import XCTest
@testable import HDWalletKit

class DerivationPathTests: XCTestCase {
    
    private var mnemonic: String!
    
    override func setUp() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        mnemonic = Mnemonic.create(entropy: entropy)
    }
    
    func testDerivationPath() async throws {
        
        XCTAssertEqual(mnemonic, "abandon amount liar amount expire adjust cage candy arch gather drum buyer")
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        
        let privateKey = await PrivateKey(seed: seed, coin: .ethereum)
        // BIP44 key derivation
        // m/44'
        let purpose = await privateKey.derived(at: .hardened(44))

        // m/44'/60'
        let coinType = await purpose.derived(at: .hardened(60))

        // m/44'/60'/0'
        let account = await coinType.derived(at: .hardened(0))

        // m/44'/60'/0'/0
        let change = await account.derived(at: .notHardened(0))

        let derivatedPrivateKey = try await privateKey.privateKey(at: "m/44'/60'/0'/0")
        
        XCTAssertEqual(change.get(), derivatedPrivateKey.get())
        XCTAssertEqual(change.publicKey.address, derivatedPrivateKey.publicKey.address)
        
        XCTAssertNotEqual(privateKey.get(), derivatedPrivateKey.get())
        XCTAssertNotEqual(privateKey.publicKey.address, derivatedPrivateKey.publicKey.address)
        
        XCTAssertEqual(privateKey.publicKey.address, "0xb538E2A54a8F3021cB064dDD18dc3700D6215612")
        XCTAssertEqual(change.publicKey.address, "0x6cd36F07a758152A04044d488AcD90F6798f245d")
    }
    
    func testDerivationPathLedger() async throws {

        XCTAssertEqual(mnemonic, "abandon amount liar amount expire adjust cage candy arch gather drum buyer")
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        
        let privateKey = await PrivateKey(seed: seed, coin: .ethereum)
        // BIP44 key derivation
        // m/44'
        let purpose = await privateKey.derived(at: .hardened(44))

        // m/44'/60'
        let coinType = await purpose.derived(at: .hardened(60))

        // m/44'/60'/12'
        let account = await coinType.derived(at: .hardened(12))

        // m/44'/60'/0'/0
        let change = await account.derived(at: .notHardened(0))
        
        // m/44'/0'/0'/0/0
        let addressIndex = await change.derived(at: .notHardened(0))

        let derivatedPrivateKey = try await privateKey.privateKey(at: "m/44'/60'/12'/0/0")

        XCTAssertEqual(addressIndex.get(), derivatedPrivateKey.get())
        XCTAssertEqual(addressIndex.publicKey.address, derivatedPrivateKey.publicKey.address)
        
        XCTAssertNotEqual(privateKey.get(), derivatedPrivateKey.get())
        XCTAssertNotEqual(privateKey.publicKey.address, derivatedPrivateKey.publicKey.address)
        
        XCTAssertEqual(privateKey.publicKey.address, "0xb538E2A54a8F3021cB064dDD18dc3700D6215612")
        XCTAssertEqual(addressIndex.publicKey.address, "0xe4967065874AFE4cb578F423c4B489D4ECf3BB2f")
        
    }
}
