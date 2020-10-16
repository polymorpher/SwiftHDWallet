//
//  AttoOne.swift
//  
//
//  Created by Ronald Mannak on 10/15/20.
//

import Foundation

public struct AttoOneConverter {
    
    // NOTE: calculate Atto by 10^18
    private static let oneInAtto = pow(Decimal(10), 18)
    
    /// Convert Atto(BInt) unit to One(Decimal) unit
    public static func toOne(atto: Atto) throws -> One {
        guard let decimalAtto = Decimal(string: atto.description) else {
            throw HDWalletKitError.convertError(.failedToConvert(atto.description))
        }
        return decimalAtto / oneInAtto
    }
    
    /// Convert One(Decimal) unit to Atto(BInt) unit
    public static func toAtto(one: One) throws -> Atto {
        guard let atto = Atto((one * oneInAtto).description) else {
            throw HDWalletKitError.convertError(.failedToConvert(one * oneInAtto))
        }
        return atto
    }
    
    /// Convert One(String) unit to Atto(BInt) unit
    public static func toAtto(one: String) throws -> Atto {
        guard let decimalOne = Decimal(string: one) else {
            throw HDWalletKitError.convertError(.failedToConvert(one))
        }
        return try toAtto(one: decimalOne)
    }
    
    ///Convert Atto to Tokens balance
    public static func toToken(balance: String, decimals: Int, radix: Int) throws -> One {
        guard let atto = Atto(balance, radix: radix),
              let  decimalAtto = Decimal(string: atto.description) else {
            throw HDWalletKitError.convertError(.failedToConvert(balance))
        }
        return decimalAtto / pow(10, decimals)
    }
    
    // Only used for calcurating gas price and gas limit.
    public static func toAtto(GAtto: Int) -> Atto {
        return Atto(GAtto) * Atto(1000000000)
    }
}
