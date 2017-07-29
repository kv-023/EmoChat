//
//  SignUpRegexController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

protocol RegexCheckProtocol {
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

    //MARK: RestAPI data
    func getArrayOfRegexMatchesForURLInText(text textForAnalyze: String?) -> [String] {
        var valueForReturn:[String] = []

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "(?:(?:https?|ftp|file):\\/\\/|www\\.|ftp\\.)(?:\\([-A-Z0-9+&@#\\/%=~_|$?!:,.]*\\)|[-A-Z0-9+&@#\\/%=~_|$?!:,.])*(?:\\([-A-Z0-9+&@#\\/%=~_|$?!:,.]*\\)|[A-Z0-9+&@#\\/%=~_|$])"
            //
            //"(?i)\\b((?:[a-z][\\w-]+:(?:\\/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}\\/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]\\{};:'\".,<>?«»“”‘’]))"

            valueForReturn = Regex.getMatchesInString(for: regexLoginPattern,
                                                      in: notNullText)
        }

        return valueForReturn
    }

    func removeTransferProtocolTag(text textForAnalyze: String?) -> String {
        var valueForReturn: String = ""

        if let notNullText = textForAnalyze {
            let regexLoginPattern = "(?:https?|ftp|file):\\/\\/|www\\.|ftp\\."

            valueForReturn = Regex.removingRegexMatches(for: regexLoginPattern,
                                                        in: notNullText,
                                                        replaceWith: "") ?? notNullText

        }
        return valueForReturn
    }

    func getMediaFileNameFromURL(text textForAnalyze: String?) -> String {
        var valueForReturn: String = ""

        if let notNullText = textForAnalyze {
            let regexPattern = "(?<=message_voice%)(.*).m4a"

            let arrayOfValueForReturn = Regex.getMatchesInString(for: regexPattern,
                                                      in: notNullText)
            if arrayOfValueForReturn.count > 0 {
                valueForReturn = arrayOfValueForReturn.first!
            }

        }
        return valueForReturn
    }


}

//MARK:- regex error explanation

enum regexErrorText: String, Localizable {
	
	case Title = "app.title"

    static let parent: LocalizeParent = nil

    enum SignUpError: String, Localizable {
		
		static let parent: LocalizeParent = nil
        
        case userName = "app.regexCheck.userName"
        case name = "app.regexCheck.name"
        case lastName = "app.regexCheck.lastName"
        case phone = "app.regexCheck.phone"
        case email = "app.regexCheck.email"
        case password = "app.regexCheck.password"
        case passwordConfirmation = "app.regexCheck.passwordConfirmation"

    }
	
	enum LogInError: String, Localizable {
		static let parent: LocalizeParent = nil
		
		case email = "app.regexCheck.email"
		case password = "app.regexCheck.password"
	}

}
