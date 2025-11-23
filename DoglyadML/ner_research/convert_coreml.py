import coremltools as coreml
from transformers import XLMRobertaForTokenClassification
import torch

model = XLMRobertaForTokenClassification.from_pretrained(
    "./DoglyadML/ner_research/model",
    torchscript=True
)
model.eval()
example_input = torch.randint(100, (1, 128))
traced = torch.jit.trace(model, example_input)

mlpackage = coreml.convert(
    traced,
    inputs=[coreml.TensorType(name="input_ids", shape=example_input.shape)],
)
mlpackage.save("./DoglyadML/ner_research/model/ResearchNERModel.mlpackage")
