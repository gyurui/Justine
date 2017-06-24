//
//  NetworkManager.swift
//  justine
//
//  Created by Trum Gyorgy on 2017. 06. 23..
//  Copyright © 2017. oncehack. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    
    private override init() {
    
    }
    
    func postText(speechText: String, success sucessHandler: @escaping (String) -> (), failure faiulerHandler: @escaping (NSError) -> () ) {
        
        
        
        var parameters: Parameters = ["text" : speechText]
        print(parameters)
        
        Alamofire.request("http://207.154.248.136/botman/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...201)
            .validate(contentType: ["text/html"])
            .responseData { response in
                switch response.result {
                case .success:
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        let dict = self.convertToDictionary(text: utf8Text)
                        print("Data: \(dict)")
                        if dict == nil {
                            sucessHandler("Erre nincs válaszom!")
                            return
                        }
                        guard let ansDict = dict as? [String: String], let answer = ansDict["text"] as? String else {
                            faiulerHandler(NSError.init(domain: "Bad server answer", code: -1, userInfo: nil))
                            return
                        }
                        sucessHandler(answer)
                    }
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                    faiulerHandler(NSError.init(domain: "Bad server answer", code: -1, userInfo: nil))
            }
        }
    }

    func convertToDictionary(text: String) -> [String: String]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
}
