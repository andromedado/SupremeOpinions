//
//  ReloadTableViewCell.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/14/15.
//
//

import UIKit

protocol ReloadTableViewCellDelegate: class {
    func buttonTap(cell:ReloadTableViewCell);
}

class ReloadTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!

    weak var delegate : protocol<ReloadTableViewCellDelegate>?

    @IBAction func buttonTap(sender: AnyObject) {
        delegate?.buttonTap(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
