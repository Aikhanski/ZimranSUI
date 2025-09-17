//
//  Spacing.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

extension CGFloat {
    // MARK: - Spacing Scale
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    static let spacingXXXL: CGFloat = 32
    
    // MARK: - Padding Scale
    static let paddingXS: CGFloat = 4
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 12
    static let paddingL: CGFloat = 16
    static let paddingXL: CGFloat = 20
    static let paddingXXL: CGFloat = 24
    static let paddingXXXL: CGFloat = 32
    
    // MARK: - Border Radius
    static let radiusS: CGFloat = 4
    static let radiusM: CGFloat = 8
    static let radiusL: CGFloat = 12
    static let radiusXL: CGFloat = 16
    static let radiusXXL: CGFloat = 20
}

extension EdgeInsets {
    static let paddingXS = EdgeInsets(top: .paddingXS, leading: .paddingXS, bottom: .paddingXS, trailing: .paddingXS)
    static let paddingS = EdgeInsets(top: .paddingS, leading: .paddingS, bottom: .paddingS, trailing: .paddingS)
    static let paddingM = EdgeInsets(top: .paddingM, leading: .paddingM, bottom: .paddingM, trailing: .paddingM)
    static let paddingL = EdgeInsets(top: .paddingL, leading: .paddingL, bottom: .paddingL, trailing: .paddingL)
    static let paddingXL = EdgeInsets(top: .paddingXL, leading: .paddingXL, bottom: .paddingXL, trailing: .paddingXL)
    static let paddingXXL = EdgeInsets(top: .paddingXXL, leading: .paddingXXL, bottom: .paddingXXL, trailing: .paddingXXL)
}
