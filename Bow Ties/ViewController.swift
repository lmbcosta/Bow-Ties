/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  // MARK: - Properties
  var managedContext: NSManagedObjectContext!
  var currentBowtie: Bowtie!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Ensures that I have data to fetch
    self.insertSampleData()
    // Fetch data
    let fetchRequest: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    let firstTitle = self.segmentedControl.titleForSegment(at: 0)!
    //fetchRequest.predicate = NSPredicate(format: "%K = %@", [#keyPath(Bowtie.searchKey), firstTitle])
    fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), firstTitle])
    
    do {
      let results = try managedContext.fetch(fetchRequest)
      self.currentBowtie = results.first
      populate(bowtie: results.first!)
    } catch let error as NSError{
      print("Could not fetch \(error), \(error.description)")
    }
  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: Any) {

  }

  @IBAction func wear(_ sender: Any) {
    // Update bowtie details
    currentBowtie.lastWorn = NSDate()
    let times = currentBowtie.timesWorn
    currentBowtie.timesWorn = times + 1
    
    // Save changes
    do {
      try self.managedContext.save()
      // Get managedObject with changes
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      print("Could not fetch \(error): \(error.description)")
    }
  }
  
  @IBAction func rate(_ sender: Any) {
    // Compose an Alert
    let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
    // Add Texfield to the alert
    alert.addTextField { textField in
      textField.keyboardType = .decimalPad
    }
    
    // Actions
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
      guard let text = alert.textFields?.first?.text else {return}
      self?.update(rating: text)
    }
    
    alert.addAction(cancelAction)
    alert.addAction(saveAction)
    self.present(alert, animated: true)
  }
  
  // MARK: - Private functions
  fileprivate func populate(bowtie: Bowtie) {
    // Get bowtie properties
    guard let imageData = bowtie.photoData as Data?, let lastWorn = bowtie.lastWorn as Date?, let tintColor = bowtie.tintColor as? UIColor else {return}
    self.imageView.image = UIImage(data: imageData)
    self.nameLabel.text = bowtie.name
    self.ratingLabel.text = "Rating: \(bowtie.rating)/5"
    self.timesWornLabel.text = "# of times worn: \(bowtie.timesWorn)"
    
    // Date
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    self.lastWornLabel.text = "Last worn: " + dateFormatter.string(for: lastWorn)!
    self.favoriteLabel.isHidden = !bowtie.isFavourite
    self.view.tintColor = tintColor
  }
  
  
  
  fileprivate func insertSampleData() {
    let fetch: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    
    let count = try! managedContext.count(for: fetch)
    
    if count > 0 {
      // Sample data already in Core Data
      return
    }
    
    // Get plist resource
    guard let path = Bundle.main.path(forResource: "SampleData", ofType: "plist"), let dataArray = NSArray(contentsOfFile: path) else {return}
    
    for dict in dataArray {
      // NSEntityDescription
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!
      // Managed Object Bowtie
      let bowtie =  Bowtie(entity: entity, insertInto: managedContext)
      // Accessing plist properties for each bowtie
      if let bowtieDict = dict as? [String: Any] {
        // Fill bowtie attributes
        bowtie.id = UUID(uuidString: bowtieDict["id"] as! String)
        bowtie.isFavourite = bowtieDict["isFavorite"] as! Bool
        bowtie.lastWorn = bowtieDict["lastWorn"] as? NSDate
        bowtie.name = bowtieDict["name"] as? String
        // photoimage
        let image = UIImage(named: bowtieDict["imageName"] as! String)
        let photoData = UIImagePNGRepresentation(image!)!
        bowtie.photoData = photoData as NSData
        bowtie.rating = bowtieDict["rating"] as! Double
        bowtie.searchKey = bowtieDict["searchKey"] as? String
        // times worn
        let timesWorn = bowtieDict["timesWorn"] as! NSNumber
        bowtie.timesWorn = timesWorn.int32Value
        bowtie.url = URL(string: bowtieDict["url"] as! String)
        // Compose color
        let colorDict = bowtieDict["tintColor"] as! [String: Any]
        if let color = UIColor.color(dict: colorDict) {
          bowtie.tintColor = color
        }
      }
      do {
        try managedContext.save()
        print("Dummies save on CoreData")
      } catch {
        print("Dummies were not commited in CoreData")
      }
    }
  }
  
  fileprivate func update(rating: String?) {
    guard let ratingString = rating, let rating = Double(ratingString) else {return}
    self.currentBowtie.rating = rating
    
    do {
      try managedContext.save()
      // Show changes
      self.populate(bowtie: currentBowtie)
    } catch let error as NSError {
      if error.domain == "NSCocoaErrorDomain" && (error.code == NSValidationNumberTooSmallError || error.code == NSValidationNumberTooLargeError) {
        rate(currentBowtie)
      } else {
        print("Error: \(error.debugDescription)")
      }
    }
  }
  
}














