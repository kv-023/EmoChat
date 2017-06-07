//
//  SignUpRegexController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

protocol RegexCheckProtocol {

//    func usernameIsValid() -> Bool
//    func emailIsValid() -> Bool
//    func passwordIsValid() -> Bool
}

extension RegexCheckProtocol {

    func usernameIsValid(userName textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "^[a-zA-Z0-9-]{3,}$"
            flagForReturn = Regex.isMatchInString(for: regexLoginPattern,
                                                       in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }

    func emailIsValid(userEmail textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            flagForReturn = Regex.isMatchInString(for: regexLoginPattern,
                                                  in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }

    func passwordIsValid(userPassword textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "^.{3,}$"
            flagForReturn = Regex.isMatchInString(for: regexLoginPattern,
                                                  in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }

    private func showInfoSignUp(_ flag: Bool) {
        if flag {
            print("All fine!")
        } else {
            print("An error occurred")
        }
    }

}
