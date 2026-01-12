//
//  YFAlertController.swift
//  YFUIKit
//
//  自定义弹窗控制器
//

import UIKit
import SnapKit

open class YFAlertController: UIViewController {
    
    // MARK: - Properties
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    public private(set) var alertStyle: YFAlertStyle = .alert
    public var dismissOnBackgroundTap: Bool = true
    public var enableSwipeToDismiss: Bool = true
    public var cornerRadius: CGFloat = 16
    public var maxWidth: CGFloat = 280
    public var alertTitle: String?
    public var alertMessage: String?
    public internal(set) var actions: [YFAlertAction] = []
    public private(set) var textFieldConfigs: [YFAlertTextField] = []
    public private(set) var textFields: [YFTextField] = []
    public var customContentView: UIView?
    
    // MARK: - UI
    
    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.surface)
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.divider)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var contentStack = YFStackView.vertical(spacing: 16)
    private lazy var titleLabel = YFLabel().font(.systemFont(ofSize: 17, weight: .semibold)).align(.center).lines(0)
    private lazy var messageLabel = YFLabel().font(.systemFont(ofSize: 14)).color(.themed(\.textSecondary)).align(.center).lines(0)
    private lazy var textFieldStack = YFStackView.vertical(spacing: 12)
    private lazy var buttonStack = YFStackView.vertical(spacing: 12)
    
    // MARK: - Init
    
    public init(style: YFAlertStyle = .alert) {
        self.alertStyle = style
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFields.first?.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Transitioning Delegate

extension YFAlertController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YFAlertAnimator(style: alertStyle, isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YFAlertAnimator(style: alertStyle, isPresenting: false)
    }
}

// MARK: - Animator (简化版)

private class YFAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let style: YFAlertStyle
    let isPresenting: Bool
    
    init(style: YFAlertStyle, isPresenting: Bool) {
        self.style = style
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.35 : 0.25
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresent(context)
        } else {
            animateDismiss(context)
        }
    }
    
    private func animatePresent(_ context: UIViewControllerContextTransitioning) {
        guard let toVC = context.viewController(forKey: .to) as? YFAlertController else {
            context.completeTransition(false)
            return
        }
        
        let containerView = context.containerView
        containerView.addSubview(toVC.view)
        toVC.view.frame = containerView.bounds
        toVC.view.layoutIfNeeded()
        
        // 初始状态
        toVC.dimmingView.alpha = 0
        if style == .alert {
            toVC.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            toVC.containerView.alpha = 0
        } else {
            toVC.containerView.transform = CGAffineTransform(translationX: 0, y: toVC.containerView.bounds.height)
        }
        
        // 动画
        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: style == .alert ? 0.8 : 0.9,
            initialSpringVelocity: 0,
            options: .curveEaseOut
        ) {
            toVC.dimmingView.alpha = 1
            toVC.containerView.transform = .identity
            toVC.containerView.alpha = 1
        } completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func animateDismiss(_ context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) as? YFAlertController else {
            context.completeTransition(false)
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn) {
            fromVC.dimmingView.alpha = 0
            if self.style == .alert {
                fromVC.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                fromVC.containerView.alpha = 0
            } else {
                fromVC.containerView.transform = CGAffineTransform(translationX: 0, y: fromVC.containerView.bounds.height)
            }
        } completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}

// MARK: - Builder

public extension YFAlertController {
    @discardableResult func title(_ title: String?) -> Self { self.alertTitle = title; return self }
    @discardableResult func message(_ message: String?) -> Self { self.alertMessage = message; return self }
    @discardableResult func addAction(_ action: YFAlertAction) -> Self { actions.append(action); return self }
    @discardableResult func addTextField(_ config: YFAlertTextField = YFAlertTextField()) -> Self { textFieldConfigs.append(config); return self }
    @discardableResult func customContent(_ view: UIView) -> Self { self.customContentView = view; return self }
    @discardableResult func dismissable(_ value: Bool) -> Self { self.dismissOnBackgroundTap = value; return self }
    @discardableResult func swipeToDismiss(_ enabled: Bool) -> Self { self.enableSwipeToDismiss = enabled; return self }
}

// MARK: - Setup

private extension YFAlertController {
    
    func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(dimmingView)
        view.addSubview(containerView)
        containerView.addSubview(contentStack)
        
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        if dismissOnBackgroundTap {
            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
        }
        
