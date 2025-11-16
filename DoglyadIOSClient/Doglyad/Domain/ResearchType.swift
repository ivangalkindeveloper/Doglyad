import Foundation

enum ResearchType: String, CaseIterable {
    case thyroidGland // Щитовидная железа
    case abdominalCavity // Брюшная полость
    case kidneysAdrenalGlandsAndRetroperitonealSpace // Почки, надпочечники и забрюшинное пространство
    case bladder // Мочевой пузырь
    case pelvicOrgans // Органы малого таза
    case scrotum // Мошонка
    case lymphNodes // Лимфатические узлы
    case salivaryGlands // Слюнные железы
    case softTissues // Мягкие ткани
    case neurosonography // Нейросонография
    case hipJointsInNewborns // Тазобедренные суставы у новорожденных
    case joints // Суставы
    case hollowOrgansStomachAndIntestines // Полые органы (желудок и кишечник)
    case eye // Глаз
    case echocardiography // Эхокардиография
    case veinsOfTheLowerExtremities // Вены нижних конечностей
    case veinsOfTheUpperExtremities // Вены верхних конечностей
    case arteriesOfTheLowerExtremities // Артерии нижних конечностей
    case arteriesOfTheUpperExtremities // Артерии верхних конечностей
    case brachiocephalicVessels // Брахиоцефальные сосуды
    case intracanialArteries // Интраканиальные артерии
    case pleuralRegion // Плевральная область
    case thymusGland // Вилочковая железа
    case mammaryGlands // Молочные железы
    case abdominalVessels // Сосуды брюшной полости
    case renalArteries // Почечные артерии
    case sinuses // Пазухи
    case bladderWithResidualUrineDetermination // Мочевой пузырь с определением остаточной мочи
    
    static let `default`: ResearchType = .thyroidGland
    
    static func fromString(_ value: String?) -> ResearchType? {
        switch value {
        case ResearchType.thyroidGland.rawValue:
                .thyroidGland
        default:
            nil
        }
    }
}

extension ResearchType: Identifiable {
    var id: Self { self }
}
