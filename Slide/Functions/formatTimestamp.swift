//  formatTimestamp.swift
//  Slide
//  Created by Ethan Harianto on 8/5/23.

import SwiftUI
import Firebase

public func formatTimestamp(_ timestamp: Timestamp) -> String {
    let currentDate = Date()
    let messageDate = timestamp.dateValue()

    let calendar = Calendar.current
    if calendar.isDateInToday(messageDate) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: messageDate)
    } else if calendar.isDate(messageDate, equalTo: currentDate, toGranularity: .weekOfYear) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Day of the week
        return formatter.string(from: messageDate)
    } else {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: messageDate)
    }
}
