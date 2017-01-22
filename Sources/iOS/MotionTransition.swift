/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

fileprivate var MotionTransitionItemKey: UInt8 = 0
fileprivate var MotionTransitionItemControllerKey: UInt8 = 0

fileprivate struct MotionTransitionItem {
    fileprivate var identifier: String
    fileprivate var animations: [MotionAnimation]
}

fileprivate struct MotionTransitionItemController {
    fileprivate var delegate: MotionTransitionDelegate
}

extension UIViewController {
    /// MaterialLayer Reference.
    fileprivate var motionTransition: MotionTransitionItemController {
        get {
            return AssociatedObject(base: self, key: &MotionTransitionItemControllerKey) {
                return MotionTransitionItemController(delegate: MotionTransitionDelegate())
            }
        }
        set(value) {
            AssociateObject(base: self, key: &MotionTransitionItemControllerKey, value: value)
        }
    }
    
    open var transitionDelegate: MotionTransitionDelegate {
        return motionTransition.delegate
    }
}

open class MotionTransitionViewController: UIViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
        prepare()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        prepare()
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepare method
     to initialize property values and other setup operations.
     The super.prepare method should always be called immediately
     when subclassing.
     */
    open func prepare() {
        modalPresentationStyle = .custom
        transitioningDelegate = transitionDelegate
    }
}

extension UIView {
    /// MaterialLayer Reference.
    fileprivate var motionTransition: MotionTransitionItem {
        get {
            return AssociatedObject(base: self, key: &MotionTransitionItemKey) {
                return MotionTransitionItem(identifier: "", animations: [])
            }
        }
        set(value) {
            AssociateObject(base: self, key: &MotionTransitionItemKey, value: value)
        }
    }
    
    open var motionTransitionIdentifier: String {
        get {
            return motionTransition.identifier
        }
        set(value) {
            motionTransition.identifier = value
        }
    }
    
    open var motionTransitionAnimations: [MotionAnimation] {
        get {
            return motionTransition.animations
        }
        set(value) {
            motionTransition.animations = value
        }
    }
}

open class MotionTransitionPresentationController: UIPresentationController {
    open override func presentationTransitionWillBegin() {
        guard nil != containerView else {
            return
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
//            print("Animating")
        })
        
//        print("presentationTransitionWillBegin")
    }

    open override func presentationTransitionDidEnd(_ completed: Bool) {
//        print("presentationTransitionDidEnd")
    }
    
    open override func dismissalTransitionWillBegin() {
        guard nil != containerView else {
            return
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
//            print("Animating")
        })
        
//        print("dismissalTransitionWillBegin")
    }
    
    open override func dismissalTransitionDidEnd(_ completed: Bool) {
//        print("dismissalTransitionDidEnd")
    }
    
    open override var frameOfPresentedViewInContainerView: CGRect {
        return containerView?.bounds ?? .zero
    }
}

open class MotionTransitionDelegate: NSObject {
    open var isPresenting = false
    
    open var toViewController: UIViewController!
    
    open var fromViewController: UIViewController!
}

extension MotionTransitionDelegate: UIViewControllerTransitioningDelegate {
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MotionTransitionPresentedAnimator()
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MotionTransitionDismissedAnimator()
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil // MotionTransitionInteractiveAnimator()
    }
    
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil // MotionTransitionInteractiveAnimator()
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MotionTransitionPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MotionTransitionDelegate: UINavigationControllerDelegate {
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = operation == .push
        return MotionTransitionAnimator()
    }
    
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return MotionTransitionInteractiveAnimator()
    }
}

extension MotionTransitionDelegate: UITabBarControllerDelegate {
    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        self.fromViewController = fromViewController ?? fromVC
        self.toViewController = toViewController ?? toVC
        //        self.inContainerController = true
        return MotionTransitionAnimator()
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return MotionTransitionInteractiveAnimator()
    }
}

open class MotionTransitionAnimator: MotionTransitionDelegate {
    open var transitionContext: UIViewControllerContextTransitioning!
    
    open var delay: TimeInterval = 0
    open var duration: TimeInterval = 0
    
    open var containerView: UIView!
    open var transitionView = UIView()
    
    public var toViews: [UIView] {
        var views: [UIView] = 0 < toViewController.view.motionTransitionIdentifier.utf16.count ? [toViewController.view] : []
        subviews(of: toViewController.view, views: &views)
        return views
    }
    
    public var fromViews: [UIView] {
        var views: [UIView] = 0 < fromViewController.view.motionTransitionIdentifier.utf16.count ? [fromViewController.view] : []
        subviews(of: fromViewController.view, views: &views)
        return views
    }
}

