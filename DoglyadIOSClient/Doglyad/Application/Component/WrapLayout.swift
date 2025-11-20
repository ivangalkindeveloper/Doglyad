import SwiftUI

struct WrapLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if width + size.width > maxWidth {
                width = 0
                height += rowHeight
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, size.height)
            width += size.width
        }
        
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.width {
                x = 0
                y += rowHeight
                rowHeight = 0
            }
            
            view.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            
            x += size.width
            rowHeight = max(rowHeight, size.height)
        }
    }
}
