//
//  APoDAPIHelper.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import Foundation

class APoDAPIHelper {

    static let shared = APoDAPIHelper()

    private static let baseURLString = "https://api.nasa.gov/planetary/apod"
    private static let apiKey = "YOUR_API_KEY"

    private init() {
        
    }

    @MainActor
    func loadAPoDData(for date: Date) async -> APoDModel? {
        guard var requestURL = URL(string: Self.baseURLString) else {
            return nil
        }
        requestURL.append(queryItems: [
            URLQueryItem(name: "api_key", value: Self.apiKey),
            URLQueryItem(name: "date", value: Utils.dateFormatter.string(from: date)),
            URLQueryItem(name: "thumbs", value: "True"),
        ])
        debugPrint("Requesting \(requestURL.absoluteString)")
        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            return try JSONDecoder().decode(APoDModel.self, from: data)
        } catch let error {
            debugPrint("Request error \(error.localizedDescription)")
            return nil
        }
    }

}
