public struct DNeuralModelData {
    public let modelId: String
    public let numLayers: Int
    /// The number of KV heads, not attention heads: Qwen2.5 uses GQA,
    /// where the KV cache is several times smaller than with classic multi-head.
    public let numKeyValueHeads: Int
    public let headDimension: Int

    public init(
        modelId: String,
        numLayers: Int,
        numKeyValueHeads: Int,
        headDimension: Int
    ) {
        self.modelId = modelId
        self.numLayers = numLayers
        self.numKeyValueHeads = numKeyValueHeads
        self.headDimension = headDimension
    }
}
