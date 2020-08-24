//
//  ViewController.swift
//  OperationQueueExample
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let operationQueue = OperationQueue()
    private let dispatchGroup = DispatchGroup()
    private var beerList: [JSON.Beer] = []
    private var images = [String : UIImage]()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        loadData()
    }

    private func loadData() {
        
        let operation = BeersFetchOperation(endpointPath: "beers")
        
        operation.completionBlock = {
            guard let beersJson = try? operation.result?.get() else {
                return
            }
            self.loadImages(for: beersJson)
            
            self.dispatchGroup.notify(queue: DispatchQueue.main) {
                self.beerList = beersJson
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    private func loadImages(for beers: [JSON.Beer]) {
        beers.forEach { beer in
            DispatchQueue.global().async {
                self.dispatchGroup.enter()
                
                guard let imagePath = beer.imageUrl, let url = URL(string: imagePath),
                    let data = try? Data(contentsOf: url) else {
                        self.dispatchGroup.leave()
                        return
                }
                
                DispatchQueue.main.async {
                    self.images[imagePath] = UIImage(data: data)
                    self.dispatchGroup.leave()
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        beerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerCell", for: indexPath)
        let beer = beerList[indexPath.row]
        cell.textLabel?.text = beer.name
        cell.detailTextLabel?.text = beer.description
        if let imagePath = beer.imageUrl {
            cell.imageView?.image = images[imagePath]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
}
