//
//  ViewController.swift
//  LHSketchKitExample
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHSketchKit

class ViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!

    @IBAction private func didTapImageView(_ sender: UITapGestureRecognizer) {
        let canvasVC = LHCanvasViewController()
        canvasVC.delegate = self
        present(canvasVC, animated: true, completion: nil)
    }
    
}

extension ViewController: LHCanvasViewControllerDelegate {
    
    func zoomTargetView(for canvasVC: LHCanvasViewController) -> UIView? {
        return nil
    }
    
    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage) {
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

