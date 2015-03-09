//
//  SecondViewController.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import UIKit

class SecondViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        self.webView.scrollView.delegate = self
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

//    func webViewDidFinishLoad(webView: UIWebView) {
//        SayIt.sayIt(view: webView)
//        if let pdfView = webView.scrollView.subviews[0] as? UIWebPDFView {
//            pdfView.initialZoomScale = 1.7
//            pdfView.zoom(pdfView, to: CGRectMake(119, 0, 320, 500), atPoint: CGPointZero, kind: 0)
//        }
//        webView.scrollView.zoomToRect(CGRectMake(119, 0, 320, 500), animated: true)
//        webView.scrollView.setZoomScale(1.75, animated: false)
//        webView.scrollView.scrollRectToVisible(CGRectMake(119, 0, 320, 500), animated: false)
//    }

    //Ended Scrolling at scale: 1.9037961546903
//    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
//        println("Ended Scrolling at scale: \(scale)")
//    }

    //DidScroll to (153.0,164.0,320.0,499.0)
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        println("DidScroll to \(scrollView.bounds)")
//    }

}

