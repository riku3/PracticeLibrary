//
//  GitHubAPIService.swift
//  PracticeLibrary
//
//  Created by riku on 2022/01/24.
//

import Foundation
import Moya

class GitHubAPIService {}

protocol GitHubAPITargetType: TargetType {}

extension GitHubAPITargetType {
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    var headers: [String : String]? { return ["Content-Type": "application/json"] }
}

extension GitHubAPIService {
    struct UserProfileRequest: GitHubAPITargetType {
        var method: Moya.Method { return .get }
        var path: String { return "/users/\(self.name)" }
        
        var task: Task { return .requestPlain }
//                var sampleData: Data { return Data() }
        
        let name: String
        
        init(name: String) {
            self.name = name
        }
    }
}

extension GitHubAPIService {
    struct RepositoryRequest: GitHubAPITargetType {
        
        var method: Moya.Method { return .get }
        var path: String { return "/users/\(self.name)/repos" }
        
//        var sampleData: Data {
//            let path = Bundle.main.path(forResource: "repository", ofType: "json")!
//            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
//        }
        
        var task: Task { return .requestParameters(parameters: ["type" : self.type], encoding: URLEncoding.default) }
        
        let name: String
        let type: String
        
        init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }
}
