//
//  FirstViewController.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import UIKit

enum FirstSection : Int, intValuable {
    case Reload
    case Available
    case NumSections
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!
    var button : UIButton!
    var available : [Opinion] = []
    var reloading : Bool?
    var fetching : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.button = UIButton()
        self.button.setTitle("Reload", forState: .Normal)
        self.button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
        self.button.addTarget(self, action: "reloadAvailable", forControlEvents: .TouchUpInside)
        let path = FileManager.instance().availableOpinionsCacheFile
        if let data = NSData(contentsOfFile: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            self.available = unarchiver.decodeObjectForKey("available") as Array
        }

    }

    func reloadAvailable() -> () {
        if ((self.reloading) != nil && self.reloading!) {
            return
        }
        self.button.enabled = false
        println("RELOAD")
        self.reloading = true
        Fetcher.instance().fetchAvailableOpinions { (opinions) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.available = opinions
                self.reloading = false
                self.button.enabled = true
                self.tableView.reloadSection(FirstSection.Available)
            })
            let nsOpinions = opinions as NSArray
            let path = FileManager.instance().availableOpinionsCacheFile
            let mutableData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: mutableData)
            archiver.encodeObject(opinions, forKey: "available")
            archiver.finishEncoding()
            let res = mutableData.writeToFile(path, atomically: true)
        }
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 0
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            if let opinion = self.opinion(forIndexPath: indexPath) {
                var alert = UIAlertView(title: opinion.name, message: opinion.summary, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }

    func opinion(forIndexPath indexPath:NSIndexPath) -> Opinion? {
        return self.available[indexPath.row]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let opinion = self.opinion(forIndexPath: indexPath) {
            if (opinion.docket == nil) {
                return
            }
            if (opinion.downloaded) {
                self.tabBarController?.selectedIndex = 1
                if let second = self.tabBarController?.viewControllers?[1] as? SecondViewController {
                    second.presentOpinion(opinion)
                }
                return
            }
            let docket = self.available[indexPath.row].docket!
            if (contains(self.fetching, docket)) {
                return//Already Fetching
            }
            self.fetching.append(docket)
            opinion.download({ (err) -> () in
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                self.updateCell(cell, atIndexPath: indexPath)
            }, nil)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let fullWidth = self.tableView.bounds.width
        if (indexPath.section == 0) {
            self.button?.frame = CGRect(x: 0, y: 0, width: fullWidth, height: cell.bounds.height)
            cell.addSubview(self.button)
            let xConstraint = NSLayoutConstraint(item: cell, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
            cell.addConstraint(xConstraint)
            let yConstraint = NSLayoutConstraint(item: cell, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
            cell.addConstraint(yConstraint)
        } else {
            self.updateCell(cell, atIndexPath: indexPath)
        }

        return cell
    }

    private func updateCell(cell:UITableViewCell?, atIndexPath indexPath: NSIndexPath) -> () {
        if (cell == nil) {
            return
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let certainCell = cell!
            if let opinion = self.opinion(forIndexPath: indexPath) {
                certainCell.textLabel?.text = opinion.name
                var accessoryType : UITableViewCellAccessoryType = .DetailButton
                if (opinion.downloaded) {
                    accessoryType = .DetailDisclosureButton
                }
                certainCell.accessoryType = accessoryType
            }
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = FirstSection(rawValue: section) {
            switch(section) {
            case .Reload:
                return 1
            case .Available:
                return self.available.count
            default:
                return 0
            }
        }
        return 0
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FirstSection.NumSections.rawValue
    }

}