extension MotionTransitionAnimator: UIViewControllerAnimatedTransitioning {
    @objc(animateTransition:)
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let tVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        guard let fVC = transitionContext.viewController(forKey: .from) else {
            return
        }

        self.transitionContext = transitionContext
        
        containerView = transitionContext.containerView
        containerView.addSubview(transitionView)
        transitionView.frame = containerView.bounds
        
        toViewController = tVC
        fromViewController = fVC
    }
    
    @objc(transitionDuration:)
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return delay + duration
    }
}

extension MotionTransitionDelegate {
    fileprivate func subviews(of view: UIView, views: inout [UIView]) {
        for v in view.subviews {
            if 0 < v.motionTransitionIdentifier.utf16.count {
                views.append(v)
            }
            subviews(of: v, views: &views)
        }
    }
    
    fileprivate func snapshotView(for view: UIView) -> UIView {
        view.isHidden = false
        
        // capture a snapshot without cornerRadius
        let oldCornerRadius = view.cornerRadius
        view.cornerRadius = 0
        let v = view.snapshotView(afterScreenUpdates: false)!
        view.cornerRadius = oldCornerRadius
        
        let contentView = v.subviews.first!
        contentView.cornerRadius = view.cornerRadius
        contentView.masksToBounds = true
        
        v.motionTransitionIdentifier = view.motionTransitionIdentifier
        v.cornerRadius = view.cornerRadius
        v.zPosition = view.zPosition
        v.opacity = view.opacity
        v.isOpaque = view.isOpaque
        v.anchorPoint = view.anchorPoint
        v.layer.masksToBounds = view.layer.masksToBounds
        v.borderColor = view.borderColor
        v.borderWidth = view.borderWidth
        v.shadowRadius = view.shadowRadius
        v.shadowOpacity = view.shadowOpacity
        v.shadowColor = view.shadowColor
        v.shadowOffset = view.shadowOffset
        
        v.layer.transform = view.layer.transform
        
        view.isHidden = true
        
        return v
    }
}

open class MotionTransitionPresentedAnimator: MotionTransitionAnimator {
    @objc(animateTransition:)
    open override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        for toView in toViews {
            for fromView in fromViews {
                if toView.motionTransitionIdentifier == fromView.motionTransitionIdentifier {
                    
                    var t: TimeInterval = 0
                    var d: TimeInterval = 0
                    var a = [CABasicAnimation]()
                    var tf = MotionAnimationTimingFunction.easeInEaseOut
                    
                    for ta in toView.motionTransitionAnimations {
                        switch ta {
                        case let .delay(time):
                            if time > delay {
                                delay = time
                            }
                            t = time
                        case let .duration(time):
                            if time > duration {
                                duration = time
                            }
                            d = time
                        default:break
                        }
                    }
                    
//                    var w: CGFloat = toView.bounds.width
//                    var h: CGFloat = toView.bounds.height
//                    var px: CGFloat = toView.position.x + w / 2
//                    var py: CGFloat = toView.position.y + h / 2
//                    a.append(Motion.position(x: px, y: py))
//                    a.append(Motion.width(w))
//                    a.append(Motion.height(h))
                    
//                    let rotate = Motion.rotate(angle: toView.layer.value(forKeyPath: MotionAnimationKeyPath.rotation.rawValue) as? CGFloat ?? 0)
//                    rotate.fromValue = fromView.layer.value(forKeyPath: MotionAnimationKeyPath.rotation.rawValue)
//                    a.append(rotate)
                    
                    a.append(Motion.background(color: toView.backgroundColor ?? .clear))
//                    a.append(Motion.corner(radius: toView.cornerRadius))
                    
                    let snapshot = snapshotView(for: fromView)
                    snapshot.isHidden = false
                    snapshot.bounds = fromView.bounds
                    snapshot.position = fromView.superview?.convert(fromView.position, to: nil) ?? fromView.position
                    transitionView.addSubview(snapshot)
                    
                    Motion.delay(t) {
                        for ta in toView.motionTransitionAnimations {
                            switch ta {
                            case let .timingFunction(timingFunction):
                                tf = timingFunction
                            case let .shadow(path):
                                a.append(Motion.shadow(path: path))
                            default:break
                            }
                        }
                    
                        let g = Motion.animate(group: a, duration: d)
                        g.fillMode = MotionAnimationFillModeToValue(mode: .forwards)
                        g.isRemovedOnCompletion = false
                        g.timingFunction = MotionAnimationTimingFunctionToValue(timingFunction: tf)
                        
                        snapshot.animate(g)
                    }
                }
            }
        }
        
