//
//  ConversationBottomBarView.swift
//  EmoChat
//
//  Created by Admin on 29.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

@IBDesignable class ConversationBottomBarView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var attachFileButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var attachPhotoButton: UIButton!
    @IBOutlet weak var geolocationButton: UIButton!

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    // Performs the initial setup.
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        // Show the view.
        addSubview(view)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }

}
