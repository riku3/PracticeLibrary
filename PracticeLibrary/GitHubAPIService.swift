//
//  GitHubAPIService.swift
//  PracticeLibrary
//
//  Created by riku on 2022/01/24.
//

import Foundation
import Moya

//class GitHubAPIService {}

protocol GitHubAPITargetType: TargetType {
    associatedtype Response: Codable
}

extension GitHubAPITargetType {
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    var headers: [String : String]? { return ["Content-Type": "application/json"] }
}

extension GitHubAPIService {
    struct UserProfileRequest: GitHubAPITargetType {
        
        typealias Response = UserProfile
        
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
        
        typealias Response = [Repository]
        
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

protocol GitHubAPI {
    func send<T: GitHubAPITargetType>(_ request: T, completion: @escaping (Result<T.Response, Moya.MoyaError>) -> Void)
}

class GitHubAPIService: GitHubAPI {
    func send<T>(_ request: T, completion: @escaping (Result<T.Response, MoyaError>) -> Void) where T : GitHubAPITargetType {
        let provider = MoyaProvider<T>()
        provider.request(request) {result in
            switch result {
            case let.success(response):
                let decoder = JSONDecoder()
                if let model = try? decoder.decode(T.Response.self, from: response.data) {
                    completion(.success(model))
                    print(try! response.mapJSON())
                } else {
                    completion(.failure(.jsonMapping(response)))
                }
            case let.failure(error):
                completion(.failure(error))
            }
        }
    }
    
    
}
