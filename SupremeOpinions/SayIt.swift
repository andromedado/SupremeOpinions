//
//  SayIt.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation
import UIKit

class SayIt {

    class func sayIt(#view:UIView) -> () {
        sayIt(view: view, indent: "")
    }

    private class func sayIt(#view: UIView, indent:String) -> () {
        println("\(indent)\(view)")
        for sub in view.subviews {
            if let subView = sub as? UIView {
                sayIt(view: subView, indent: indent + "-")
            }
        }
    }

}

