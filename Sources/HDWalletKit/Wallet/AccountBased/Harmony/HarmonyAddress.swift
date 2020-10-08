//
//  HarmonyAddress.swift
//  HDWalletKit
//
//  Created by Ronald Mannak on 10/6/20.
//

import Foundation
/// Represents an address
public struct HarmonyAddress: Codable {
    
    /// Address in data format
    public let data: Data
    
    /// Address in string format, EIP55 encoded
    public let string: String
    
    public init(data: Data, string: String) {
        self.data = data
        self.string = string
    }
    
    public init(data: Data) {
        self.data = data
        self.string = "one" + EIP55.encode(data)
    }
    
    public init(string: String) {
        self.data = Data(hex: string.stripHexPrefix())
        self.string = string
    }
}
