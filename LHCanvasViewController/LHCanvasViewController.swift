//
//  LHCanvasViewController.swift
//  Testing
//
//  Created by 許立衡 on 2018/10/26.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

public protocol LHCanvasViewControllerDelegate: AnyObject {
    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage)
    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController)
}

open class LHCanvasViewController: UIViewController {
    
    enum StrokeType {
        case pen, eraser
    }
    private var strokeType: StrokeType = .pen {
        didSet {
            penButton.isEnabled = strokeType != .pen
            eraserButton.isEnabled = strokeType != .eraser
        }
    }

    @IBOutlet private weak var penButton: UIBarButtonItem!
    @IBOutlet private weak var eraserButton: UIBarButtonItem!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var canvasView: LHCanvasView!
    @IBOutlet private weak var redoButton: UIBarButtonItem!
    @IBOutlet private weak var undoButton: UIBarButtonItem!
    
    weak open var delegate: LHCanvasViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: Bundle.init(for: LHCanvasViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        canvasView.delegate = self
        strokeType = .pen
        updateButtons()
    }
    
    @IBAction private func didPressUndoButton(_ sender: Any) {
        canvasView.undoManager.undo()
    }
    
    @IBAction private func didPressRedoButton(_ sender: Any) {
        canvasView.undoManager.redo()
    }
    
    @IBAction private func didPressPenButton(_ sender: Any) {
        strokeType = .pen
    }
    
    @IBAction private func didPressEraserButton(_ sender: Any) {
        strokeType = .eraser
    }
    
    @IBAction private func didPressCancelButton(_ sender: Any) {
        delegate?.canvasViewControllerDidCancel(self)
    }
    
    @IBAction private func didPressSaveButton(_ sender: Any) {
        guard let image = canvasView.image else { return }
        delegate?.canvasViewController(self, didSave: image)
    }
    
}

extension LHCanvasViewController: LHCanvasViewDelegate {
    
    public func lineConfigurator(for canvasView: LHCanvasView) -> LHCanvasView.LineConfigurationHandler? {
        switch strokeType {
        case .pen:
            return {
                $0.setStrokeColor(.black)
            }
        case .eraser:
            return {
                $0.setStrokeColor(.white)
                $0.setLineWidth(20)
            }
        }
    }
    
    private func updateButtons() {
        saveButton.isEnabled = canvasView.undoManager.canUndo
        undoButton.isEnabled = canvasView.undoManager.canUndo
        redoButton.isEnabled = canvasView.undoManager.canRedo
    }
    
    public func canvasViewDidChange(_ canvasView: LHCanvasView) {
        updateButtons()
    }
    
}