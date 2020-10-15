//
//  HarmonyCryptoTests.swift
//  HDWalletKitTests
//
//  Created by Ronald Mannak on 2020/10/14
//  Copyright © 2020 Starling Protocol. All rights reserved.
//

import XCTest
@testable import HDWalletKit

class HarmonyCryptoTests: XCTestCase {
    
    func testSHA3Keccak256() {
        let data = "Hello".data(using: .utf8)!
        let encrypted = Crypto.sha3keccak256(data: data)
        XCTAssertEqual(encrypted.toHexString(), "06b3dfaec148fb1bb2b066f10ec285e7c9bf402ab32aa78a5d38e34566810cd2")
    }
    
    func testPrivateKeySign() {
        
        let signer = HarmonySigner(chainId: 2)
        let rawTransaction1 = HarmonyRawTransaction(
            value: BInt("2000000000000", radix: 10)!,
            to: "one1a0x3d6xpmr6f8wsyaxd9v36pytvp48zckswvv9",
            gasPrice: 1,
            gasLimit: 80000000,
            fromShard: 0,
            toShard: 0,
            nonce: 1,
            payload: Data()
        )
        
        XCTAssertEqual(
            try! signer.hash(rawTransaction: rawTransaction1).toHexString(),
            "12dbe15810342a13bdc1cc34cf7095b506a4307bf408a82e752fef69dbe99650"
        )
        
        let rawTransaction2 = HarmonyRawTransaction(
            value: BInt("10000000000000000", radix: 10)!,
            to: "one1a0x3d6xpmr6f8wsyaxd9v36pytvp48zckswvv9",
            gasPrice: 99000000000,
            gasLimit: 200000,
            fromShard: 0,
            toShard: 1,
            nonce: 4
        )
        
        XCTAssertEqual(
            try! signer.hash(rawTransaction: rawTransaction2).toHexString(),
            "6a8ea10b00dfa3b0e359235e4cd6875bdb4d82851dc61957d1da6c4488a83ca6"
        )
        
        let rawTransaction3 = HarmonyRawTransaction(
            value: BInt("20000000000000000", radix: 10)!,
            to: "one1d2rngmem4x2c6zxsjjz29dlah0jzkr0k2n88wc",
            gasPrice: 99000000000,
            gasLimit: 21000,
            fromShard: 2,
            toShard: 0,
            nonce: 25)
        
        XCTAssertEqual(
            try! signer.hash(rawTransaction: rawTransaction3).toHexString(),
            "0f9a6c4ee947c669ab8dacddddfb1c4d6ef9ea7696045bcb025f2ada42457c9c"
        )
    }
    
    func testDecode() {
//        let rawTx = Data(hex: "0xf85501018404c4b4008080808601d1a94a20008027a0d59a95830872a579273db651d64441cfa6552230dead4e0e098c179ac202f5f1a019b27be67ce57bb5a37df00de259124b5a491649f98caab31b1a05cd4fe54c28")
//        let signer = HarmonySigner(chainId: 2)
        
//        let decoded = signer.decode
        //        let decoded = AnySigner.decode(data: rawTx, coin: .ethereum)
        //
        //        let expected = """
        //        {
        //          "gas": "0x77fb",
        //          "gasPrice": "0xb2d05e00",
        //          "input": "0x1896f70ae71cd96d4ba1c4b512b0c5bee30d2b6becf61e574c32a17a67156fa9ed3c4c6f0000000000000000000000004976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41",
        //          "nonce": "0x64",
        //          "to": "0x00000000000c2e074ec69a0dfb2997ba6c7d2e1e",
        //          "value": "0x",
        //          "v": "0x25",
        //          "r": "0xb55e479d5872b7531437621780ead128cd25d8988fb3cda9bcfb4baeb0eda4df",
        //          "s": "0x77b096cf0cb4bee6eb8c756e9cdba95a6cf62af74e05e7e4cdaa8100271a508d"
        //        }
        //        """
        //        assert(String(data: decoded, encoding: .utf8)! == expected)
    }
    
