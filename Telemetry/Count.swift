//
//  Count.swift
//  Telemetry
//
//  Created by MacBook on 22/07/2023.
//

import Foundation

class ContentViewState: ObservableObject {
    @Published private(set) var count: Int = 0
    
    func countUp() {
        count += 1
    }
    
    func reset() {
        count = 0
    }
}
