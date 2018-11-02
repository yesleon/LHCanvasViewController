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
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        switch navigationBar.barStyle {
        case .default:
            return .default
        case .black, .blackTranslucent:
            return .lightContent
        }
    }
    
    private lazy var brush = LHBrush()
    private var strokeColor: UIColor {
        get {
            return brush.configuration.strokeColor
        }
        set {
            brush.configuration.strokeColor = newValue
        }
    }
    private var strokeWidth: CGFloat {
        get {
            return brush.configuration.lineWidth
        }
        set {
            brush.configuration.lineWidth = newValue
        }
    }

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
        brush.canvas = canvasView
        updateButtons()
        navigationBar.delegate = self
        toolBar.delegate = self
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.clipsToBounds = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async(execute: setNeedsStatusBarAppearanceUpdate)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction private func didPressUndoButton(_ sender: UIBarButtonItem) {
        presentUndoMenu(undoManager: canvasView.undoManager, popoverSource: .barButtonItem(sender))
    }
    
    private func makePenPanelViewController(popoverSource: LHPopoverSource) -> UIViewController {
        let penPanelVC = LHPopoverViewController(popoverSource: popoverSource)
        
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
        
        return penPanelVC
    }
    
    @IBAction private func didPressPenButton(_ sender: UIBarButtonItem) {
        let panelVC = makePenPanelViewController(popoverSource: .barButtonItem(sender))
        
        presentedViewController?.dismiss(animated: false, completion: nil)
        present(panelVC, animated: true, completion: nil)
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
