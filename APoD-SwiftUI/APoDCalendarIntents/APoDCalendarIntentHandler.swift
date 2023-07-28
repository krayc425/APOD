//
//  IntentHandler.swift
//  APoDCalendarIntents
//
//  Created by Kuixi Song on 7/28/23.
//

import Intents

class IntentHandler: INExtension, APoDCalendarIntentHandling {

    func resolveSelectDate(for intent: APoDCalendarIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
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
