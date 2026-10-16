// Typography.swift — Tipografía del sistema (SF Pro + Dynamic Type)
// Todos los estilos mapean a text styles de Apple para respetar
// el tamaño de texto del usuario.

import SwiftUI

extension Font {
    static let habLargeTitle = Font.largeTitle.weight(.bold)
    static let habTitle1     = Font.title.weight(.bold)
    static let habTitle2     = Font.title2.weight(.semibold)
    static let habTitle3     = Font.title3.weight(.semibold)
    static let habHeadline   = Font.headline
    static let habBody       = Font.body
    static let habCallout    = Font.callout
    static let habSubhead    = Font.subheadline
    static let habFootnote   = Font.footnote
    static let habCaption    = Font.caption
}
