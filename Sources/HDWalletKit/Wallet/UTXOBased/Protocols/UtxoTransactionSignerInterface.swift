//
//  UtxoTransactionSigner.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 2/19/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import Foundation

@available(macOS 12.0.0, *)
public protocol UtxoTransactionSignerInterface {
    func sign(_ unsignedTransaction: UnsignedTransaction, with key: PrivateKey) throws -> Transaction
}
