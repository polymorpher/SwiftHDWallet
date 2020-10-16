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
    
    /// Address in string format, e.g. one1kx8f98avylkglwlns8rv5jp4yk09pwrnyhk98z
    public let string: String
    
    public init(data: Data, string: String) {
        self.data = data
        self.string = string
    }
    
//    public init(data: Data) {
//        self.data = data
//        self.string = "one" + EIP55.encode(data)
//    }
    
    public init(string: String) {
        self.data = Data(hex: string.stripHexPrefix())
        self.string = string
    }
    
    
    
    // TODO: convert HarmonyAddress to a subclass of a new Bech32Address class
    /*
     bool Bech32Address::isValid(const std::string& addr, const std::string& hrp) {
         auto dec = Bech32::decode(addr);
         // check hrp prefix (if given)
         if (hrp.length() > 0 && dec.first.compare(0, hrp.length(), hrp) != 0) {
             return false;
         }
         if (dec.second.empty()) {
             return false;
         }

         Data conv;
         auto success = Bech32::convertBits<5, 8, false>(conv, dec.second);
         if (!success || conv.size() < 2 || conv.size() > 40) {
             return false;
         }

         return true;
     }
     */
}
