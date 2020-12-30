//
//  ShareController.swift
//  DinoPrez
//
//  Created by Erik Iversen on 5/14/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import Foundation
import SpriteKit
import LinkPresentation

class ShareController: NSObject, UIActivityItemSource {
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        if let image = UIImage(named: "AppIcon") {
            let imageProvider = NSItemProvider(object: image)
            metadata.imageProvider = imageProvider
            metadata.title = "Check out my score on PrezHopper!"
        }
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
}
