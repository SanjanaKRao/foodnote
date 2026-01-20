import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    private init() {}
    
    private let apiKey = Secrets.openAIAPIKey
    
    func detectFoodName(from image: UIImage) async throws -> String {
        // Resize image to reduce token usage
        guard let resizedImage = resizeImage(image, maxDimension: 512),
              let imageData = resizedImage.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "What food is in this image? Respond with ONLY the name of the food, nothing else. Be concise (2-4 words maximum)."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        // Retry logic for rate limits
        var lastError: Error?
        for attempt in 1...3 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 429 {
                    // Rate limited - wait and retry
                    print("Rate limited, attempt \(attempt)/3")
                    if attempt < 3 {
                        try await Task.sleep(nanoseconds: UInt64(attempt * 2_000_000_000)) // Wait 2, 4 seconds
                        continue
                    }
                    throw NSError(domain: "OpenAI", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded. Please wait a moment and try again."])
                }
                
                guard httpResponse.statusCode == 200 else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                    }
                    throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status \(httpResponse.statusCode)"])
                }
                
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let choices = json?["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
                }
                
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
                
            } catch {
                lastError = error
                if attempt < 3 {
                    print("Attempt \(attempt) failed: \(error.localizedDescription)")
                }
            }
        }
        
        throw lastError ?? NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed after 3 attempts"])
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
