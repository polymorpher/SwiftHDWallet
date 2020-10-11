import Foundation
/// RawTransaction constructs necessary information to publish transaction.
public struct HarmonyRawTransaction {
    
    /// Amount value to send, amount is smallest unit
    public let value: BInt
    
    /// Address to send ether to
    public let to: HarmonyAddress
    
    /// Gas price for this transaction, unit is in Wei
    /// you need to convert it if it is specified in GWei
    /// use Converter.toWei method to convert GWei value to Wei
    public let gasPrice: Int
    
    /// Gas limit for this transaction
    /// Total amount of gas will be (gas price * gas limit)
    public let gasLimit: Int // TODO: convert to BigInt
    
    // From shard (default is 0)
    public let shardID: Int
    
    // To which the Shard (default is 0)
    public let toShardID: Int
    
    /// Nonce of your address
    public let nonce: Int
    
    /// Data to attach to this transaction
    public let payload: Data

    public init(value: BInt, to: String, gasPrice: Int, gasLimit: Int, fromShard: Int = 0, toShard: Int = 0, nonce: Int, payload: Data = Data()) {
        self.value = value
        self.to = HarmonyAddress(string:to)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.shardID = fromShard
        self.toShardID = toShard
        self.nonce = nonce
        self.payload = payload
    }
}
//
//public Transaction(String from, long nonce, String recipient, int shardID, int toShardID, BigInteger amount,
//        long gasLimit, BigInteger gasPrice, byte[] payload) {
//    this.from = from;
//    this.nonce = BigInteger.valueOf(nonce);
//    this.recipient = recipient;
//    this.shardID = shardID;
//    this.toShardID = toShardID;
//    this.amount = amount;
//    this.gasLimit = BigInteger.valueOf(gasLimit);
//    this.gasPrice = gasPrice;
//    this.payload = payload;
//}
