//
//  APoDAPIHelper.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import Foundation
import UIKit

class APoDAPIHelper {

    static let shared = APoDAPIHelper()

    private static let baseURLString = "https://api.nasa.gov/planetary/apod"
    private static let apiKey = "YOUR_API_KEY"

    private init() {
        
    }

    @MainActor
    func loadAPoDData(for date: Date) async -> APoDModel? {
        guard let requestURL = buildURL(for: date) else {
            return nil
        }
        debugPrint("Requesting \(requestURL.absoluteString)")
        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            return try JSONDecoder().decode(APoDModel.self, from: data)
        } catch let error {
            debugPrint("Request error \(error.localizedDescription)")
            return nil
        }
    }

    func loadAPoDData(for date: Date, completion: @escaping (APoDModel?) -> Void) {
        guard let requestURL = buildURL(for: date) else {
            completion(nil)
            return
        }
        debugPrint("Requesting \(requestURL.absoluteString)")
        let dataTask = URLSession.shared.dataTask(with: URLRequest(url: requestURL), completionHandler: { data, response, error in
            if let data {
                let model = try? JSONDecoder().decode(APoDModel.self, from: data)
                completion(model)
            } else {
                completion(nil)
            }
        })
        dataTask.resume()
    }

    func loadImageData(imageURL: URL, completion: @escaping (UIImage?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: URLRequest(url: imageURL), completionHandler: { data, response, error in
            if let data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        })
        dataTask.resume()
    }

    private func buildURL(for date: Date) -> URL? {
        guard var requestURL = URL(string: Self.baseURLString) else {
            return nil
        }
        requestURL.append(queryItems: [
            URLQueryItem(name: "api_key", value: Self.apiKey),
            URLQueryItem(name: "date", value: Utils.dateFormatter.string(from: date)),
            URLQueryItem(name: "thumbs", value: "True"),
        ])
        return requestURL
    }

}
