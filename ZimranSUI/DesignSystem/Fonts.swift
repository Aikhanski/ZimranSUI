//
//  Fonts.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

extension Font {
    static let titleLarge = Font.largeTitle.weight(.bold)
    static let titleMedium = Font.title.weight(.semibold)
    static let titleSmall = Font.title2.weight(.semibold)
    
    static let bodyLarge = Font.title3.weight(.medium)
    static let bodyRegular = Font.body.weight(.regular)
    static let bodySmall = Font.callout.weight(.regular)
    
    static let captionLarge = Font.subheadline.weight(.medium)
    static let captionRegular = Font.caption.weight(.regular)
    static let captionSmall = Font.caption2.weight(.regular)
    
    static let buttonLarge = Font.title3.weight(.semibold)
    static let buttonRegular = Font.body.weight(.semibold)
    static let buttonSmall = Font.callout.weight(.semibold)
    
    static let labelLarge = Font.headline.weight(.medium)
    static let labelRegular = Font.subheadline.weight(.medium)
    static let labelSmall = Font.caption.weight(.medium)
}
