import UIKit
import TKUIKit

final class SwapSearchTokenOtherCell: TKCollectionViewContainerCell<SwapSearchTokenOtherCellContentView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Background.content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SwapSearchTokenOtherCellContentView: UIView, ConfigurableView, TKCollectionViewCellContentView, ReusableView {
    var padding: UIEdgeInsets { .init(top: 16, left: 16, bottom: 16, right: 16) }
    
    let iconView = TKListItemIconImageView()
    let contentView = TKListItemContentView()
    
    lazy var layout = TKListItemLayout(iconView: iconView, contentView: contentView, valueView: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.layouSubviews(bounds: bounds)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout.calculateSize(targetSize: size)
    }
    
    struct Model {
        let iconModel: TKListItemIconImageView.Model
        let contentModel: TKListItemContentView.Model
        let action: (() -> Void)?
        
        init(
            iconModel: TKListItemIconImageView.Model,
            contentModel: TKListItemContentView.Model,
            action: (() -> Void)? = nil
        ) {
            self.iconModel = iconModel
            self.contentModel = contentModel
            self.action = action
        }
    }
    
    func configure(model: Model) {
        iconView.configure(model: model.iconModel)
        contentView.configure(model: model.contentModel)
    }
}

private extension SwapSearchTokenOtherCellContentView {
    func setup() {
        addSubview(iconView)
        addSubview(contentView)
    }
}
