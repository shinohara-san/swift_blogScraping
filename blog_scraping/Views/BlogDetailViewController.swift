//
//  BlogDetailViewController.swift
//  blog_scraping
//
//  Created by Yuki Shinohara on 2020/07/14.
//  Copyright © 2020 Yuki Shinohara. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class BlogDetailViewController: UIViewController {
    
    var blog: Article!
    var blogs = [Article]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = self?.blog.title
            self?.dateLabel.text = self?.blog.date
        }

        DispatchQueue.global().async {
            self.getData()
        }
        
        wait( { return self.blogs == [Article]() } ) {
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = UIImage(url: (self?.blogs[0].imageURL)!)
                self?.bodyLabel.text = self?.blogs[0].body
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        blogs = [Article]()
    }
    
    func getData(){
        let url = "https://www.aeonet.co.jp\(blog.blogURL)"
        AF.request(url).responseString { [weak self](response) in
            
            guard let self = self else {return}
            
            if let html = response.value {
                //                                print(html)
                if let doc = try? HTML(html: html, encoding: .utf8){
                    
                    var imgUrls = [String]()
                    for imgUrl in doc.xpath("//p[@class='p-blog-img']/img/@src"){
                        //                        print(imgUrl.text ?? "")
                        imgUrls.append(imgUrl.text ?? "")
                    }
                    
                    var bodies = [String]()
                    for body in doc.xpath("//div[@class='p-blog-text-wrp']"){
                        //                        print(body.text ?? "")
                        bodies.append(body.text ?? "")
                    }
                    
                    for (index, value) in imgUrls.enumerated(){
                        var article = Article()
                        article.title = self.blog.title
                        article.date = self.blog.date
                        article.imageURL = value
                        article.body = bodies[index]
                        self.blogs.append(article)
                    }
                }
            }
            
        }
    }
    
   func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
    
}

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: "https://www.aeonet.co.jp" + url)
        do {
            //print(url!)//urlが間違ってる可能性あるのでちゃんとアクセスできるかブラウザ確認
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