        setupContainer()
        setupContent()
        setupSwipeGesture()
    }
    
    func setupContainer() {
        if alertStyle == .alert {
            containerView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(maxWidth)
                make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(20)
                make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
            }
            contentStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(20) }
        } else {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            containerView.snp.makeConstraints { $0.left.right.bottom.equalToSuperview() }
            
            if enableSwipeToDismiss {
                containerView.addSubview(dragIndicator)
                dragIndicator.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(8)
                    make.size.equalTo(CGSize(width: 36, height: 5))
                }
            }
            
            let bottomInset = max(safeAreaBottom, 16) + 16
            let topInset: CGFloat = enableSwipeToDismiss ? 24 : 20
            contentStack.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(topInset)
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(bottomInset)
            }
        }
    }
    
    var safeAreaBottom: CGFloat {
        YFApp.safeAreaInsets.bottom
    }
    
    func setupContent() {
        if let customView = customContentView {
            contentStack.addArrangedSubview(customView)
        } else {
            if let title = alertTitle, !title.isEmpty {
                titleLabel.text = title
                contentStack.addArrangedSubview(titleLabel)
            }
            if let message = alertMessage, !message.isEmpty {
                messageLabel.text = message
                contentStack.addArrangedSubview(messageLabel)
            }
            if !textFieldConfigs.isEmpty {
                setupTextFields()
                contentStack.addArrangedSubview(textFieldStack)
            }
        }
        
        if !actions.isEmpty {
            setupButtons()
            contentStack.addArrangedSubview(buttonStack)
        }
    }
    
    func setupTextFields() {
        for config in textFieldConfigs {
            let tf = YFTextField(config.placeholder).keyboard(config.keyboardType).secure(config.isSecureTextEntry).bordered()
            if let text = config.text { tf.text = text }
            tf.snp.makeConstraints { $0.height.equalTo(44) }
            textFields.append(tf)
            textFieldStack.addArrangedSubview(tf)
        }
    }
    
    func setupButtons() {
        let horizontal = alertStyle == .alert && actions.count == 2
        buttonStack.axis = horizontal ? .horizontal : .vertical
        buttonStack.distribution = horizontal ? .fillEqually : .fill
        
        let sorted = alertStyle == .actionSheet
            ? actions.filter { $0.style != .cancel } + actions.filter { $0.style == .cancel }
            : actions.sorted { ($0.style == .cancel ? 0 : 1) < ($1.style == .cancel ? 0 : 1) }
        
        for (i, action) in sorted.enumerated() {
            if alertStyle == .actionSheet && action.style == .cancel && i > 0 {
                let spacer = UIView()
                spacer.snp.makeConstraints { $0.height.equalTo(8) }
                buttonStack.addArrangedSubview(spacer)
            }
            buttonStack.addArrangedSubview(createButton(for: action))
        }
    }
    
    func createButton(for action: YFAlertAction) -> YFButton {
        let btn = YFButton(action.title).font(.systemFont(ofSize: 16, weight: .medium)).cornerRadius(10)
        btn.snp.makeConstraints { $0.height.equalTo(48) }
        
        switch action.style {
        case .default: btn.style(.primary)
        case .cancel: btn.background(.themed(\.surfaceSecondary)).color(.themed(\.textPrimary))
        case .destructive: btn.style(.destructive)
        }
        
        btn.onPressed { [weak self] in
            self?.dismiss(animated: true) { action.handler?() }
        }
        return btn
    }
    
    func setupSwipeGesture() {
        guard alertStyle == .actionSheet && enableSwipeToDismiss else { return }
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        let velocity = gesture.velocity(in: view).y
        let height = containerView.bounds.height
        
        switch gesture.state {
        case .changed:
            if translation > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation)
                dimmingView.alpha = 1 - min(translation / height, 0.5)
            }
        case .ended, .cancelled:
            if translation > height / 3 || velocity > 500 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                    self.containerView.transform = .identity
                    self.dimmingView.alpha = 1
                }
            }
        default: break
        }
    }
}

// MARK: - Keyboard

private extension YFAlertController {
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ n: Notification) {
        guard alertStyle == .alert,
              let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let overlap = containerView.frame.maxY - (view.bounds.height - frame.height) + 20
        if overlap > 0 {
            UIView.animate(withDuration: duration) {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: -overlap)
            }
        }
    }
    
    @objc func keyboardWillHide(_ n: Notification) {
        guard alertStyle == .alert,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) { self.containerView.transform = .identity }
    }
}

// MARK: - Show

public extension YFAlertController {
    
    func show(from vc: UIViewController? = nil) {
        (vc ?? YFApp.topViewController)?.present(self, animated: true)
    }
}
