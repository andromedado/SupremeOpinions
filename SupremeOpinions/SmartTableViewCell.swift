//
//  SmartTableViewCell.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/14/15.
//
//

import Foundation
import UIKit

extension UITableViewCell {

    class func registerWithTableView(tableView:UITableView) {
        println(NSStringFromClass(self.classForCoder()))
        tableView.registerNib(UINib(nibName: NSStringFromClass(self.classForCoder()), bundle: nil), forCellReuseIdentifier: NSStringFromClass(self.classForCoder()));
    }

    class func dequeueFromTableView(tableView:UITableView) -> UITableViewCell? {
        return tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(self.classForCoder())) as? UITableViewCell;
    }

}
