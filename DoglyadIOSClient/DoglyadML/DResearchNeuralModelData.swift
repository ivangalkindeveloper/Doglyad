import Foundation

final class DResearchNeuralModelData {
    static let tokenizerName = "NousResearch/Llama-2-7b-hf"
    static let sequenceLength = 256
    static func fullPrompt(
        locale: Locale,
        text: String
    ) -> String {
        """
        You are a model parsing a medical study text obtained by a doctor's dictation.
        This text must be parsed into the following entities: patient name, patient gender, patient date of birth, patient height, patient weight, patient complaint, research description, and additional information about the medical research performed.
        Ignore noise, filler words, dictation errors, and incomplete or repeated phrases in the parsed text. No guesswork; if there is no data, enter null.
        Each parsed section of entities must be edited for syntax and spelling errors, as the text is simply dictated by voice.
        The response must be returned in the JSON format described below, nothing else is required.

        JSON format:
        {
            "patientName": "Patient name",
            "patientGender": "male / female",
            "patientDateOfBirth": "1994-03-28 12:00:00+0000",
            "patientHeight": 180.0,
            "patientWeight": 80.0,
            "patientComplaint": "Patient complaint",
            "researchDescription": "Research description",
            "additionalData": "Additional data"
        }
        
        Locale of text: \(locale.identifier)

        Text:
        \(text)
        """
    }
}
