//
//  TenjinBlogViewController.swift
//  blog_scraping
//
//  Created by Yuki Shinohara on 2020/07/11.
//  Copyright © 2020 Yuki Shinohara. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class TenjinBlogViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    private var blogs = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        blogs = [Article]()
    }
    
    func getData(){
        let url = "https://www.aeonet.co.jp/school/kyushu/fukuoka/4024/blog/"
        AF.request(url).responseString { [weak self](response) in
            
            guard let self = self else {return}
            
            if let html = response.value {
                print(html)
                if let doc = try? HTML(html: html, encoding: .utf8){
                    var error = [String]()
                    for e in doc.xpath("//h1"){
                        error.append(e.text ?? "")
                    }
                    
                    var titles = [String]()
                    for title in doc.xpath("//h3[@class='p-blog-title']/a"){
                        print(title.text ?? "")
                        titles.append(title.text ?? "")
                    }
                    
                    var dates = [String]()
                    for date in doc.xpath("//p[@class='p-blog-date']"){
                        dates.append(date.text ?? "")
                    }
                    //
                    if error.count > 0{
                        let article = Article()
                        article.title = error[0]
                        article.date = "アクセスエラー"
                        self.blogs.append(article)
                    } else {
                        for (index, value) in titles.enumerated(){
                            let article = Article()
                            article.title = value
                            article.date = dates[index]
                            self.blogs.append(article)
                        }
                    }
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.table.reloadData()
                    }
                    
                }
            }
            
        } 
    }
}



extension TenjinBlogViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tenjinCell", for: indexPath)
        let blog = blogs[indexPath.row]
        cell.textLabel?.text = blog.title
        cell.detailTextLabel?.text = blog.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
