//
//  ViewController.swift
//  PracticeLibrary
//
//  Created by riku on 2022/01/21.
//

import UIKit
import Alamofire
import Moya

struct UserProfile: Codable {
    let id: Int
    let name: String
    let email: String?
    let avatarUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarUrl = "avatar_url"
    }
}

struct Repository: Codable {

    let id: Int
    let name: String
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case url = "html_url"
    }
}

enum GitHub {
    case profile(name: String)
    case repository(name: String, type: String)
}

extension GitHub: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case let.profile(name):
            return "/users/\(name)"
        case let.repository(name, _):
            return "/users/\(name)/repos"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .profile:
            return .requestPlain
        case let.repository(_, type):
            return .requestParameters(parameters: ["type" : type], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var articleListTableView: UITableView!

    let decoder: JSONDecoder = JSONDecoder()
    var articles = [Article]()
    var addresses: AddressModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getQiitaArticles()
        getAddress(zipCode: "2790031")
        getGithubProfile()
        getGithubRepository()
        getGitHubAPI()
    }
    
    private func getGithubProfile() {
        let provider = MoyaProvider<GitHubAPIService.UserProfileRequest>()
        provider.request(GitHubAPIService.UserProfileRequest(name: "y-hryk")) { result in
            switch result {
            case let.success(response):
                let decoder = JSONDecoder()
                let profile = try! decoder.decode(UserProfile.self, from: response.data)
                print("Profile: SUCCESS StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(profile)
                print("Profile: SUCCESS EndXXXXXXXXXXXXXXXXXXXXXXXXX")
            case let.failure(error):
                print("Profile: ERROR StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(error)
                print("Profile: ERROR EndXXXXXXXXXXXXXXXXXXXXXXXXX")
                break
            }
        }
    }
    
    private func getGithubRepository() {
        let provider = MoyaProvider<GitHubAPIService.RepositoryRequest>()
        provider.request(GitHubAPIService.RepositoryRequest(name: "y-hryk", type: "all")) { (result) in
            switch result {
            case let .success(response):
                
                let decoder = JSONDecoder()
                let data = try! decoder.decode([Repository].self, from: response.data)
                print("Repository: SUCCESS StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(data)
                print("Repository: SUCCESS EndXXXXXXXXXXXXXXXXXXXXXXXXX")
            case let .failure(error):
                print("Repository: ERROR StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(error)
                print("Repository: ERROR EndXXXXXXXXXXXXXXXXXXXXXXXXX")
                break
            }
        }
    }
    
    private func getGitHubAPI() {
        let provider = GitHubAPIService()
        provider.send(GitHubAPIService.UserProfileRequest(name: "y-hryk")) {result in
            switch result {
            case .success(let response):
                print("Common: SUCCESS StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(response)
                print("Common: SUCCESS EndXXXXXXXXXXXXXXXXXXXXXXXXX")
            case .failure(let error):
                print("Common: ERROR StartXXXXXXXXXXXXXXXXXXXXXXXXX")
                print(error)
                print("Common: ERROR EndXXXXXXXXXXXXXXXXXXXXXXXXX")
            }
        }
    }
    
    private func setup() {
        articleListTableView.delegate = self
        articleListTableView.dataSource = self
    }
    
    private func getQiitaArticles() {
        AF.request("https://qiita.com/api/v2/items").responseJSON { response in
            switch response.result {
            case .success:
                do {
                    self.articles = try self.decoder.decode([Article].self, from: response.data!)
                    self.articleListTableView.reloadData()
                } catch {
                    print("デコードに失敗しました")
                }
            case .failure(let error):
                print("error", error)
            }
        }
    }
    
//    private func getAddress(zipCode: String) {
//        let baseUrlString = "http://zipcloud.ibsnet.co.jp/api/"
//        let searchUrlString = "\(baseUrlString)search"
//        let searchUrl = URL(string: searchUrlString)!
//        guard var components = URLComponents(url: searchUrl, resolvingAgainstBaseURL: searchUrl.baseURL != nil) else {
//            return
//        }
//        components.queryItems = [URLQueryItem(name: "zipcode", value: zipCode)] + (components.queryItems ?? [])
//        var request = URLRequest(url: components.url!)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            guard let data = data else {
//                return
//            }
//            do {
//                self.addresses = try JSONDecoder().decode(AddressModel.self, from: data)
//                print(self.addresses?.results ?? "")
//            } catch let error {
//                print("Error: \(error)")
//            }
//        }.resume()
//    }
    private func getAddress(zipCode: String) {
        let baseUrl = "http://zipcloud.ibsnet.co.jp/api/"
        let searchUrl = "\(baseUrl)search"
        let parameters: [String: Any] = ["zipcode": zipCode]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        AF.request(searchUrl, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: headers).responseJSON { response in
            guard let data = response.data else {
                return
            }
            do {
                self.addresses = try JSONDecoder().decode(AddressModel.self, from: data)
                print(self.addresses?.results ?? "")
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath)
        cell.textLabel?.text = articles[indexPath.row].title
        return cell
    }
}












