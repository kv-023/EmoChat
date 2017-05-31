//
//  Auxiliary.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 31.05.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

struct Auxiliary {

    static func getUUID() -> String {

        let uuid = UUID().uuidString
        return uuid
    }

    static func getEmpyUUID() -> String {
        return "00000000-0000-0000-0000-000000000000"
    }
}

