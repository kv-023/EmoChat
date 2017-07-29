//
//  File.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 29.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModelAudio: MessageModelGeneric {

//    var dataForMediaInfoView: DataForAudioMessageInfoView?

    //prepare data for conversation's cell
    func getParseDataFromResource(delaySeconds delay: Int = 0,
                                  completion: @escaping(_ allDone: Bool) -> Void) {

        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + .seconds(delay), execute: {[unowned self] in

                //smth to do...

                DispatchQueue.main.async {
                    
                    completion(true)
                }
        })
    }

}
