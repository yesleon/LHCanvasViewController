//
//  LHColorPickerView.swift
//  LHColorPickerController
//
//  Created by 許立衡 on 2018/10/30.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

@IBDesignable
public class LHColorPickerView: UIView {

    public typealias Handler = (UIColor) -> Void
    public var colors: [UIColor] = [#colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1), #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.2156862745, alpha: 1), #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.5450980392, blue: 0, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.7607843137, blue: 0, alpha: 1), #colorLiteral(red: 0.5960784314, green: 0.4784313725, blue: 0.3294117647, alpha: 1), .white, #colorLiteral(red: 0.6235294118, green: 0.2941176471, blue: 0.7882352941, alpha: 1), #colorLiteral(red: 0.5176470588, green: 0.5176470588, blue: 0.537254902, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)] {
        didSet {
            collectionView.reloadData()
        }
    }
    public var handler: Handler?
    private var preferredMaxLayoutWidth: CGFloat = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 44, height: 44)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    public override var intrinsicContentSize: CGSize {
        guard preferredMaxLayoutWidth > 0 else { return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) }
        let itemWidth: CGFloat = 44
        let horizontalItemCount = Int(ceil(Double(preferredMaxLayoutWidth) / Double(itemWidth)))
        let verticalItemCount = ceil(Double(colors.count) / Double(horizontalItemCount))
        return CGSize(width: preferredMaxLayoutWidth, height: itemWidth * CGFloat(verticalItemCount))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if preferredMaxLayoutWidth != bounds.width {
            preferredMaxLayoutWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }

    private func initialize() {
        addSubview(collectionView)
    }
    
    public convenience init(handler: @escaping Handler) {
        self.init(frame: .zero)
        self.handler = handler
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        collectionView.reloadData()
    }
    
}

extension LHColorPickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        cell.contentView.backgroundColor = colors[indexPath.item]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handler?(colors[indexPath.item])
    }

}
