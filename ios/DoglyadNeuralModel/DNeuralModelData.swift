public struct DNeuralModelData {
    public let modelId: String
    public let numLayers: Int
    /// Число KV-голов, а не голов внимания: Qwen2.5 использует GQA,
    /// где KV-кэш кратно меньше, чем при классическом multi-head.
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
