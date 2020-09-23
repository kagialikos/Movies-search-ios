//
//  loadingCell.swift
//  Movie search
//
//  Created by kagialikos on 2/9/20.
//  Copyright © 2020 kagialikos. All rights reserved.
//

import UIKit

class loadingCell: UITableViewCell {

    @IBOutlet var indicator: UIActivityIndicatorView!

      override func layoutSubviews() {
         super.layoutSubviews()
         indicator.startAnimating()
     }

    
}
