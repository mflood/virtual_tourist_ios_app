//
//  FlickrImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/28/23.
//

import Foundation

import UIKit

class FlickrImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 // allow for multiline subtitles
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(subtitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViewSize = frame.size.width
        imageView.frame = CGRect(x: 0, y: 0, width: imageViewSize, height:imageViewSize)
        subtitleLabel.frame = CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height - imageView.frame.size.height)
    }
    
    func configure(with image: UIImage, subtitle: String) {
        imageView.image = image
        subtitleLabel.text = subtitle
    }
}
