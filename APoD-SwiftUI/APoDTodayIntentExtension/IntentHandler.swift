//
//  IntentHandler.swift
//  APoDTodayIntentExtension
//
//  Created by Kuixi Song on 7/23/23.
//

import Intents

class IntentHandler: INExtension, APoDTodayIntentsIntentHandling {

    func resolveSelectDate(for intent: APoDTodayIntentsIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        guard let dateComponents = intent.selectDate, let date = dateComponents.date else {
            completion(.confirmationRequired(with: intent.selectDate))
            return
        }
        if Utils.validDateRange().contains(date) {
            completion(.success(with: dateComponents))
        } else {
            completion(.confirmationRequired(with: dateComponents))
        }
    }

}
