import coremltools as coreml
from transformers import XLMRobertaForTokenClassification
import torch

model = XLMRobertaForTokenClassification.from_pretrained(
    "./research_ner/model",
    torchscript=True
)

model.eval()
example_input = torch.randint(100, (1, 128))

traced = torch.jit.trace(model, example_input)

mlmodel = coreml.convert(
    traced,
    inputs=[coreml.TensorType(name="input_ids", shape=example_input.shape)],
)

mlmodel.save("./research_ner/model/ResearchNERModel.mlpackage")
