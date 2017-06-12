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
            let regexLoginPattern = "^[a-z0-9-]{5,}$"
            flagForReturn = Regex.isMatchInString(for: regexLoginPattern,
                                                       in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }

    func nameIsValid(uname textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexNamePattern = "^[a-zA-Z-']{0,18}$"
            flagForReturn = Regex.isMatchInString(for: regexNamePattern,
                                                  in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }
    
    func lastNameIsValid(uname textForAnalyze: String?) -> Bool {
        var flagForReturn = true
        
        if let notNullText = textForAnalyze {
            let regexNamePattern = "^[a-zA-Z-']{0,18}$"
            flagForReturn = Regex.isMatchInString(for: regexNamePattern,
                                                  in: notNullText)
        }
        
        showInfoSignUp(flagForReturn)
        return flagForReturn
    }
    
    func phoneIsValid(uname textForAnalyze: String?) -> Bool {
        var flagForReturn = true
        
        if let notNullText = textForAnalyze {
            let regexPhonePattern = "^[+0-9]{0,13}$"
            flagForReturn = Regex.isMatchInString(for: regexPhonePattern,
                                                  in: notNullText)
        }
        
        showInfoSignUp(flagForReturn)
        return flagForReturn
    }
    

    func emailIsValid(userEmail textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            flagForReturn = Regex.isMatchInString(for: regexLoginPattern,
                                                  in: notNullText)
        }

        showInfoSignUp(flagForReturn)
        return flagForReturn
    }

    func passwordIsValid(userPassword textForAnalyze: String?) -> Bool {
        var flagForReturn = true

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "^.{6,}$"
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
