import coremltools as ct
from transformers import AutoModelForCausalLM
import torch
import numpy as np
from pathlib import Path

MODEL_NAME = "OpenELM-270M-Instruct"
MODEL_ID = f"apple/{MODEL_NAME}"
SEQUENCE_LENGTH = 2048
OUTPUT_PATH = (
    Path(__file__)
    .parent
    .joinpath("..", "..", "..", "DoglyadIOSClient", "DoglyadML", f"{MODEL_NAME}.mlpackage")
    .resolve()
)

class OpenELMWrapper(torch.nn.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model

    def forward(self, inputIds: torch.Tensor, causalMask: torch.Tensor):
        outputs = self.model(
            input_ids=inputIds,
            attention_mask=causalMask,
            use_cache=True,
            return_dict=True,
        )
        return outputs.logits

max_context_size = SEQUENCE_LENGTH
torch_model = AutoModelForCausalLM.from_pretrained(
    MODEL_ID,
    dtype=torch.float16,
    trust_remote_code=True,
)
torch_model.eval()
wrapped_model = OpenELMWrapper(torch_model)
wrapped_model.eval()

input_ids: torch.Tensor = torch.zeros((1, 2), dtype=torch.int32)
causal_mask: torch.Tensor = torch.zeros((1, 2), dtype=torch.float32)
traced_model = torch.jit.trace(wrapped_model, [input_ids, causal_mask])
del torch_model, wrapped_model

# Convert traced TorchScript to Core ML format
query_length = ct.RangeDim(lower_bound=1, upper_bound=max_context_size, default=1)
end_step_dim = ct.RangeDim(lower_bound=1, upper_bound=max_context_size, default=1)
inputs = [
    ct.TensorType(shape=(1, query_length), dtype=np.int32, name="inputIds"),
    ct.TensorType(shape=(1, end_step_dim), dtype=np.float32, name="causalMask"),
]
outputs = [
    ct.TensorType(
        dtype=np.float16,
        name="logits"
    )
]

# Convert model with FP32 precision
mlmodel = ct.convert(
    traced_model,
    source="pytorch",
    inputs=inputs,
    outputs=outputs,
    convert_to="mlprogram",
    minimum_deployment_target=ct.target.iOS18,
    compute_precision=ct.precision.FLOAT16,
)
del traced_model

architecture = mlmodel._spec.description.metadata.userDefined.get(
    "co.huggingface.exporters.architecture",
    "openelm"
)
user_defined_metadata = {
    "co.huggingface.exporters.name": MODEL_NAME,
    "co.huggingface.exporters.task": "text-generation",
    "co.huggingface.exporters.architecture": architecture,
    "co.huggingface.exporters.framework": "pytorch",
    "co.huggingface.exporters.precision": ct.precision.FLOAT16.value,
}
mlmodel._spec.description.metadata.userDefined.update(user_defined_metadata)

mlmodel.save(OUTPUT_PATH)