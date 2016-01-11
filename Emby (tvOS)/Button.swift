//
//  Button.swift
//  Emby
//
//  Created by Aaron Alexander on 11/5/15.
//
//

import UIKit

class Button: UIButton {
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        coordinator.addCoordinatedAnimations({ [unowned self] in
            
            if self.focused {
                self.backgroundColor = UIColor.blueColor();
            } else {
                self.backgroundColor = UIColor.redColor();
            }
            
        }, completion: nil)
    }
    
}
