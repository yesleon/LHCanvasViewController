//
//  MessagesViewController.swift
//  Canvas
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet private weak var containerView: UIView!
    
    private lazy var canvasVC = LHCanvasViewController(image: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.autoresizesSubviews = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !children.contains(canvasVC) {
            addChild(canvasVC)
            canvasVC.view.frame = containerView.bounds
            canvasVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            canvasVC.delegate = self
            containerView.addSubview(canvasVC.view)
            canvasVC.didMove(toParent: self)
        }
    }

}

extension MessagesViewController: LHCanvasViewControllerDelegate {
    
    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage) {
        if let conversation = activeConversation {
            do {
                let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                try image.jpegData(compressionQuality: 0.9)?.write(to: imageURL)
                conversation.sendAttachment(imageURL, withAlternateFilename: nil) { error in
                    if let error = error {
                        print(error)
                    }
                    do { try FileManager.default.removeItem(at: imageURL) } catch { print(error) }
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController) {
        dismiss()
    }
    
}
