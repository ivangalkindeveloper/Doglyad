import coremltools as coreml
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

MODEL_NAME = "meta-llama/Llama-3.1-8B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME)
model.eval()

example_input = torch.randint(0, tokenizer.vocab_size, (1, 32))
mlmodel = coreml.convert(
    model,
    inputs=[coreml.TensorType(shape=example_input.shape, dtype=example_input.dtype)],
    convert_to="mlprogram",
    minimum_deployment_target=coreml.target.iOS17
)
mlmodel.save("DoglyadResearchLLMModel.mlmodel")
