//
//  StoryService.swift
//  InstagramStory
//
//  Created by Otis on 2024/9/23.
//

import Foundation

// 資料格式
struct Story: Codable {
    let id: String
    let mediaType: String
    let mediaUrl: String
    let duration: Int
}

class StoryService {
    // 抓取 Story 資料
    func fetchStories(completion: @escaping ([Story]) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/stories") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch stories: \(String(describing: error))")
                return
            }

            do {
                let stories = try JSONDecoder().decode([Story].self, from: data)
                DispatchQueue.main.async {
                    completion(stories)
                }
            } catch {
                print("Failed to decode stories: \(error)")
            }
        }.resume()
    }
}
