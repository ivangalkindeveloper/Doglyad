import Foundation

struct DResearchGenerationConfig {
    static let mlxModelId: String = "mlx-community/Qwen3-0.6B-4bit"
    
    static let modelRole: String =
        """
        You are a model parsing a medical study text obtained by a doctor's dictation.
        This text must be parsed into the following entities: patient name, patient gender, patient date of birth, patient height, patient weight, patient complaint, research description, and additional information about the medical research performed.
        Ignore noise, filler words, dictation errors, and incomplete or repeated phrases in the parsed text. No guesswork; if there is no data, enter null.
        Each parsed section of entities must be edited for syntax and spelling errors, as the text is simply dictated by voice.
        The response must be returned in the JSON format described below, nothing else is required.
        """
    
    static let jsonFormat: String =
        """
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
        """
    
    static func taskPrompt(
        _ locale: Locale,
        _ text: String
    ) -> String {
        """
        Locale of text: \(locale.identifier)
        Text:
        \(text)
        """
    }
    
    static let testText = "Пациент Иван мужчина родился 28 марта 1994г. рост 180 см 80 кг жалобы периодически боли животе дискомфорт при глотании боли в левом потребили и чья жесть в правом потреби исследования проведено ультразвуковой исследование органов брюшной полости а также ультразвуковой исследования почек дополнительную информацию о технических фотофактов не выявлено использован линейный да частотой 7,5 мегагерц сохранено 12 снимков исследования"
    
    let sequenceLength = 1024
    let maxNewTokens: Int = 512
    let temperature: Float = 0.2
    let topP: Float = 0.9
}
