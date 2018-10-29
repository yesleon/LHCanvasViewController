//
//  ViewController.swift
//  LHCanvasViewControllerExample
//
//  Created by 許立衡 on 2018/10/29.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction private func didTapImageView(_ sender: UITapGestureRecognizer) {
        let canvasVC = LHCanvasViewController(image: imageView.image)
        canvasVC.delegate = self
        present(canvasVC, animated: true, completion: nil)
    }
    
}

extension ViewController: LHCanvasViewControllerDelegate {
    
    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage) {
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

