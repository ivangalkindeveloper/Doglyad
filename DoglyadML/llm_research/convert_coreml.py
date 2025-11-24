import coremltools as coreml
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import numpy as np

MODEL_NAME = "google/gemma-7b"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME)
model.eval()

class WrappedModel(torch.nn.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model
    
    def forward(self, input_ids):
        outputs = self.model(input_ids)
        return outputs.logits

wrapped_model = WrappedModel(model)
example_input = torch.randint(0, tokenizer.vocab_size, (1, 32), dtype=torch.int32)
traced = torch.jit.trace(wrapped_model, example_input)
mlpackage = coreml.convert(
    traced,
    source="pytorch",
    inputs=[coreml.TensorType(shape=example_input.shape, dtype=np.int32)],
    convert_to="mlprogram", 
    minimum_deployment_target=coreml.target.iOS18
)
mlpackage.save("./DoglyadML/llm_research/model/DoglyadResearchLLMModel.mlpackage")
