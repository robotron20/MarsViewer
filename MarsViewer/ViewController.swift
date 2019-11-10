//
//  ViewController.swift
//  MarsViewer
//
//  Created by John Ostlund on 11/7/19.
//  Copyright © 2019 John Ostlund. All rights reserved.
//

import UIKit

struct Mars: Decodable {
    
    let photos: [Photo]
    
}

struct Photo: Decodable {
    
    let id: Int
    let sol: Int
    let img_src: String
    let earth_date: String
    
}

struct PhotoRowData {
    
    let name: String
    let image: UIImage
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let headerView = UIView()
    let marsRoverLabel = UILabel()
    let solTextView = UITextView()
    let imageTable = UITableView()
    let keyboardView = UIView()
    let doneButton = UIButton()
    
    let imageView = UIView()
    
    
    var photoRowDataList = [PhotoRowData]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photoRowDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.photoRowDataList[indexPath.item].name
        cell.imageView?.image = self.photoRowDataList[indexPath.item].image
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let image = self.photoRowDataList[indexPath.item]
        
        
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //layout
        self.headerView.backgroundColor = .orange
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140)
        self.view.addSubview(self.headerView)
        
        self.doneButton.setTitle("Done", for: .normal)
        self.keyboardView.backgroundColor = .lightGray
        self.keyboardView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        self.doneButton.frame = CGRect(x: self.view.frame.width - 80, y: 0, width: 60, height: 60)
        self.keyboardView.addSubview(self.doneButton)
        self.doneButton.addTarget(self, action: #selector(self.donePressed), for: .touchUpInside)
        
        self.solTextView.inputAccessoryView = self.keyboardView
        self.solTextView.layer.cornerRadius = 10
        self.solTextView.font = UIFont.systemFont(ofSize: 18)
        self.solTextView.text = "1"
        self.solTextView.textAlignment = .center
        self.solTextView.keyboardType = .numberPad
        self.solTextView.frame = CGRect(x: 100, y: 45, width: self.view.frame.width - 200, height: 40)
        self.headerView.addSubview(self.solTextView)
        
        self.marsRoverLabel.textAlignment = .center
        self.marsRoverLabel.text = "Mars Rover Sol"
        self.marsRoverLabel.frame = CGRect(x: 0, y: 95, width: self.view.frame.width, height: 12)
        self.headerView.addSubview(self.marsRoverLabel)
        
        self.imageTable.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: self.view.frame.height - 120)
        self.view.addSubview(self.imageTable)

        self.imageTable.dataSource = self
        self.imageTable.delegate = self
        self.imageTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.begin()
        
    }
    
    @objc func donePressed() {
        
        self.solTextView.resignFirstResponder()
        self.solTextView.endEditing(true)
        
    }
    
    func begin() {

        self.parsePhotos(sol: 1)
        
    }
    
    func parsePhotos(sol: Int) {
        
        if let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=\(sol)&api_key=nujVIFrr9L96fhWX8XhZgjWnRSvXiq5jh5nljKZy") {
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                guard let data = data else { return }
                
                do {
                    
                    let mars = try JSONDecoder().decode(Mars.self, from: data)
                    
                    for photo in mars.photos {
                        
                        if let url = URL(string: photo.img_src) {
                            
                            self.getData(from: url) { data, response, error in
                                
                                guard let data = data, error == nil else { return }
                                
                                DispatchQueue.main.async() {
                                    
                                    if let image = UIImage(data: data) {

                                        let photoView = PhotoRowData(name: photo.img_src, image: image)
                                        
                                        self.photoRowDataList.append(photoView)
                                        
                                        self.imageTable.reloadData()

                                    }
                                    
                                }
                                
                            }
                            
                        }
 
                    }
                    
                }
                catch let jsonErr {
                    print("Error serializing json:", jsonErr)
                }
                
            }
            task.resume()
            
        }
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}

