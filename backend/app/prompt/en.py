from __future__ import annotations

from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_data import USExaminationData
from app.prompt.base import PromptFactory


class PromptFactoryEn(PromptFactory):

    def build_stub(self) -> str:
        return (
            "STUB: Ultrasound Examination Report\n"
            "The examination was performed using an expert-class ultrasound system "
            "equipped with a multifrequency convex transducer (3.5–7.5 MHz) "
            "and a linear transducer (7.5–12 MHz). "
            "Scanning was carried out in standard longitudinal, transverse, and oblique planes "
            "utilizing B-mode grayscale imaging, color Doppler flow mapping (CDFM), "
            "and pulsed-wave Doppler.\n\n"
            "Findings: the visualized structures are located in their typical anatomical positions "
            "with preserved topographic relationships. "
            "Organ contours are smooth and well-defined; the capsule is clearly delineated throughout. "
            "Parenchymal echogenicity is within normal limits and comparable to that of surrounding tissues. "
            "The echostructure is homogeneous and finely granular with no focal abnormalities identified. "
            "Color Doppler flow mapping demonstrates a normal vascular pattern "
            "with symmetric blood flow and no hemodynamically significant disturbances. "
            "Peak systolic velocities and resistive indices are within reference ranges. "
            "The ductal system shows no signs of dilation; no calculi are detected. "
            "The perivisceral fat appears unremarkable with no infiltrative changes. "
            "Regional lymph nodes are not enlarged, displaying a normal oval morphology "
            "with preserved corticomedullary differentiation.\n\n"
            "Conclusion: the ultrasound examination reveals no evidence of focal "
            "or diffuse pathology in the examined region. "
            "The sonographic findings are consistent with age-appropriate normal anatomy. "
            "No pathological free gas or fluid is identified within the scanning field. "
            "Clinical and laboratory correlation of the obtained results is recommended. "
            "If clinically indicated, a follow-up ultrasound examination "
            "in 6 to 12 months is advisable."
        )

    def build_system_prompt(self) -> str:
        return (
            "You are an AI assistant specialized in generating medical ultrasound examination reports. "
            "Generate without markdown formatting. "
            "Your task is to produce clinical conclusions that physicians rely on for diagnosis and treatment planning. "
            "Write only the medical conclusion based strictly on the provided examination data and images. "
            "Do not infer, assume, or fabricate any findings that are not supported by the input. "
            "Use precise medical terminology appropriate for a formal radiology report. "
            "If the provided data is insufficient to assess a specific structure, "
            "state that it was not adequately visualized rather than speculating. "
            "Structure the report with findings followed by a conclusion. "
        )

    def build_prompt(
        self,
        settings: NeuralModelSettings,
        examination: USExaminationData,
        examination_title: str,
        template: str | None = None,
    ) -> str:
        base = (
            f"Generate a full medical ultrasound conclusion for data:\n"
            f"Ultrasound examination type: {examination_title}\n"
            f"Patient name: {examination.patientName}\n"
            f"Patient gender: {examination.patientGender}\n"
            f"Patient date of birth: {examination.patientDateOfBirth.date().isoformat()}\n"
            f"Patient height: {examination.patientHeight}\n"
            f"Patient weight: {examination.patientWeight}\n"
            f"Ultrasound examination description: {examination.examinationDescription}\n"
        )

        if examination.patientComplaint:
            base += f"Patient complaint: {examination.patientComplaint}\n"
        if examination.additionalData:
            base += f"Additional data: {examination.additionalData}\n"

        if template:
            base += f"Response template: {template}\n"
        if settings.responseLength:
            base += f"Maximum response length (tokens): {settings.responseLength}\n"

        return base
