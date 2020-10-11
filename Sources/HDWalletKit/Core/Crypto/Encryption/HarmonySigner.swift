//
//  HarmonySigner.swift
//  
//
//  Created by Ronald Mannak on 10/10/20.
//

import Foundation

import CryptoSwift

public struct HarmonySigner {
    
    public init(chainId: Int) {
        self.chainId = chainId
    }
    
    private let chainId: Int
    
    public func sign(_ rawTransaction: HarmonyRawTransaction, privateKey: PrivateKey) throws -> Data {
        let transactionHash = try hash(rawTransaction: rawTransaction)
        let signature = try privateKey.sign(hash: transactionHash)
        return try signTransaction(signature: signature, rawTransaction: rawTransaction)
    }
    
    public func sign(_ rawTransaction: HarmonyRawTransaction, privateKey: Data) throws -> Data {
        let transactionHash = try hash(rawTransaction: rawTransaction)
        let signature = try Crypto.sign(transactionHash, privateKey: privateKey)
        return try signTransaction(signature: signature, rawTransaction: rawTransaction)
    }
    
    private func signTransaction(signature: Data, rawTransaction: HarmonyRawTransaction) throws -> Data {
        let (r, s, v) = calculateRSV(signature: signature)
        return try RLP.encode([
            rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.shardID,
            rawTransaction.toShardID,
            rawTransaction.to.data, // should be "" in case to is nil
            rawTransaction.value,
            rawTransaction.payload,
            v, r, s
        ])
    }
    
//    private List<RlpType> asRlpValues(SignatureData signatureData) {
//        List<RlpType> result = new ArrayList<>();
//
//        result.add(RlpString.create(this.getNonce()));
//        result.add(RlpString.create(this.getGasPrice()));
//        result.add(RlpString.create(this.getGasLimit()));
//        result.add(RlpString.create(this.getShardID()));
//        result.add(RlpString.create(this.getToShardID()));
//        if (this.getRecipient() != null) {
//            // skip contract deploy
//            result.add(RlpString.create(Numeric.hexStringToByteArray(this.getRecipient())));
//        } else {
//            result.add(RlpString.create(""));
//        }
//        result.add(RlpString.create(this.getAmount()));
//        result.add(RlpString.create(this.getPayload()));
//
//        if (signatureData != null) {
//            result.add(RlpString.create(signatureData.getV()));
//            result.add(RlpString.create(Bytes.trimLeadingZeroes(signatureData.getR())));
//            result.add(RlpString.create(Bytes.trimLeadingZeroes(signatureData.getS())));
//        }
//
//        return result;
//    }
    
    
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
    
    public func calculateRSV(signature: Data) -> (r: BInt, s: BInt, v: BInt) {
        return (
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!,
            v: BInt(signature[64]) + (chainId == 0 ? 27 : (35 + 2 * chainId))
        )
    }
    
    public func calculateSignature(r: BInt, s: BInt, v: BInt) -> Data {
        let isOldSignitureScheme = [27, 28].contains(v)
        let suffix = isOldSignitureScheme ? v - 27 : v - 35 - 2 * chainId
        let sigHexStr = hex64Str(r) + hex64Str(s) + suffix.asString(withBase: 16)
        return Data(hex: sigHexStr)
    }
    
    private func hex64Str(_ i: BInt) -> String {
        let hex = i.asString(withBase: 16)
        return String(repeating: "0", count: 64 - hex.count) + hex
    }
}
