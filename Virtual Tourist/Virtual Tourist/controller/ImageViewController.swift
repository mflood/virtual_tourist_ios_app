//
//  ImageViewController.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 6/4/23.
//

import Foundation
import UIKit


class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: image)
               imageView.contentMode = .scaleAspectFit
               imageView.frame = self.view.bounds
               imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               self.view.addSubview(imageView)
        
        
        
        // Create a UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        
        // Add it to the view
        self.view.addGestureRecognizer(tapGesture)

        
    }
 
    @objc func didTapView() {
        print("View was tapped!!!")
        dismiss(animated: true)
        
        // dismiss(animated: true, completion: nil)
    }
}
