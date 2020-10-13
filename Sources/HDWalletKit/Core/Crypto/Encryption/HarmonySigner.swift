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
        
//        let transactionHash = try hash(rawTransaction: rawTransaction)
//        let signature = try privateKey.sign(hash: transactionHash)
//        return try signTransaction(signature: signature, rawTransaction: rawTransaction)
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
    
    /*
     Based on TrustWalletCore Harmony/Signer.cpp
     
     std::tuple<uint256_t, uint256_t, uint256_t> Signer::values(const uint256_t &chainID,
                                                                const Data& signature) noexcept {
         auto r = load(Data(signature.begin(), signature.begin() + 32));
         auto s = load(Data(signature.begin() + 32, signature.begin() + 64));
         auto v = load(Data(signature.begin() + 64, signature.begin() + 65));
         v += 35 + chainID + chainID;
         return std::make_tuple(r, s, v);
     }

     std::tuple<uint256_t, uint256_t, uint256_t>
     Signer::sign(const uint256_t &chainID, const PrivateKey &privateKey, const Data& hash) noexcept {
         auto signature = privateKey.sign(hash, TWCurveSECP256k1);
         return values(chainID, signature);
     }
     
     */
    public func calculateRSV(signature: Data) -> SignatureData {
//        print((BInt(signature[64]) + 35 + 2 * chainId).asString(withBase: 16))
        let signatureData = SignatureData(
//            v: BInt(signature[64]) + 35 + 2 * chainId, //in trustwalletcore
            v: BInt(signature[64]) + chainId == 0 ? 27 : 35 + 2 * chainId, // in Harmony Java
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!)
        return signatureData
    }
    
    /*
    // Based on transaction.java
    public func calculateRSV(signature: Data) -> SignatureData {
        
//        var headerByte: Int = 0
//        if chainId == 0 {
//
//            // Now we have to work backwards to figure out the recId needed to recover the
//            // signature.
//            var recId: Int?
//            for i in 0 ..< 4 {
//                let k =
//
////                    BigInteger k = Sign.recoverFromSignature(i, sig, messageHash);
////                    if (k != null && k.equals(publicKey)) {
////                        recId = i;
////                        break;
////                    }
//            }
//            guard let recID = recId else {
//                throw HDWalletKitError.failedToSign // Could not construct a recoverable key. Are the credentials valid?
//            }
//            headerByte = recId + 27
//        } else {
//            headerByte = recId + 35 + chainId * 2;
//        }
        
        let signatureData = SignatureData(
            v: BInt(signature[64]) + BInt(signature[65]) + chainId == 0 ? 27 : 35 + 2 * chainId,
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!)
        return signatureData
    }
    
     /*
    /* from Transaction.java
     private static SignatureData signMessage(int chainId, byte[] message, ECKeyPair keyPair, boolean needToHash) {

             ECDSASignature sig = keyPair.sign(messageHash);
             // Now we have to work backwards to figure out the recId needed to recover the
             // signature.
             int recId = -1;
             for (int i = 0; i < 4; i++) {
                 BigInteger k = Sign.recoverFromSignature(i, sig, messageHash);
                 if (k != null && k.equals(publicKey)) {
                     recId = i;
                     break;
                 }
             }
             if (recId == -1) {
                 throw new RuntimeException("Could not construct a recoverable key. Are your credentials valid?");
             }

             int headerByte = recId + 27;

             if (chainId != 0) {
                 headerByte = 0;
                 headerByte += 35;
                 headerByte += chainId * 2;
                 headerByte += recId;
             }

             // 1 header + 32 bytes for R + 32 bytes for S
             byte v = (byte) headerByte;
             byte[] r = Numeric.toBytesPadded(sig.r, 32);
             byte[] s = Numeric.toBytesPadded(sig.s, 32);

             return new SignatureData(v, r, s);
         }
     */
    */
 */

    
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
