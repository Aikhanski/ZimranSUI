//
//  Fonts.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

extension Font {
    // MARK: - Title Styles
    static let titleLarge = Font.largeTitle.weight(.bold)
    static let titleMedium = Font.title.weight(.semibold)
    static let titleSmall = Font.title2.weight(.semibold)
    
    // MARK: - Body Styles
    static let bodyLarge = Font.title3.weight(.medium)
    static let bodyRegular = Font.body.weight(.regular)
    static let bodySmall = Font.callout.weight(.regular)
    
    // MARK: - Caption Styles
    static let captionLarge = Font.subheadline.weight(.medium)
    static let captionRegular = Font.caption.weight(.regular)
    static let captionSmall = Font.caption2.weight(.regular)
    
    // MARK: - Button Styles
    static let buttonLarge = Font.title3.weight(.semibold)
    static let buttonRegular = Font.body.weight(.semibold)
    static let buttonSmall = Font.callout.weight(.semibold)
    
    // MARK: - Label Styles
    static let labelLarge = Font.headline.weight(.medium)
    static let labelRegular = Font.subheadline.weight(.medium)
    static let labelSmall = Font.caption.weight(.medium)
}
