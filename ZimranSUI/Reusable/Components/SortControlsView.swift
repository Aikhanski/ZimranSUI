//
//  SortControlsView.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct SortControlsView: View {
    @Binding var sortOption: RepositorySortOption
    @Binding var sortOrder: SortOrder
    let onSortOptionChanged: (RepositorySortOption) -> Void
    let onSortOrderToggled: () -> Void
    
    var body: some View {
        HStack(spacing: .spacingM) {
            Menu {
                ForEach(RepositorySortOption.allCases, id: \.self) { option in
                    Button(option.displayName) {
                        onSortOptionChanged(option)
                    }
                }
            } label: {
                HStack(spacing: .spacingS) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                    Text("Sort by: \(sortOption.displayName)")
                        .font(.captionRegular)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal, CGFloat.paddingM)
                .padding(.vertical, CGFloat.paddingS)
                .background(Color.secondaryBackground)
                .cornerRadius(.radiusM)
            }
            
            if sortOption != .bestMatch {
                Button(action: onSortOrderToggled) {
                    HStack(spacing: .spacingXS) {
                        Image(systemName: sortOrder == .asc ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(sortOrder.displayName)
                            .font(.captionRegular)
                    }
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, CGFloat.paddingM)
                    .padding(.vertical, CGFloat.paddingS)
                    .background(Color.secondaryBackground)
                    .cornerRadius(.radiusM)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding(.horizontal, CGFloat.paddingL)
        .padding(.vertical, CGFloat.paddingS)
    }
}

struct UserSortControlsView: View {
    @Binding var sortOption: UserSortOption
    @Binding var sortOrder: SortOrder
    let onSortOptionChanged: (UserSortOption) -> Void
    let onSortOrderToggled: () -> Void
    
    var body: some View {
        HStack(spacing: .spacingM) {
            Menu {
                ForEach(UserSortOption.allCases, id: \.self) { option in
                    Button(option.displayName) {
                        onSortOptionChanged(option)
                    }
                }
            } label: {
                HStack(spacing: .spacingS) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                    Text("Sort by: \(sortOption.displayName)")
                        .font(.captionRegular)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal, CGFloat.paddingM)
                .padding(.vertical, CGFloat.paddingS)
                .background(Color.secondaryBackground)
                .cornerRadius(.radiusM)
            }
            
            if sortOption != .bestMatch {
                Button(action: onSortOrderToggled) {
                    HStack(spacing: .spacingXS) {
                        Image(systemName: sortOrder == .asc ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(sortOrder.displayName)
                            .font(.captionRegular)
                    }
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, CGFloat.paddingM)
                    .padding(.vertical, CGFloat.paddingS)
                    .background(Color.secondaryBackground)
                    .cornerRadius(.radiusM)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding(.horizontal, CGFloat.paddingL)
        .padding(.vertical, CGFloat.paddingS)
    }
}

#Preview {
    @State var sortOption: RepositorySortOption = .stars
    @State var sortOrder: SortOrder = .desc
    
    return VStack(spacing: .spacingL) {
        SortControlsView(
            sortOption: $sortOption,
            sortOrder: $sortOrder,
            onSortOptionChanged: { option in
                sortOption = option
            },
            onSortOrderToggled: {
                sortOrder = sortOrder == .asc ? .desc : .asc
            }
        )
        
        Text("Current: \(sortOption.displayName) - \(sortOrder.displayName)")
            .font(.captionRegular)
            .foregroundColor(.secondaryText)
    }
    .padding()
}
