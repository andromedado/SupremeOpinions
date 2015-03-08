//
//  Extractor.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation

class Extractor
{
    class var opts : NSRegularExpressionOptions {
        get {
            return NSRegularExpressionOptions(NSRegularExpressionOptions.CaseInsensitive.rawValue | NSRegularExpressionOptions.DotMatchesLineSeparators.rawValue)
        }
    }

    class func extract(html:String) -> [Opinion] {
        var tables = self.extractMatcingPair(html, tagname: "table")
        for table in tables {
            var rows = self.extractMatcingPair(table, tagname: "tr")
            for row in rows {
                var cells = self.extractMatcingPair(row, tagname: "td")
                if (cells.count != 6) {
                    continue;
                }
                for cell in cells {
                    println(cell)
                }
            }
        }
        return []
    }

    class func extractMatcingPair(html:String, tagname:String) -> [String] {
        var pointer = NSErrorPointer()
        let strAsNSString = html as NSString
        let pattern = "<\(tagname)[^>]*>.*?\(tagname)>"
        var regex = NSRegularExpression(pattern: pattern, options: Extractor.opts, error: pointer)
        var range = NSMakeRange(0, strAsNSString.length)
        var pairs : [String] = []
        regex?.enumerateMatchesInString(html, options: nil, range: range, usingBlock: { (result, flags, stop) -> Void in
            let pair = strAsNSString.substringWithRange(result.range)
            pairs.append(pair)
        })
        return pairs
    }

}
