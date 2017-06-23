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
        
        let parameters: Parameters = ["speechText" : speechText]
        
        Alamofire.request("http://justine.com/speech", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                        sucessHandler(utf8Text)
                    }
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                    faiulerHandler(NSError.init(domain: "Bad server answer", code: -1, userInfo: nil))
            }
        }
    }

}
