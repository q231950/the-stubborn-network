//
//  RecordMode.swift
//  
//
//  Created by Martin Kim Dung-Pham on 24.09.19.
//

import Foundation

public enum RecordMode {
    // freshly records all stubs
    case record

    // records only stubs which don't exist yet
    case recordNew

    // plays stubs back and does not record anything
    case playback
}
