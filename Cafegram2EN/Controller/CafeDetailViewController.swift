//
//  CafeDetailViewController.swift
//  Cafegram2EN
//
//  Created by Ibrahim Mo Gedami on 16/05/2020.
//  Copyright © 2020 Ibrahim Mo Gedami. All rights reserved
//

import UIKit

class CafeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: CafeDetailHeaderView!
    
    var cafe: CafeMO!
    
    // MARK:- View Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        // Configure the header view
        headerView.nameLabel.text = cafe.name
        headerView.typeLabel.text = cafe.type
        
        if let cafeImage = cafe.image {
            headerView.headerImageView.image = UIImage(data: cafeImage as Data)
        }
        
        // Configure the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Customization of the navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.hidesBarsOnSwipe = false
        
        tableView.contentInsetAdjustmentBehavior = .never
        
        if let rating = cafe.rating {
            headerView.ratingImageView.image = UIImage(named: rating)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CafeDetailIconTextCell.self), for: indexPath) as! CafeDetailIconTextCell
            cell.iconImageView.image = UIImage(named: "phone")
            cell.shortTextLabel.text = cafe.phone
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CafeDetailIconTextCell.self), for: indexPath) as! CafeDetailIconTextCell
            cell.iconImageView.image = UIImage(named: "map")
            cell.shortTextLabel.text = cafe.location
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CafeDetailTextCell.self), for: indexPath) as! CafeDetailTextCell
            cell.descriptionLabel.text = cafe.summary
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CafeDetailSeparatorCell.self), for: indexPath) as! CafeDetailSeparatorCell
            cell.titleLabel.text = "HOW TO GET HERE"
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CafeDetailMapCell.self), for: indexPath) as! CafeDetailMapCell
            
            if let cafeLocation = cafe.location {
                cell.configure(location: cafeLocation)
            }
            
            return cell
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
    
    // MARK:- Status Bar Customization
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.cafe = cafe
        }
        
        if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
            destinationController.cafe = cafe
        }
    }

    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateCafe(segue: UIStoryboardSegue) {
        dismiss(animated: true) {
            if let rating = segue.identifier {
                self.cafe.rating = rating
                self.headerView.ratingImageView.image = UIImage(named: rating)
            }
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            
            let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            self.headerView.ratingImageView.transform = scaleTransform
            self.headerView.ratingImageView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [], animations: {
                self.headerView.ratingImageView.transform = .identity
                self.headerView.ratingImageView.alpha = 1
            }, completion: nil)
        }
    }
    
}
