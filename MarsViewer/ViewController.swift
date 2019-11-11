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
    let rover: Rover
    
}

struct Rover: Decodable {
    
    let id: Int
    let name: String
    
}

struct PhotoRowData {
    
    let name: String
    let image: UIImage
    let text: String
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let headerView = UIView()
    let marsRoverLabel = UILabel()
    let solTextField = UITextField()
    let imageTable = UITableView()
    let keyboardView = UIView()
    let doneButton = UIButton()
    
    let backgroundView = UIView()
    let imageView = UIImageView()
    let textView = UITextView()
    
    let noneFoundBackgroundView = UIView()
    let noneFoundView = UIView()
    let noneFoundLabel = UILabel()
    let noneFoundOkButton = UIButton()
    
    var previousSol = "1"
    
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
        
        print("Row selected\(indexPath.item)")
        
        self.backgroundView.layer.opacity = 1.0
        
        let image = self.photoRowDataList[indexPath.item].image
        
        if image.size.width > self.view.frame.width {
            
            let scale = self.view.frame.width / image.size.width
            
            self.imageView.frame.size = CGSize(width: self.view.frame.width, height: image.size.height * scale)
            
        }
        else {
            self.imageView.frame.size = CGSize(width: image.size.width, height: image.size.height)
        }

        self.imageView.center = self.backgroundView.center
        self.imageView.image = image
        
        self.textView.text = self.photoRowDataList[indexPath.item].text
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.headerView.backgroundColor = .orange
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140)
        self.view.addSubview(self.headerView)
        
        self.doneButton.setTitle("Done", for: .normal)
        self.keyboardView.backgroundColor = .lightGray
        self.keyboardView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        self.doneButton.frame = CGRect(x: self.view.frame.width - 80, y: 0, width: 60, height: 60)
        self.keyboardView.addSubview(self.doneButton)
        self.doneButton.addTarget(self, action: #selector(self.donePressed), for: .touchUpInside)
        
        self.solTextField.delegate = self
        self.solTextField.backgroundColor = .white
        self.solTextField.inputAccessoryView = self.keyboardView
        self.solTextField.layer.cornerRadius = 10
        self.solTextField.font = UIFont.systemFont(ofSize: 18)
        self.solTextField.text = "1"
        self.solTextField.textAlignment = .center
        self.solTextField.keyboardType = .numberPad
        self.solTextField.frame = CGRect(x: 100, y: 45, width: self.view.frame.width - 200, height: 40)
        self.headerView.addSubview(self.solTextField)
        
        self.marsRoverLabel.textAlignment = .center
        self.marsRoverLabel.text = "Mars Rover Sol"
        self.marsRoverLabel.frame = CGRect(x: 0, y: 95, width: self.view.frame.width, height: 12)
        self.headerView.addSubview(self.marsRoverLabel)
        
        self.imageTable.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: self.view.frame.height - 120)
        self.view.addSubview(self.imageTable)

        self.imageTable.dataSource = self
        self.imageTable.delegate = self
        self.imageTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.backgroundView.addGestureRecognizer(backgroundTap)
        self.backgroundView.backgroundColor = .black
        self.backgroundView.layer.opacity = 0.0
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.backgroundView)

        self.backgroundView.addSubview(self.imageView)

        let textViewTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.textView.addGestureRecognizer(textViewTap)
        self.textView.isEditable = false
        self.textView.frame = CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: 100)
        self.backgroundView.addSubview(self.textView)
        
        self.noneFoundBackgroundView.layer.opacity = 0.0
        self.noneFoundBackgroundView.backgroundColor = .black
        self.noneFoundBackgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.noneFoundBackgroundView)
        self.noneFoundView.backgroundColor = .white
        self.noneFoundView.frame.size = CGSize(width: self.view.frame.width - 20, height: 80)
        self.noneFoundView.center = self.noneFoundBackgroundView.center
        self.noneFoundView.layer.cornerRadius = 10
        self.noneFoundView.layer.opacity = 0.0
        self.view.addSubview(self.noneFoundView)
        self.noneFoundLabel.textAlignment = .center
        self.noneFoundLabel.text = "No images"
        self.noneFoundLabel.textColor = .black
        self.noneFoundLabel.frame = CGRect(x: 0, y: 10, width: self.noneFoundView.frame.width, height: 40)
        self.noneFoundView.addSubview(self.noneFoundLabel)
        self.noneFoundOkButton.setTitleColor(.black, for: .normal)
        self.noneFoundOkButton.setTitle("OK", for: .normal)
        self.noneFoundOkButton.addTarget(self, action: #selector(self.okPressed), for: .touchUpInside)
        self.noneFoundOkButton.frame = CGRect(x: 0, y: 40, width: self.noneFoundView.frame.width, height: 40)
        self.noneFoundView.addSubview(self.noneFoundOkButton)
        
        self.begin()
        
    }
    
    @objc func handleTap() {
        self.backgroundView.layer.opacity = 0.0
    }
    
    @objc func donePressed() {
        
        self.solTextField.resignFirstResponder()
        self.solTextField.endEditing(true)
        
        self.photoRowDataList.removeAll()
        self.imageTable.reloadData()
        
        if let sol = Int(self.solTextField.text ?? "1") {
            
            if sol > 0 {
                self.parsePhotos(sol: sol)
            }
            else {
                self.showNoImages(sol: 0)
            }
            
        }
        
    }
    
    @objc func okPressed() {
        
        self.noneFoundBackgroundView.layer.opacity = 0.0
        self.noneFoundView.layer.opacity = 0.0
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let text = textField.text {
            
            self.previousSol = text
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            
        }
        
    }
    
    func begin() {
        self.parsePhotos(sol: 1)
    }
    
    func showNoImages(sol: Int) {
        
        self.noneFoundLabel.text = "No images for Sol \(sol)"
        self.noneFoundBackgroundView.layer.opacity = 0.75
        self.noneFoundView.layer.opacity = 1.0
        
    }
    
    func parsePhotos(sol: Int) {
        
        if let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=\(sol)&api_key=nujVIFrr9L96fhWX8XhZgjWnRSvXiq5jh5nljKZy") {
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                guard let data = data else { return }
                
                do {
                    
                    let mars = try JSONDecoder().decode(Mars.self, from: data)
                    
                    if mars.photos.count == 0 {
                        
                        DispatchQueue.main.async() {
                            
                            self.showNoImages(sol: sol)
                            
                        }
                        
                    }
                    
                    for photo in mars.photos {
                        
                        if let url = URL(string: photo.img_src) {
                            
                            self.getData(from: url) { data, response, error in
                                
                                guard let data = data, error == nil else { return }
                                
                                DispatchQueue.main.async() {
                                    
                                    if let image = UIImage(data: data) {
                                        
                                        let text = "\(photo.img_src)\nDate: \(photo.earth_date)\n\(photo.rover.name)"

                                        let photoView = PhotoRowData(name: photo.img_src, image: image, text: text)
                                        
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

