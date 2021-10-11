//
//  KeystoreTests.swift
//  HDWalletKit_Tests
//
//  Created by Pavlo Boiko on 22.08.18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import XCTest
@testable import HDWalletKit

class KeystoreTests: XCTestCase {
    
    func testKeyStoreGeneration() async throws {
        let data = Data("abandon amount liar amount expire adjust cage candy arch gather drum buyer".utf8)
        let passwordData =  Data("qwertyui".utf8)
        let keystore = try await KeystoreV3(privateKey: data, passwordData: passwordData)
        XCTAssertEqual(keystore?.keystoreParams?.crypto.cipher, "aes-128-ctr")
        XCTAssertEqual(keystore?.keystoreParams?.crypto.kdf, "scrypt")
        XCTAssertEqual(keystore?.keystoreParams?.crypto.kdfparams.r, 8)
        XCTAssertEqual(keystore?.keystoreParams?.crypto.kdfparams.p, 1)
        XCTAssertEqual(keystore?.keystoreParams?.crypto.kdfparams.n, 1024)
        XCTAssertEqual(keystore?.keystoreParams?.crypto.kdfparams.dklen, 32)
    }
    
    func testDecodeKeystore() async throws {
        let data = Data("abandon amount liar amount expire adjust cage candy arch gather drum buyer".utf8)
        let passwordData =  Data("qwertyui".utf8)
        let keystore = try await KeystoreV3(privateKey: data, passwordData: passwordData)
        guard let decoded = try await keystore?.getDecryptedKeyStore(passwordData: passwordData) else {
            XCTFail()
            return
        }
        XCTAssertEqual(decoded, data)
    }
    
    func testDecodeKeystoreFile() async throws {
        let data = Data("abandon amount liar amount expire adjust cage candy arch gather drum buyer".utf8)
        let passwordData =  Data("qwertyui".utf8)
        guard let keystore = try await KeystoreV3(privateKey: data, passwordData: passwordData) else {
            XCTFail()
            return
        }
        let fileData = try keystore.encodedData()
        guard let recoveredKeystore = try KeystoreV3(keyStore: fileData), let decoded = try await recoveredKeystore.getDecryptedKeyStore(passwordData: passwordData) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decoded, data)
    }
}
