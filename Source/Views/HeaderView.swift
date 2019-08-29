import UIKit

protocol HeaderViewDelegate: class {
  func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

open class HeaderView: UIView {
  open fileprivate(set) lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.CloseButton.text,
      attributes: LightboxConfig.CloseButton.textAttributes)

    let button = UIButton(type: .system)

    button.setAttributedTitle(title, for: UIControl.State())

    if let size = LightboxConfig.CloseButton.size {
      button.frame.size = size
    } else {
      button.sizeToFit()
    }

    button.addTarget(self, action: #selector(closeButtonDidPress(_:)),
      for: .touchUpInside)

    if let image = LightboxConfig.CloseButton.image {
        button.setBackgroundImage(image, for: UIControl.State())
    }

    button.isHidden = !LightboxConfig.CloseButton.enabled

    return button
  }()

    open var pageIndicator: UIView? {
        didSet {
            if let pi = pageIndicator {
                pi.isHidden = true
                addSubview(pi)
            }
        }
    }

  weak var delegate: HeaderViewDelegate?

  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor.clear

    addSubview(closeButton)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions
    
  @objc func closeButtonDidPress(_ button: UIButton) {
    delegate?.headerView(self, didPressCloseButton: button)
  }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

  @objc public func configureLayout() {
    let topPadding: CGFloat

    if #available(iOS 11, *) {
      topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    } else {
      topPadding = 0
    }

    closeButton.frame.origin = CGPoint(
      x: bounds.width - closeButton.frame.width - 17,
      y: topPadding
    )

    pageIndicator?.frame.origin = CGPoint(
      x: 17,
      y: topPadding
    )
    pageIndicator?.isHidden = !LightboxConfig.PageIndicator.enabled
  }
}