    func testGeneratingRSV() {
        let signature = Data(hex: "0x31326462653135383130333432613133626463316363333463663730393562353036613433303762663430386138326537353266656636396462653939363530")
        let signer = HarmonySigner(chainId: 2)
        let sig = signer.calculateRSV(signature: signature)
        
        
        XCTAssertEqual(sig.r.asString(withBase: 16), "84cc200aab11f5e1b2f7ece0d56ec67385ac50cefb6e3dc2a2f3e036ed575a5c")
        XCTAssertEqual(sig.s.asString(withBase: 16), "643f18005b790cac8d8e7dc90e6147df0b83874b52db198864694ea28a79e6fc")
        XCTAssertEqual(sig.v.asString(withBase: 16), "28")
        let restoredSignature = signer.calculateSignature(sig)
        XCTAssertEqual(signature, restoredSignature)
    }
    
    func testRestoringSignatureSignedWithOldScheme() {
        let v = 27
        let r = "75119860711638973245538703589762310947594328712729260330312782656531560398776"
        let s = "51392727032514077370236468627319183981033698696331563950328005524752791633785"
        let signer = EIP155Signer(chainId: 1)
        let signature = signer.calculateSignature(r: BInt(r)!, s: BInt(s)!, v: BInt(v))
        XCTAssertEqual(signature.toHexString(), "a614559de76862bb1dbf8a969d8979e5bf21b72c51c96b27b3d247b728ebffb8719f40b018940ffd0880285d2196cdd31a710bf7cdda60c77632743d687dff7900")
        
        let r1 = "79425995431864040500581522255237765710685762616259654871112297909982135982384"
        let s1 = "1777326029228985739367131500591267170048497362640342741198949880105318675913"
        let signature1 = signer.calculateSignature(r: BInt(r1)!, s: BInt(s1)!, v: BInt(v))
        XCTAssertEqual(signature1.toHexString(), "af998533cdac5d64594f462871a8ba79fe41d59295e39db3f069434c9862193003edee4e64d899a2c57bd726e972bb6fdb354e3abcd5846e2315ecfec332f5c900")
    }
    
    func testCreatePublicKey() {
        let pk = PrivateKey(pk: "3cdb9ed21dedc0c454634f148685df05a6c5fb44bcbb4fda127705d8912498ee", coin: .harmony)!
        let publicKey = Crypto.generatePublicKey(data: pk.raw, compressed: true)
        XCTAssertEqual(publicKey.toHexString(), "02b932afb33896fddeec46718644292a7cdcf8d65b8da88194c2a4b7f7f695e591")
        let publicKey2 = pk.publicKey.get()
        XCTAssertEqual(publicKey2, "02b932afb33896fddeec46718644292a7cdcf8d65b8da88194c2a4b7f7f695e591")
        
//        assert(account.rawPrivateKey == "3cdb9ed21dedc0c454634f148685df05a6c5fb44bcbb4fda127705d8912498ee")
//        assert(account.privateKey.publicKey.get() == "02b932afb33896fddeec46718644292a7cdcf8d65b8da88194c2a4b7f7f695e591")
//        assert(account.address == "one1kx8f98avylkglwlns8rv5jp4yk09pwrnyhk98z")
    }
    
//    func bip44PrivateKey(coin: Coin , from: PrivateKey) -> PrivateKey {
//        let bip44Purpose:UInt32 = 44
//        let purpose = from.derived(at: .hardened(bip44Purpose))
//        let coinType = purpose.derived(at: .hardened(coin.coinType))
//        let account = coinType.derived(at: .hardened(0))
//        let receive = account.derived(at: .notHardened(0))
//        return receive
//    }

//     func testPublickKeyHashOutFromPubKeyHash() {
//        let expected = "76a9210392030131e97b2a396691a7c1d91f6b5541649b75bda14d056797ab3cadcaf2f588ac"
//        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
//        let mnemonic = Mnemonic.create(entropy: entropy)
//        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
//        let privateKey = PrivateKey(seed: seed, coin: .bitcoin)
//        let publicKey = privateKey.publicKey.data
//        let hash = Script.buildPublicKeyHashOut(pubKeyHash: publicKey)
//        XCTAssertEqual(hash.toHexString(), expected)
//    }
}
