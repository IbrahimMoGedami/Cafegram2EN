//
//  CafeTableViewController.swift
//  Cafegram2EN
//
//  Created by Ibrahim Mo Gedami on 16/05/2020.
//  Copyright © 2020 Ibrahim Mo Gedami. All rights reserved
//

import UIKit
import CoreData
import UserNotifications



class CafeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    var searchController: UISearchController!
    
    var searchResults: [CafeMO] = []
    
    var fetchResultController: NSFetchedResultsController<CafeMO>!
    
    @IBOutlet var emptyCafeView: UIView!
    
    var cafes: [CafeMO] = []

    // MARK:- View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Customize the navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            // For Xcode 9 users, NSAttributedString.Key is equal to NSAttributedStringKey
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 153.0/255.0, alpha: 1), NSAttributedString.Key.font: customFont]
        }
        
        navigationController?.hidesBarsOnSwipe = true
        
        // Prepare the empty view
        tableView.backgroundView = emptyCafeView
        tableView.backgroundView?.isHidden = true
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<CafeMO> = CafeMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    cafes = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
        
        // Search bar methods
        searchController = UISearchController(searchResultsController: nil)
//        self.navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // Customization of the search bar
        searchController.searchBar.placeholder = "Search cafes..."
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(red: 231, green: 76, blue: 60)
        
        // Peek and Pop
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        // Notifications
        prepareNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if cafes.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return searchResults.count
        } else {
            return cafes.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CafeTableViewCell
        
        // Determine if we get the cafe from search result or the original array
        let cafe = (searchController.isActive) ? searchResults[indexPath.row] : cafes[indexPath.row]

        // Configure the cell...
        cell.nameLabel.text = cafe.name
        cell.locationLabel.text = cafe.location
        cell.typeLabel.text = cafe.type
        
        if let cafeImage = cafe.image {
            cell.thumbnailImageView.image = UIImage(data: cafeImage as Data)
        }
        
        cell.accessoryType = cafe.isVisited ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    // MARK:- Table View Delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
        
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            // Delete the row from the data source
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let cafeToDelete = self.fetchResultController.object(at: indexPath)
                
                context.delete(cafeToDelete)
                
                appDelegate.saveContext()
            }
            
            // Call completion handler to dismiss the action button
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at " + self.cafes[indexPath.row].name!
            
            let activityController: UIActivityViewController
            
            if let cafeImage = self.cafes[indexPath.row].image, let imageToShare = UIImage(data: cafeImage as Data) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            self.present(activityController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        deleteAction.image = UIImage(named: "delete")
        
        shareAction.backgroundColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        shareAction.image = UIImage(named: "share")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkInAction = UIContextualAction(style: .normal, title: "Check-in") { (action, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! CafeTableViewCell
            self.cafes[indexPath.row].isVisited = (self.cafes[indexPath.row].isVisited) ? false : true
            cell.accessoryType = (self.cafes[indexPath.row].isVisited) ? .checkmark : .none
            
            completionHandler(true)
        }
        
        // Customize the action button
        checkInAction.backgroundColor = UIColor(red: 39, green: 174, blue: 96)
        
        checkInAction.image = self.cafes[indexPath.row].isVisited ? UIImage(named: "undo") : UIImage(named: "tick")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCafeDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! CafeDetailViewController
                destinationController.cafe = (searchController.isActive) ? searchResults[indexPath.row] : cafes[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }

    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Fetch requests methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            cafes = fetchedObjects as! [CafeMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //MARK: - SearchBar methods

    func filterContent(for SearchText: String) {
        searchResults = cafes.filter({ (cafe) -> Bool in
            if let name = cafe.name {
                let isMatch = name.localizedCaseInsensitiveContains(SearchText)
                return isMatch
            }
            
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}

extension CafeTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        guard let cafeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "CafeDetailViewController") as? CafeDetailViewController else { return nil }
        
        let selectedCafe = cafes[indexPath.row]
        cafeDetailViewController.cafe = selectedCafe
        cafeDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 460.0)
        
        previewingContext.sourceRect = cell.frame
        
        return cafeDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: - Notifications
    
    func prepareNotification() {
        // Make sure the cafe array is not empty
        if cafes.count <= 0 {
            return
        }
        
        // Pick a cafe randomly
        let randomNum = Int(arc4random_uniform(UInt32(cafes.count)))
        let suggestedCafe = cafes[randomNum]
        
        // Create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Cafe Recommendation"
        content.subtitle = "Try a new cafe today"
        content.body = "I recommend you to check out \(suggestedCafe.name!). The cafe is one of my favorites. It's located at \(suggestedCafe.location!). Would you like to give it a try?"
        // For Swift 4 users, it's UNNotificationSound.default()
        content.sound = UNNotificationSound.default
        content.userInfo = ["phone": suggestedCafe.phone!]
        
        // Attachments
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-cafe.jpg")
        
        if let image = UIImage(data: suggestedCafe.image! as Data) {
            
            // For Swift 4 users, it's UIImageJPEGRepresentation(image, 1.0)?.write(to: tempFileURL)
            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let cafeImage = try? UNNotificationAttachment(identifier: "cafeImage", url: tempFileURL, options: nil) {
                content.attachments = [cafeImage]
            }
        }
        
        // User Notifications Custom Actions
        let categoryIdentifier = "cafegram.cafeAction"
        let makeReservationAction = UNNotificationAction(identifier: "cafegram.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "cafegram.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.categoryIdentifier = categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "cafegram.cafeSuggestion", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