        Motion.delay(transitionDuration(using: transitionContext)) { [weak self] in
            defer {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            guard let s = self else {
                return
            }
            
//            s.transitionView.removeFromSuperview()
            s.containerView.addSubview(s.toViewController.view)
        }
    }
}

open class MotionTransitionDismissedAnimator: MotionTransitionAnimator {
    @objc(animateTransition:)
    open override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        for v in fromViews {
            for v2 in toViews {
                if v.motionTransitionIdentifier == v2.motionTransitionIdentifier {
                    
                    var t: TimeInterval = 0
                    var d: TimeInterval = 0
                    var a = [CABasicAnimation]()
                    var tf = MotionAnimationTimingFunction.easeInEaseOut
                    
                    for ta in v.motionTransitionAnimations {
                        switch ta {
                        case let .delay(time):
                            if time > delay {
                                delay = time
                            }
                            t = time
                        case let .duration(time):
                            if time > duration {
                                duration = time
                            }
                            d = time
                        case let .timingFunction(timingFunction):
                            tf = timingFunction
                        case .rotate(_):
                            let radians = CGFloat(atan2f(Float(v2.transform.b), Float(v2.transform.a)))
                            let rotate = Motion.rotate(angle: radians * 180 / CGFloat(M_PI))
                            rotate.fromValue = v.layer.value(forKeyPath: MotionAnimationKeyPath.rotation.rawValue)
                            a.append(rotate)
                        case .backgroundColor(_):
                            a.append(Motion.background(color: .clear))
                        case .corners(_):
                            a.append(Motion.corner(radius: v2.cornerRadius))
                        case .x(_), .y(_), .point(_, _), .position(_, _):
                            a.append(Motion.position(to: nil == v2.superview ? v2.position : v2.superview!.convert(v2.position, to: nil)))
                        case let .shadow(path):
                            a.append(Motion.shadow(path: path))
                        case .width(_):
                            a.append(Motion.width(v2.bounds.width))
                        case .height(_):
                            a.append(Motion.height(v2.bounds.height))
                        default:break
                        }
                    }
                    
                    Motion.delay(t) {
                        let g = Motion.animate(group: a, duration: d)
                        g.fillMode = MotionAnimationFillModeToValue(mode: .forwards)
                        g.isRemovedOnCompletion = false
                        g.timingFunction = MotionAnimationTimingFunctionToValue(timingFunction: tf)
                        
                        v.animate(g)
                    }
                }
            }
        }
        
        Motion.delay(delay + duration) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

open class MotionTransitionInteractiveAnimator: MotionTransitionInteractiveDelegate {
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        
    }
}

open class MotionTransitionInteractiveDelegate: UIPercentDrivenInteractiveTransition {
    open var isPresenting = false
    open var transitionContext: UIViewControllerContextTransitioning!
    
    open var containerView: UIView!
    
    open var toView: UIView!
    open var toViewController: UIViewController!
    open var toViewStartFrame: CGRect!
    open var toViewFinalFrame: CGRect!
    
    open var fromView: UIView!
    open var fromViewController: UIViewController!
    open var fromViewFinalFrame: CGRect!
    
    open var panGesture: UIPanGestureRecognizer!
    
    @objc(startInteractiveTransition:)
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        
        guard let tView = transitionContext.view(forKey: .to) else {
            return
        }
        
        guard let tVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        guard let fView = transitionContext.view(forKey: .from) else {
            return
        }
        
        guard let fVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        self.transitionContext = transitionContext
        
        containerView = transitionContext.containerView
        
        toView = tView
        toViewController = tVC
        
        fromView = fView
        fromViewController = fVC
        
        toViewStartFrame = transitionContext.initialFrame(for: toViewController)
        toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        
        preparePanGesture()
    }
    
    open func animationEnded(_ transitionCompleted: Bool) {
        //        print("MotionTransitionAnimator", #function)
    }
}

extension MotionTransitionInteractiveDelegate {
    fileprivate func preparePanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        panGesture.maximumNumberOfTouches = 1
        containerView.addGestureRecognizer(panGesture)
    }
}

extension MotionTransitionInteractiveDelegate {
    @objc
    fileprivate func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panGesture.setTranslation(.zero, in: containerView)
        case .changed:
            let translation = panGesture.translation(in: containerView)
            
            /**
             Compute how far the gesture recognizer tranveled on the
             vertical axis.
             */
            let percentageComplete = fabs(translation.y / containerView.bounds.height)
            update(percentageComplete)
            
        case .ended:
            finish()
            containerView.removeGestureRecognizer(panGesture)
        default:break
        }
    }
}