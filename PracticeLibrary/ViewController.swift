//
//  ViewController.swift
//  PracticeLibrary
//
//  Created by riku on 2022/01/21.
//

import UIKit
import Alamofire

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
    
    private func getAddress(zipCode: String) {
        let baseUrlString = "http://zipcloud.ibsnet.co.jp/api/"
        let searchUrlString = "\(baseUrlString)search"
        let searchUrl = URL(string: searchUrlString)!
        guard var components = URLComponents(url: searchUrl, resolvingAgainstBaseURL: searchUrl.baseURL != nil) else {
            return
        }
        components.queryItems = [URLQueryItem(name: "zipcode", value: zipCode)] + (components.queryItems ?? [])
        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else {
                return
            }
            do {
                self.addresses = try JSONDecoder().decode(AddressModel.self, from: data)
                print(self.addresses?.results ?? "")
            } catch let error {
                print("Error: \(error)")
            }
        }.resume()
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












