//
//  SecondViewController.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func presentOpinion(opinion:Opinion) -> () {
        if (opinion.downloaded) {
            let url = NSURL(fileURLWithPath: opinion.filePath)!
            self.webView.loadRequest(NSURLRequest(URL: url));
        }
    }

}

