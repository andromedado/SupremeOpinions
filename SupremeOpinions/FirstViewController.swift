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
    var available : [(String, String)]?
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
    }

    func reloadAvailable() -> () {
        if ((self.reloading) != nil && self.reloading!) {
            return
        }
        self.button.enabled = false
        println("RELOAD")
        self.reloading = true
        Fetcher.instance().fetchPairs { (pairs) -> () in
            self.available = pairs
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.reloading = false
                self.button.enabled = true
                self.tableView.reloadSection(FirstSection.Available)
            })
        }
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            if let href = self.available?[indexPath.row].0 {
                if (!contains(self.fetching, href)) {
                    self.fetching.append(href)
                    var cell = tableView.cellForRowAtIndexPath(indexPath)
                    cell?.accessoryType = .DetailButton
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            if let pair = self.available?[indexPath.row] {
                cell.textLabel?.text = pair.1
                var accessory : UITableViewCellAccessoryType = .None
                if (contains(self.fetching, pair.0)) {
                    accessory = .DetailButton
                }
                cell.accessoryType = accessory
            }
        }

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = FirstSection(rawValue: section) {
            switch(section) {
            case .Reload:
                return 1
            case .Available:
                return self.available?.count ?? 0
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

