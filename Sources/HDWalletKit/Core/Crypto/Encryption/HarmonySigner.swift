//
//  HarmonySigner.swift
//  
//
//  Created by Ronald Mannak on 10/10/20.
//

import Foundation

import CryptoSwift

public struct HarmonySigner {
    
    public private (set) var signatureData: SignatureData?
    
    public init(chainId: Int) {
        self.chainId = chainId
    }
    
    private let chainId: Int
    
    public mutating func sign(_ rawTransaction: HarmonyRawTransaction, privateKey: PrivateKey) throws -> Data {
        guard privateKey.coin == .harmony else { throw HDWalletKitError.privateKeyError }
        return try sign(rawTransaction, privateKey: privateKey.raw)
    }
    
    public mutating func sign(_ rawTransaction: HarmonyRawTransaction, privateKey: Data) throws -> Data {        
        let transactionHash = try hash(rawTransaction: rawTransaction)
        let signature = try Crypto.sign(transactionHash, privateKey: privateKey)
        return try signTransaction(signature: signature, rawTransaction: rawTransaction)
    }
    
    private mutating func signTransaction(signature: Data, rawTransaction: HarmonyRawTransaction) throws -> Data {
        signatureData = calculateRSV(signature: signature)
        return try RLP.encode([
            rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.shardID,
            rawTransaction.toShardID,
            rawTransaction.to.data, // should be "" in case to is nil
            rawTransaction.value,
            rawTransaction.payload,
            signatureData!.v,
            signatureData!.r,
            signatureData!.s
        ])
    }
    
    public func hash(rawTransaction: HarmonyRawTransaction) throws -> Data {
        return Crypto.sha3keccak256(data: try encode(rawTransaction: rawTransaction))
    }
    
    public func encode(rawTransaction: HarmonyRawTransaction) throws -> Data {
        var toEncode: [Any] = [
            rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.shardID,
            rawTransaction.toShardID,
            rawTransaction.to.data,
            rawTransaction.value,
            rawTransaction.payload]
        if chainId != 0 {
            toEncode.append(contentsOf: [chainId, 0, 0 ]) // EIP155
        }
        return try RLP.encode(toEncode)
    }
    
    public func calculateRSV(signature: Data) -> SignatureData {
        let signatureData = SignatureData(
//            v: BInt(signature[64]) + 35 + 2 * chainId, //in trustwalletcore
            v: BInt(signature[64]) + chainId == 0 ? 27 : 35 + 2 * chainId, // in Harmony Java
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!)
        return signatureData
    }
    
    public func calculateSignature(_ signatureData: SignatureData) -> Data {
        let suffix = signatureData.v - (chainId == 0 ? 27 : 35 - (2 * chainId))
        let sigHexStr = hex64Str(signatureData.r) + hex64Str(signatureData.s) + suffix.asString(withBase: 16)
        return Data(hex: sigHexStr)
    }
//    public func calculateSignature(r: BInt, s: BInt, v: BInt) -> Data {
//        let isOldSignitureScheme = [27, 28].contains(v)
//        let suffix = isOldSignitureScheme ? v - 27 : v - 35 - 2 * chainId
//        let sigHexStr = hex64Str(r) + hex64Str(s) + suffix.asString(withBase: 16)
//        return Data(hex: sigHexStr)
//    }
    
    private func hex64Str(_ i: BInt) -> String {
        let hex = i.asString(withBase: 16)
        return String(repeating: "0", count: 64 - hex.count) + hex
    }
}
