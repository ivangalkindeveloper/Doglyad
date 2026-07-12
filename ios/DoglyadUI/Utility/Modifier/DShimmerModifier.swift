import Shimmer
import SwiftUI

public struct DShimmerModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = .infinity) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                Color.clear
                    .shimmering(
                        animation: Animation.linear(duration: 1.5)
                            .delay(2.4)
                            .repeatForever(autoreverses: false),
                        // Крайние стопы прозрачны: LinearGradient заливает область
                        // вне «полосы» крайним цветом, поэтому непрозрачные края дали бы
                        // постоянное побеление всей вьюхи, а не только бегущий блик.
                        gradient: Gradient(colors: [
                            .clear,
                            .white,
                            .clear,
                        ]),
                        bandSize: 0.8,
                        mode: .overlay(blendMode: .overlay)
                    )
                    .cornerRadius(cornerRadius)
                    .allowsHitTesting(false)
            }
    }
}

public extension View {
    /// Накладывает поверх вью периодический шиммер-блик дизайн-системы.
    /// - Parameter cornerRadius: радиус скругления блика (`.infinity` — капсула).
    func dShimmer(cornerRadius: CGFloat = .infinity) -> some View {
        modifier(DShimmerModifier(cornerRadius: cornerRadius))
    }
}

// Форма-подложка для превью: без непрозрачного фона блик шиммера не виден.
private func shimmerSurface(
    _ label: String,
    cornerRadius: CGFloat,
    height: CGFloat = 56
) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
        .fill(
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .frame(height: height)
        .overlay {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
        }
}

#Preview("Chip (капсула)") {
    Text("PRO")
        .font(.footnote.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(.blue))
        .dShimmer()
        .padding()
}

#Preview("Карточка") {
    shimmerSurface("Premium card", cornerRadius: 24, height: 120)
        .dShimmer(cornerRadius: 24)
        .padding()
}

#Preview("Сравнение радиусов") {
    VStack(spacing: 24) {
        shimmerSurface("cornerRadius 0", cornerRadius: 0)
        shimmerSurface("cornerRadius 0", cornerRadius: 0)
            .dShimmer(cornerRadius: 0)

        shimmerSurface("cornerRadius 12", cornerRadius: 12)
            .dShimmer(cornerRadius: 12)

        shimmerSurface("cornerRadius 28", cornerRadius: 28)
            .dShimmer(cornerRadius: 28)

        Capsule()
            .fill(
                LinearGradient(
                    colors: [.blue, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 56)
            .overlay {
                Text("капсула (.infinity)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .dShimmer()
    }
    .padding()
}
