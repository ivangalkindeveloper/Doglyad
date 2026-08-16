---
name: mobile-module
description: Создание нового мобильного модуля (экрана) по конвенциям проекта Doglyad. iOS — SwiftUI/MVVM-модуль (Screen/ScreenView/ViewModel/Arguments) с регистрацией в роутере; задел под Android. Используй, когда нужно добавить новый экран, bottom-sheet или экранный модуль в мобильное приложение.
---

# mobile-module — скаффолд мобильного модуля

Создаёт новый модуль приложения по принятым в проекте конвенциям и **полностью** подключает его к навигации. Цель — чтобы новый модуль был неотличим от существующих по структуре и стилю.

## Платформы

- **iOS** (есть сейчас) — раздел [iOS](#ios-swiftui-mvvm) ниже.
- **Android** (планируется) — когда появится Android-проект, добавь раздел `## Android` с аналогичной процедурой; имя и идея скилла кросс-платформенные.

При запуске определи платформу. Если в проекте только iOS — работай по iOS-разделу без лишних вопросов.

## Что нужно уточнить перед началом

1. **Имя модуля** в PascalCase без суффиксов, напр. `Profile`, `Statistics` (имена файлов/типов соберутся сами).
2. **Тип**: полноэкранный модуль (`Screen`) или `BottomSheet`. Если не очевидно из запроса — спроси.
3. **Аргументы**: какие данные/колбэки приходят в модуль (может быть пусто).
4. **Зависит ли от данных** (репозитории/менеджеры из `DependencyContainer`) — влияет на `onInit()` во ViewModel.

---

## iOS (SwiftUI / MVVM)

Каталог модулей: `ios/Doglyad/Application/Module/<Name>/`.
Регистрация навигации: `ios/Doglyad/Application/Application/Router/RouteType.swift` и `RouterBuilder.swift`.

Перед генерацией **прочитай эталонный модуль** `Module/Settings/` (полноэкранный) или `Module/Select/NeuralModel/` (sheet), чтобы повторить актуальный стиль — шаблоны ниже это лишь каркас.

### Жёсткие правила (из AGENTS.md)

- `*Screen` — SwiftUI View, только создаёт ViewModel и отдаёт его в `*ScreenView`.
- `*ScreenView` — чистая View без логики; вёрстка **только** компонентами из `DoglyadUI` (`DScreen`, `DBottomSheet`, `DListButtonCard`, `DButton`, `DText`, `DTheme`…).
- `*ViewModel` — `@MainActor`, наследует `DViewModel`, вся логика отображения здесь.
- Если ViewModel зависит от контейнера — передавай **весь** `DependencyContainer`, а не отдельные сущности.
- **ViewModel не общаются между собой напрямую** — обмен данными между модулями только через замыкания, прокинутые в `*Screen` при создании VM (`getIsActive`, `getAvailableRequestCount`, `onNeuralModelSelected` и т.п.). VM модуля не обращается к чужой VM ни напрямую, ни через `@EnvironmentObject`.
- **Показ частей интерфейса регулирует VM своего модуля**: во VM прокидываются данные/замыкания, а она объявляет вычисляемые флаги и методы (`isSpeechButtonVisible`, `isNeuralModelSettingsVisible`). `*ScreenView` ветвит вёрстку только по флагам/методам своей VM, а не по сторонним `@EnvironmentObject`.
- Состояние: `@Published` для скаляров, `@NestedObservableObject` для вложенных `ObservableObject`. View владеет VM через `@StateObject`.
- Сеть — только через `DoglyadNetwork`, БД — только через `DoglyadDatabase`.
- Тексты — `LocalizedStringResource` из `Localizable.xcstrings` (новые ключи добавляй туда; ru+en).

### Файлы полноэкранного модуля

`<Name>Screen.swift`, `<Name>ScreenView.swift`, `<Name>ViewModel.swift`, `<Name>ScreenArguments.swift`.

**`<Name>ScreenArguments.swift`** (пустые аргументы — оставь тело пустым):
```swift
import Router

final class <Name>ScreenArguments: RouteArgumentsProtocol {
    // let value: SomeType
    // let onResult: (SomeType) -> Void
    // init(...) { ... }
}
```

**`<Name>Screen.swift`**:
```swift
import DoglyadUI
import Router
import SwiftUI

struct <Name>Screen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: <Name>ScreenArguments?

    var body: some View {
        <Name>ScreenView(
            viewModel: <Name>ViewModel(
                container: container,
                router: router
            )
        )
    }
}

#Preview {
    <Name>Screen(
        arguments: nil
    )
    .previewable()
}
```

**`<Name>ViewModel.swift`**:
```swift
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
final class <Name>ViewModel: DViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
        super.init()
    }

    // @Published var items: [Some] = []

    // Грузим данные здесь (вызывается один раз через onAppear -> onInit).
    // override func onInit() {
    //     handle {
    //         await self.container.someRepository.getItems()
    //     } onMainSuccess: { items in
    //         self.items = items
    //     }
    // }

    func onTapBack() {
        router.pop()
    }
}
```

**`<Name>ScreenView.swift`**:
```swift
import DoglyadUI
import SwiftUI

struct <Name>ScreenView: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }

    @StateObject var viewModel: <Name>ViewModel

    var body: some View {
        DScreen(
            title: .<nameLocalizedTitleKey>,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(showsIndicators: false) {
                VStack(spacing: size.s16) {
                    // вёрстка из компонентов DoglyadUI
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .environmentObject(viewModel)
    }
}
```

### Регистрация в навигации (обязательно)

1. В `RouteType.swift` добавь кейс в `enum ScreenType`: `case <name>`.
2. В `RouterBuilder.swift` в `build(route: RouteScreen<ScreenType>)` добавь:
```swift
case .<name>:
    AnyView(
        <Name>Screen(
            arguments: route.arguments as? <Name>ScreenArguments
        )
    )
```
Используй `as!` вместо `as?` только если аргументы обязательны (см. `.conclusion`).

3. Переход на модуль из другого ViewModel:
```swift
router.push(route: RouteScreen(type: .<name>))
// либо с аргументами:
router.push(route: RouteScreen(type: .<name>, arguments: <Name>ScreenArguments(...)))
```

### Вариант BottomSheet

Файлы: `<Name>BottomSheet.swift` + `<Name>Arguments.swift` (sheet обычно проще и часто без отдельных ScreenView/ViewModel — смотри `Select/NeuralModel/`). Каркас View:
```swift
import DoglyadUI
import Router
import SwiftUI

struct <Name>BottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }

    let arguments: <Name>Arguments?

    var body: some View {
        DBottomSheet(
            title: .<nameLocalizedTitleKey>,
            fraction: 0.8
        ) { toolbarHeight in
            ScrollView(showsIndicators: false) {
                VStack(spacing: .zero) {
                    // содержимое
                }
                .padding(size.s16)
                .padding(.top, toolbarHeight)
            }
        }
    }
}

#Preview {
    <Name>BottomSheet(arguments: nil).previewable()
}
```
Регистрация: `enum SheetType { case <name> }` в `RouteType.swift` + кейс в `build(route: RouteSheet<SheetType>)`. Показ: `router.push(route: RouteSheet(type: .<name>, arguments: ...))`, закрытие — `router.dismissSheet()`.

### Финальные шаги

1. Добавь новые ключи локализации в `ios/Doglyad/Resources/Localizable.xcstrings` (ru + en).
2. Файлы подхватятся Xcode-проектом автоматически (synchronized groups) — отдельная правка `project.pbxproj` обычно не нужна; проверь, что новые типы доступны.
3. Запусти `make format` (swiftformat) перед завершением.
4. Сообщи пользователю список созданных файлов и точки регистрации в роутере.
