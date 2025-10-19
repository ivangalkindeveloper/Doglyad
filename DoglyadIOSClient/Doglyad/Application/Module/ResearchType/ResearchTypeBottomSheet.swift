//
//  ResearchTypeScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

struct ResearchTypeScreenArguments: RouteArgumentsProtocol {
    let onSelected: (ResearchType) -> Void
}
    
struct ResearchTypeBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: ResearchTypeScreenArguments?
    @StateObject private var viewModel = ResearchTypeViewModel()
    
    var body: some View {
        DBottomSheet(
            title: L10n.researchTypeTitle.string,
            content: {
                ForEach(
                    viewModel.researchTypes
                ) { type in
                    Button {
                        dismiss()
                        viewModel.onPressedType(
                            arguments: arguments,
                            type: type
                        )
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.title.string)
                                    .font(.headline)
                            }
                            Spacer()
                            Image(systemName: "largecircle.fill.circle")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                DText(
                    L10n.researchTypeFutureAddingDescription.string
                )
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlaceholder,
                    alignment: .center
                )
                .padding(size.s16)
            }
        )
    }
}

#Preview {
    ApplicationWrapperView {
        DThemeWrapperView {
            ResearchTypeBottomSheet(
                arguments: nil
            )
        }
    }
}
