//
//  TableViewExtensions.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation
import UIKit

protocol intValuable {
    var rawValue : Int { get }
}

extension UITableView
{

    func reloadSection(intable:protocol<intValuable>) -> () {
        self.reloadSections(NSIndexSet(index: intable.rawValue), withRowAnimation: .Automatic)
    }

}
