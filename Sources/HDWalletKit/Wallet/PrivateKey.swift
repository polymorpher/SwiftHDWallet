//
//  PrivateKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

enum PrivateKeyType {
    case hd
    case nonHd
}

@available(macOS 12.0.0, *)
public struct PrivateKey {
    public let raw: Data
    public let chainCode: Data
    public let index: UInt32
    public let coin: Coin
    private var keyType: PrivateKeyType
    
    public init(seed: Data, coin: Coin) async {
        let output = Crypto.HMACSHA512(key: "Bitcoin seed".data(using: .ascii)!, data: seed)
        self.raw = output[0..<32]
        self.chainCode = output[32..<64]
        self.index = 0
        self.coin = coin
        self.keyType = .hd
        self.publicKey = await PublicKey(privateKey: raw, coin: coin)
    }
    
    public init?(pk: String, coin: Coin) async {
        switch coin {
        case .ethereum, .harmony:
            self.raw = Data(hex: pk)
        default:
            let utxoPkType = UtxoPrivateKeyType.pkType(for: pk, coin: coin)
            switch utxoPkType {
            case .some(let pkType):
                switch pkType {
                case .hex:
                    self.raw = Data(hex: pk)
                case .wifUncompressed:
                    let decodedPk = Base58.decode(pk) ?? Data()
                    let wifData = decodedPk.dropLast(4).dropFirst()
                    self.raw = wifData
                case .wifCompressed:
                    let decodedPk = Base58.decode(pk) ?? Data()
                    let wifData = decodedPk.dropLast(4).dropFirst().dropLast()
                    self.raw = wifData
                }
            case .none:
                return nil
            }

        }
        self.chainCode = Data(capacity: 32)
        self.index = 0
        self.coin = coin
        self.keyType = .nonHd
        self.publicKey = await  PublicKey(privateKey: raw, coin: coin)
    }
    
    private init(privateKey: Data, chainCode: Data, index: UInt32, coin: Coin) async {
        self.raw = privateKey
        self.chainCode = chainCode
        self.index = index
        self.coin = coin
        self.keyType = .hd
        self.publicKey = await  PublicKey(privateKey: raw, coin: coin)
    }
    
    public let publicKey: PublicKey
    
    public func wifCompressed() -> String {
        var data = Data()
        data += coin.wifAddressPrefix
        data += raw
        data += UInt8(0x01)
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func wifUncompressed() -> String {
        var data = Data()
        data += coin.wifAddressPrefix
        data += raw
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func get() -> String {
        switch self.coin {
        case .bitcoin: fallthrough
        case .litecoin: fallthrough
        case .dash: fallthrough
        case .bitcoinCash:
            return self.wifCompressed()
        case .dogecoin:
            return self.wifUncompressed()
        case .ethereum, .harmony:
            return self.raw.toHexString()
        }
    }
    
    public func derived(at node:DerivationNode) async -> PrivateKey {
        guard keyType == .hd else { fatalError() }
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }
        
        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            data += Crypto.generatePublicKey(data: raw, compressed: true)
        }
        
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex
        
        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])
        
        let curveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
        let derivedPrivateKey = ((BInt(data: raw) + factor) % curveOrder).data
        let derivedChainCode = digest[32..<64]
        return await PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            index: derivingIndex,
            coin: coin
        )
    }
    
    public func sign(hash: Data) async throws -> Data {
        return try Crypto.sign(hash, privateKey: raw)
    }
}


@available(macOS 12.0.0, *)
public extension PrivateKey {
    
    // TODO: group task
    func privateKey(at derivationPath: String ) async throws -> PrivateKey {
        
        // key must be the master node (derived from the master seed)
        guard index == 0 else { throw PrivateKeyError.notMasterNode }
        
        // Sanitize the path and remove the leading m if present
        var nodes = derivationPath.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "/")
        if let m = nodes.first, m == "m" { nodes.removeFirst() }
        
        var key = self
        for var node in nodes {
                
            let isHardened = (node.last! == "'")
            if isHardened { node = node.dropLast() }
            guard let value = UInt32(node) else { throw PrivateKeyError.notAValidDerivationPath }
            
            if isHardened {
                key = await key.derived(at: .hardened(value))
            } else {
                key = await key.derived(at: .notHardened(value))
            }
        }
        
        return key
    }
}

public enum PrivateKeyError: Error {
    case notMasterNode
    case notAValidDerivationPath
}

@available(macOS 12.0.0, *)
extension PrivateKey: Equatable {
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.raw == rhs.raw && lhs.index == rhs.index && lhs.coin == rhs.coin
    }
}
