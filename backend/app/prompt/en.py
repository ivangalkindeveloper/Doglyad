from __future__ import annotations

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_data import USExaminationData
from app.prompt.base import PromptFactory


class PromptFactoryEn(PromptFactory):

    stub = """## Ultrasound Examination Report

**Methodology.** The examination was performed using an expert-class ultrasound system equipped with a multifrequency convex transducer (3.5–7.5 MHz) and a linear transducer (7.5–12 MHz). Scanning was carried out in standard longitudinal, transverse, and oblique planes utilizing grayscale **B-mode**, color Doppler flow mapping (**CDFM**), and pulsed-wave Doppler.

### Findings

- Organs: contours are smooth and well-defined; the capsule is clearly delineated throughout.
- Parenchymal echogenicity is within normal limits, comparable to that of surrounding tissues; the echostructure is homogeneous and finely granular, with no focal abnormalities.
- *Visualization:* structures are located in their typical anatomical positions, with preserved topographic relationships.
- **Doppler:** symmetric blood flow, normal vascular pattern, no hemodynamically significant disturbances; peak systolic velocities and resistive indices within reference ranges.
- The ductal system shows no dilation; no calculi are detected.
- The perivisceral fat shows no infiltrative changes.
- Regional lymph nodes are not enlarged, with an oval morphology and preserved corticomedullary differentiation.

### Conclusion

The ultrasound examination **revealed no** signs of focal or diffuse pathology in the examined region; the sonographic findings are consistent with age-appropriate normal anatomy. No pathological free gas or fluid is identified within the scanning field.

**Recommendations**

1. _Clinical and laboratory correlation_ of the obtained results.
2. If clinically indicated — a follow-up ultrasound in **6–12 months**.
""".strip()

    def system_prompt(
        self,
        settings: NeuralModelSettings
    ) -> str:
        prompt =  (
            "You are an AI assistant specialized in generating medical ultrasound examination reports.\n"
            "Your task is to produce clinical conclusions that physicians rely on for diagnosis and treatment planning.\n"
            "Write only the medical conclusion based strictly on the provided examination data and images.\n"
            "Do not infer, assume, or fabricate any findings that are not supported by the input.\n"
            "Use precise medical terminology appropriate for a formal radiology report.\n"
            "If the provided data is insufficient to assess a specific structure, state that it was not adequately visualized rather than speculating.\n"
        )

        if not settings.isMarkdown:
            prompt += f"Provide your answer in plain text and without Markdown.\n"

        return prompt

    def build_prompt(
        self,
        settings: NeuralModelSettings,
        examination: USExaminationData,
        examination_title: str,
        template: str | None = None,
    ) -> str:
        prompt = (
            f"Ultrasound examination type: {examination_title}\n"
            f"Patient name: {examination.patientName}\n"
            f"Patient gender: {examination.patientGender}\n"
            f"Patient date of birth: {examination.patientDateOfBirth.date().isoformat()}\n"
            f"Patient height: {examination.patientHeight}\n"
            f"Patient weight: {examination.patientWeight}\n"
            f"Ultrasound examination description: {examination.examinationDescription}\n"
        )

        if examination.patientComplaint:
            prompt += f"Patient complaint: {examination.patientComplaint}\n"
        if examination.additionalData:
            prompt += f"Additional data: {examination.additionalData}\n"

        if template:
            prompt += f"Response template: {template}\n"

        if not settings.isMarkdown:
            prompt += f"Provide your answer in plain text and without Markdown.\n"

        return prompt
