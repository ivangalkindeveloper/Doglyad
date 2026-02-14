from pydantic import BaseModel

from app.model.neural_model_settings import NeuralModelSettings
from app.model.research_data import ResearchData


class ResearchRequest(BaseModel):
    neuralModelSettings: NeuralModelSettings
    researchData: ResearchData
