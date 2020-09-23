//
//  SearchMovieCell.swift
//  Movie search
//
//  Created by kagialikos on 1/9/20.
//  Copyright © 2020 kagialikos. All rights reserved.
//

import UIKit

class SearchMovieCell: UITableViewCell {
    
    @IBOutlet var Date: UILabel!
    @IBOutlet var Title: UILabel!
    @IBOutlet var Poster: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2))
    }
}
