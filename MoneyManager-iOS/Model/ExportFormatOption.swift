//
//  ExportFormatOption.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 30/4/26.
//

import SwiftUI

enum ExportFormatOption: String, CaseIterable, Identifiable {
    case csv
    case pdf

    var id: String { rawValue }

    var title: String {
        switch self {
        case .csv:
            return "CSV File"
        case .pdf:
            return "PDF Document"
        }
    }

    var subtitle: String {
        switch self {
        case .csv:
            return "Best for spreadsheets and data analysis"
        case .pdf:
            return "Formatted report for viewing or sharing"
        }
    }

    var actionTitle: String {
        switch self {
        case .csv:
            return "Export CSV"
        case .pdf:
            return "Export PDF"
        }
    }

    var tintColor: Color {
        switch self {
        case .csv:
            return Color(hex: "#34C759")
        case .pdf:
            return Color(hex: "#1677F2")
        }
    }

    var iconName: String {
        switch self {
        case .csv:
            return "tablecells"
        case .pdf:
            return "doc.text"
        }
    }
}
