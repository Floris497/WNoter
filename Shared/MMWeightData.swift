//
//  MMWeightData.swift
//  WNoter
//
//  Created by Floris Fredrikze on 25/09/2020.
//

import SwiftUI
import Combine

enum MMWeightType {
    case kTempWeight
    case kDefiniteWeight
}

struct MMWeightData: Hashable, Identifiable {
    let id = UUID()
    let date = Date()
    
    var weight: Int
    var type: MMWeightType
}
