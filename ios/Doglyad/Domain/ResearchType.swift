import Foundation

enum ResearchType: String, CaseIterable, Codable {
    case abdominalCavity // Брюшная полость
    case abdominalVessels // Сосуды брюшной полости
    case arteriesOfTheLowerExtremities // Артерии нижних конечностей
    case arteriesOfTheUpperExtremities // Артерии верхних конечностей
    case bladder // Мочевой пузырь
    case bladderWithResidualUrineDetermination // Мочевой пузырь с определением остаточной мочи
    case brachiocephalicVessels // Брахиоцефальные сосуды
    case echocardiography // Эхокардиография
    case eye // Глаз
    case hipJointsInNewborns // Тазобедренные суставы у новорожденных
    case hollowOrgansStomachAndIntestines // Полые органы (желудок и кишечник)
    case intracanialArteries // Интраканиальные артерии
    case joints // Суставы
    case kidneysAdrenalGlandsAndRetroperitonealSpace // Почки, надпочечники и забрюшинное пространство
    case lymphNodes // Лимфатические узлы
    case mammaryGlands // Молочные железы
    case neurosonography // Нейросонография
    case pelvicOrgans // Органы малого таза
    case pleuralRegion // Плевральная область
    case renalArteries // Почечные артерии
    case salivaryGlands // Слюнные железы
    case scrotum // Мошонка
    case sinuses // Пазухи
    case softTissues // Мягкие ткани
    case thymusGland // Вилочковая железа
    case thyroidGland // Щитовидная железа
    case veinsOfTheLowerExtremities // Вены нижних конечностей
    case veinsOfTheUpperExtremities // Вены верхних конечностей
    
    static let `default`: ResearchType = .thyroidGland
    
    static func fromString(
        _ value: String?
    ) -> ResearchType? {
        for type in ResearchType.allCases {
            if type.rawValue == value {
                return type
            }
        }
        return nil
    }
}

extension ResearchType: Identifiable {
    var id: Self { self }
}
