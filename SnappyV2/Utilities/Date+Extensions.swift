//
//  Date+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 25/02/2022.
//
import Foundation

extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
