import Foundation

struct DResearchGenerationConfig {
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
            "additionalData": "Some additional data"
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
    
//    static let testText = "Пациент Иван мужчина родился 28 марта 1994г. рост 180 см 80 кг жалобы периодически боли животе дискомфорт при глотании боли в левом потребили и чья жесть в правом потреби исследования проведено ультразвуковой исследование органов брюшной полости а также ультразвуковой исследования почек дополнительную информацию о технических фотофактов не выявлено использован линейный да частотой 7,5 мегагерц сохранено 12 снимков исследования"
    static let testText = "patient Ivan male born March 28 1994 height 180 cm 80 kg complaints periodic abdominal pain discomfort when swallowing pain in the left abdomen and a tingling sensation in the right abdomen an ultrasound examination of the abdominal organs and an ultrasound examination of the kidneys were performed no additional information about technical photographic evidence was found a linear array with a frequency of 7.5 megahertz was used 12 images of the study were saved"
}
