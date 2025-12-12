import coremltools as ct
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import numpy as np
from pathlib import Path

MODEL_NAME = "apple/OpenELM-1_1B-Instruct"
TOKENIZER_NAME = "NousResearch/Llama-2-7b-hf"
SEQUENCE_LENGTH = 256
OUTPUT_DIR = Path(__file__).parent / "model"
OUTPUT_PATH = OUTPUT_DIR / "DoglyadOpenELM.mlpackage"

torch_model = AutoModelForCausalLM.from_pretrained(
    MODEL_NAME,
    dtype=torch.float32,
    trust_remote_code=True,
    return_dict=False,
    use_cache=True,
)
torch_model.eval()
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_NAME)

example_input_ids = torch.zeros((1, 32), dtype=torch.int32)
sequence_length = torch.export.Dim(name="sequence_length", min=1, max=SEQUENCE_LENGTH)
dynamic_shapes = {"input_ids": {1: sequence_length}}
exported_program = torch.export.export(
    torch_model,
    (example_input_ids,),
    dynamic_shapes=dynamic_shapes,
)
exported_program = exported_program.run_decompositions({})

mlmodel = ct.convert(
    exported_program,
    source="pytorch",
    convert_to="mlprogram",
    minimum_deployment_target=ct.target.iOS18,
    compute_precision=ct.precision.FLOAT16
)
mlmodel.save(OUTPUT_PATH)