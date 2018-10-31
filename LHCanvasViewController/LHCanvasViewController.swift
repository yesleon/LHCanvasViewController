//
//  LHCanvasViewController.swift
//  Testing
//
//  Created by 許立衡 on 2018/10/26.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHPopoverKit

public protocol LHCanvasViewControllerDelegate: AnyObject {
    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage)
    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController)
}

open class LHCanvasViewController: UIViewController {
    
    private var strokeColor: UIColor = .black
    private var strokeWidth: CGFloat = 5

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var toolBar: UIToolbar!
    @IBOutlet private weak var penButton: UIBarButtonItem!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var canvasView: LHCanvasView!
    @IBOutlet private weak var undoButton: UIBarButtonItem!
    
    weak open var delegate: LHCanvasViewControllerDelegate?
    
    public init(image: UIImage?) {
        super.init(nibName: nil, bundle: Bundle.init(for: LHCanvasViewController.self))
        if let image = image {
            loadViewIfNeeded()
            canvasView.undoManager.disableUndoRegistration()
            canvasView.replaceImage(with: image)
            canvasView.undoManager.enableUndoRegistration()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        canvasView.delegate = self
        updateButtons()
        navigationBar.delegate = self
        toolBar.delegate = self
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.clipsToBounds = true
    }
    
    @IBAction private func didPressUndoButton(_ sender: UIBarButtonItem) {
        let undoMenu = LHMenu()
        undoMenu.addConstraint(.init(item: undoMenu, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 240))
        func updateActions(undoManager: UndoManager) {
            undoMenu.actions = [
                .init(title: undoManager.undoMenuItemTitle, isEnabled: undoManager.canUndo, handler: { action in
                    undoManager.undo()
                    updateActions(undoManager: undoManager)
                    return nil
                }),
                .init(title: undoManager.redoMenuItemTitle, isEnabled: undoManager.canRedo, handler: { action in
                    undoManager.redo()
                    updateActions(undoManager: undoManager)
                    return nil
                }),
            ]
        }
        updateActions(undoManager: canvasView.undoManager)
        let popoverVC = LHPopoverViewController(popoverSource: .barButtonItem(sender))
        popoverVC.addManagedView(undoMenu)
        present(popoverVC, animated: true, completion: nil)
    }
    
    @IBAction private func didPressPenButton(_ sender: UIBarButtonItem) {
        let penPanelVC = LHPopoverViewController(popoverSource: .barButtonItem(sender))
        
        let scale: CGFloat = {
            let imageSize = canvasView.image?.size ?? CGSize(width: 1920, height: 1080)
            return imageSize.width / canvasView.bounds.width
        }()
        
        let circleView: LHCircleView = {
            let circleView = LHCircleView()
            circleView.color = strokeColor
            circleView.circleSize = CGSize(width: strokeWidth / scale, height: strokeWidth / scale)
            circleView.addConstraint(.init(item: circleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
            return circleView
        }()
        penPanelVC.addManagedView(circleView)
        
        let colorPickerView = LHColorPickerView { color in
            self.strokeColor = color
            circleView.color = color
        }
        colorPickerView.addConstraint(.init(item: colorPickerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44 * 5))
        penPanelVC.addManagedView(colorPickerView)
        
        let slider: LHSlider = {
            let slider = LHSlider { slider in
                let value = CGFloat(slider.value)
                self.strokeWidth = value
                circleView.circleSize = CGSize(width: value / scale, height: value / scale)
            }
            slider.minimumValue = 1
            slider.maximumValue = 100
            slider.value = Float(strokeWidth)
            return slider
        }()
        penPanelVC.addManagedView(slider)
        
        presentedViewController?.dismiss(animated: false, completion: nil)
        present(penPanelVC, animated: true, completion: nil)
    }
    
    @IBAction private func didPressClearButton(_ sender: UIBarButtonItem) {
        canvasView.replaceImage(with: nil, actionName: NSLocalizedString("Clear Canvas", comment: ""))
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
    
    public func canvasView(_ canvasView: LHCanvasView, willStrokeWith configurator: LHLineConfigurating) {
        configurator.setStrokeColor(strokeColor)
        configurator.setLineWidth(strokeWidth)
    }
    
    private func updateButtons() {
        saveButton.isEnabled = canvasView.undoManager.canUndo
    }
    
    public func canvasViewDidChange(_ canvasView: LHCanvasView) {
        updateButtons()
    }
    
}

extension LHCanvasViewController: UINavigationBarDelegate, UIToolbarDelegate {
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        if bar === navigationBar {
            return .topAttached
        } else if bar === toolBar {
            return .bottom
        } else {
            return .any
        }
    }
    
}
