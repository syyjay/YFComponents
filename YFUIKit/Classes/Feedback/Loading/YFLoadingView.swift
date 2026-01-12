//
//  YFLoadingView.swift
//  YFUIKit
//
//  Loading 视图
//

import UIKit
import SnapKit

/// Loading 视图
class YFLoadingView: UIView {
    
    // MARK: - Properties
    
    private var config: YFLoadingConfig
    private var theme: YFTheme { YFThemeManager.shared.theme }
    
    // MARK: - UI
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.surface)
        view.layer.cornerRadius = config.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.15
        return view
    }()
    
    private lazy var contentStack = YFStackView.vertical(spacing: 12, alignment: .center)
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .themed(\.primary)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var iconView = YFImageView()
    private lazy var progressView = YFProgressView()
    private lazy var textLabel = YFLabel().font(.systemFont(ofSize: 14)).align(.center).lines(0)
    
    // MARK: - Init
    
    init(config: YFLoadingConfig) {
        self.config = config
        super.init(frame: .zero)
        setupUI()
        configure(with: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = config.maskType.color
        isUserInteractionEnabled = !config.maskType.isUserInteractionEnabled
        
        addSubview(containerView)
        containerView.addSubview(contentStack)
        
        contentStack.addViews(activityIndicator, iconView, progressView, textLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(config.minimumSize.width)
            make.width.lessThanOrEqualTo(250)
        }
        
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        let size = config.indicatorSize
        [activityIndicator, iconView, progressView].forEach {
            $0.snp.makeConstraints { make in make.size.equalTo(size) }
        }
        
        // 初始隐藏
        iconView.isHidden = true
        progressView.isHidden = true
        textLabel.isHidden = true
    }
    
    // MARK: - Configure
    
    func configure(with config: YFLoadingConfig) {
        self.config = config
        backgroundColor = config.maskType.color
        isUserInteractionEnabled = !config.maskType.isUserInteractionEnabled
        
        // 文字
        textLabel.text = config.text
        textLabel.isHidden = config.text?.isEmpty ?? true
        
        // 状态
        switch config.status {
        case .loading:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            iconView.isHidden = true
            progressView.isHidden = true
            
        case .success, .error, .warning:
            activityIndicator.stopAnimating()
            iconView.isHidden = false
            iconView.image = config.status.icon
            iconView.tintColor = config.status.iconColor
            progressView.isHidden = true
            animateIcon()
            
        case .progress(let value):
            activityIndicator.stopAnimating()
            iconView.isHidden = true
            progressView.isHidden = false
            progressView.setProgress(value)
        }
    }
    
    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress)
    }
    
    // MARK: - Animation
    
    private func animateIcon() {
        iconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.iconView.transform = .identity
        }
    }
    
    func showAnimation(completion: (() -> Void)? = nil) {
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        } completion: { _ in completion?() }
    }
    
    func hideAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.15) {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0
        } completion: { _ in completion?() }
    }
}
