//
//  Colors.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let primaryBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // MARK: - Button Colors
    static let primaryButton = Color.blue
    static let secondaryButton = Color(.systemGray5)
    static let destructiveButton = Color.red
    
    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(.tertiaryLabel)
    
    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // MARK: - Accent Colors
    static let accentBlue = Color.blue
    static let accentGreen = Color.green
    static let accentOrange = Color.orange
    static let accentPurple = Color.purple
    
    // MARK: - Border Colors
    static let borderPrimary = Color(.separator)
    static let borderSecondary = Color(.systemGray4)
    static let borderTertiary = Color(.systemGray5)
    
    // MARK: - Shadow Colors
    static let shadowLight = Color.black.opacity(0.1)
    static let shadowMedium = Color.black.opacity(0.2)
    static let shadowDark = Color.black.opacity(0.3)
}
