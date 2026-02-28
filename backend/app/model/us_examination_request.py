from pydantic import BaseModel

from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_data import USExaminationData


class USExaminationRequest(BaseModel):
    neuralModelSettings: NeuralModelSettings
    examinationData: USExaminationData
