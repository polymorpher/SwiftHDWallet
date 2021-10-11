//
//  KeystoreInterface.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 20.08.18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public enum KeystoreError: Error {
    case keyDerivationError
    case aesError
}

//protocol KeystoreInterface {
//    func getDecryptedKeyStore(passwordData: Data) throws -> Data?
//    func encodedData() throws -> Data
//    init? (data: Data, passwordData: Data) throws
//    init? (keyStore: Data) throws
//}
