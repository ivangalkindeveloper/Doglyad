import coremltools as coreml
from transformers import XLMRobertaForTokenClassification, AutoTokenizer
import torch
import numpy as np

MODEL_PATH = "./DoglyadML/ner_research/model"
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = XLMRobertaForTokenClassification.from_pretrained(
    MODEL_PATH,
    torchscript=True
)
model.eval()

example_input = torch.randint(0, tokenizer.vocab_size, (1, 128), dtype=torch.int32)
traced = torch.jit.trace(model, example_input)
mlpackage = coreml.convert(
    traced,
    source="pytorch",
    inputs=[coreml.TensorType(name="input_ids", shape=example_input.shape, dtype=np.int32)],
    convert_to="mlprogram", 
    minimum_deployment_target=coreml.target.iOS18
)
mlpackage.save("./DoglyadML/ner_research/model/DoglyadResearchNERModel.mlpackage")
