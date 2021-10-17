//
//  Wallet.swift
//  WalletKit
//
//  Created by yuzushioh on 2018/01/01.
//  Copyright © 2018 yuzushioh. All rights reserved.
//
import Foundation

@available(macOS 12.0.0, *)
public final class Wallet {
    
    public let privateKey: PrivateKey
    public let coin: Coin
    
    public init(seed: Data, coin: Coin) async {
        self.coin = coin
        let privateKey = await PrivateKey(seed: seed, coin: coin)
        self.privateKey = privateKey
        bip44PrivateKey = await {
            let bip44Purpose:UInt32 = 44
            let purpose = await privateKey.derived(at: .hardened(bip44Purpose))
            let coinType = await purpose.derived(at: .hardened(coin.coinType))
            let account = await coinType.derived(at: .hardened(0))
            let receive = await account.derived(at: .notHardened(0))
            return receive
        }()
    }
    
    //MARK: - Public
    public func generateAddress(at index: UInt32) async -> String {
        let derivedKey = await bip44PrivateKey.derived(at: .notHardened(index))
        return derivedKey.publicKey.address
    }
    
    public func generateAddresses(count: Int = 5) async -> [String] {
        var addresses: [String] = []
        for i in 0 ..< count {
            await addresses.append(generateAddress(at: UInt32(i)))
        }
        return addresses
    }
    
    public func generateAccount(at derivationPath: [DerivationNode]) async -> Account {
        let privateKey = await generatePrivateKey(at: derivationPath)
        return Account(privateKey: privateKey)
    }
    
    public func generateAccount(at index: UInt32 = 0) async -> Account {
        let address = await bip44PrivateKey.derived(at: .notHardened(index))
        return Account(privateKey: address)
    }
    
    public func generateAccounts(count: UInt32) async -> [Account]  {
        var accounts:[Account] = []
        for index in 0..<count { // TODO: Update to task groups
            await accounts.append(generateAccount(at: index))
        }
        return accounts
    }
    
    /*
     https://www.biteinteractive.com/swift-5-5-asynchronous-looping-with-async-await/
     
     let countries = await Server.shared.getCountries()
     print(countries)
     var capitals = [(country:String, capital:String)]()
     await withTaskGroup(of: (String,String).self) { group in
         for country in countries {
             group.addTask {
                 let capital = await Server.shared.getCapital(of:country)
                 return (country,capital)
             }
         }
         for await pair in group {
             capitals.append(pair)
         }
     }
     print(capitals)
     
     */
    
    
    public func sign(rawTransaction: EthereumRawTransaction) async throws -> String {
        let signer = EIP155Signer(chainId: 1)
        let rawData = try await signer.sign(rawTransaction, privateKey: privateKey)
        let hash = rawData.toHexString().addHexPrefix()
        return hash
    }
    
    //MARK: - Private
    //https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    let bip44PrivateKey:PrivateKey
    
    private func generatePrivateKey(at nodes:[DerivationNode]) async -> PrivateKey {
        return await privateKey(at: nodes)
    }
    
    private func privateKey(at nodes: [DerivationNode]) async -> PrivateKey {
        var key: PrivateKey = privateKey
        for node in nodes {
            key = await key.derived(at:node)
        }
        return key
    }
}

@available(macOS 12.0.0, *)
extension Wallet: Equatable {
    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.privateKey == rhs.privateKey && lhs.coin == rhs.coin
    }
}
