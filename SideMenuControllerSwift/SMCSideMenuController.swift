/*****************************************************************************
 *
 * FILE:	SMCSideMenuController.swift
 * DESCRIPTION:	SideMenuController: Sliding Side Menu Controller Main Class
 * DATE:	Mon, Feb 18 2019
 * UPDATED:	Sat, Mar 23 2019
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2019 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2019 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 *****************************************************************************/

import UIKit
import QuartzCore

// MARK: -
let SMCSideMenuControllerDidShowMenuNotification: String = "SMCSideMenuControllerDidShowMenuNotification"
let SMCSideMenuControllerDidHideMenuNotification: String = "SMCSideMenuControllerDidHideMenuNotification"

extension Notification.Name {
  public struct SMCSideMenu
  {
    static let ShowSideMenu = Notification.Name(SMCSideMenuControllerDidShowMenuNotification)
    static let HideSideMenu = Notification.Name(SMCSideMenuControllerDidHideMenuNotification)
  }
}

fileprivate let kSideMenuTableViewCellIdentifier: String = "SideMenuTableViewCellIdentifier"
fileprivate let kSideMenuHeaderIdentifier: String = "SideMenuHeaderIdentifier"
fileprivate let kSectionHeaderLabelHeight: CGFloat = 32.0
fileprivate let kSectionHeaderFontSize: CGFloat    = 14.0

fileprivate final class SideMenuHeader: UITableViewHeaderFooterView
{
  public let titleLabel: UILabel = {
    let label: UILabel = UILabel()
    label.backgroundColor = .clear
    label.textAlignment = .left
    label.textColor = .darkGray
    label.font = UIFont.boldSystemFont(ofSize: kSectionHeaderFontSize)
    return label
  }()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    self.contentView.addSubview(titleLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let x: CGFloat = 4.0
    let y: CGFloat = 4.0
    let w: CGFloat = contentView.frame.size.width - x * 2.0
    let h: CGFloat = kSectionHeaderLabelHeight - y * 2.0
    titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
  }
}

fileprivate let kRevealAnimationSpeed: TimeInterval = 0.4

public class SMCSideMenuController: UIViewController
{
  public private(set) var delegate: SMCSideMenuDelegate
  public private(set) var isMenuVisible: Bool = true
  public private(set) weak var currentViewController: UIViewController? = nil

  public lazy private(set) var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: self.tableStyle)
    tableView.register(SideMenuHeader.self, forHeaderFooterViewReuseIdentifier: kSideMenuHeaderIdentifier)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: kSideMenuTableViewCellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .groupTableViewBackground
    if #available(iOS 11.0, *) {
      tableView.contentInsetAdjustmentBehavior = .never
    }
    tableView.separatorColor = .darkGray
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.isScrollEnabled = true
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    return tableView
  }()

  private lazy var sideMenuWidth: CGFloat = {
    let width: CGFloat = self.view.bounds.size.width
    let right: CGFloat = 64.0 // Right margin at showing side menu
    return width - right
  }()

  // Setup the container view which will hold the child view controllers view
  private lazy var containerView: UIView = {
    let containerView: UIView = UIView()
    var frame = self.view.bounds
    frame.origin.x = self.sideMenuWidth
    containerView.frame = frame
    containerView.autoresizesSubviews = true
    containerView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

    // The container view also needs a subtle shadow
    let containerShadow: CAGradientLayer = {
      let kContainerShadowWidth: CGFloat = 10.0
      let containerShadow: CAGradientLayer = CAGradientLayer()
      let x: CGFloat = -kContainerShadowWidth
      let y: CGFloat = 0.0
      let w: CGFloat = kContainerShadowWidth
      let h: CGFloat = containerView.frame.size.height
      containerShadow.frame = CGRect(x: x, y: y, width: w, height: h)
      let colors = [
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).cgColor,
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor
      ]
      containerShadow.colors = colors
      containerShadow.startPoint = CGPoint(x: 1.0, y: 1.0)
      return containerShadow
    }()
    containerView.layer.addSublayer(containerShadow)
    return containerView
  }()

  // Setup the touch mask for when the menu is visible
  private lazy var touchView: UIView = {
    let touchView: UIView = UIView()
    touchView.frame = self.containerView.frame
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
    touchView.addGestureRecognizer(tapGesture)
    return touchView
  }()

  private var tableStyle: UITableView.Style = .plain
  private var isAnimating: Bool = false
  private var isModalPresenting: Bool = false

  // Designated Initializer
  public required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  public init(delegate: SMCSideMenuDelegate, style: UITableView.Style = .plain) {
    self.delegate = delegate
    self.tableStyle = style
    super.init(nibName: nil, bundle: nil)
  }

  public override func loadView() {
    super.loadView()

    self.view.backgroundColor	= .white
    self.view.autoresizesSubviews = true
    self.view.autoresizingMask	= [ .flexibleWidth, .flexibleHeight ]

    self.edgesForExtendedLayout = []
    self.extendedLayoutIncludesOpaqueBars = true

    // Setup the menu table view
    self.view.addSubview(tableView)
    tableView.frame = {
      let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
      var frame: CGRect  = self.view.frame
      frame.origin.y    += statusBarHeight
      frame.size.height -= statusBarHeight
      frame.size.width   = self.sideMenuWidth
      return frame
    }()

    /*
     * XXX:
     * swift - iOS 11 Extra top space in UITableView - Stack Overflow
     * https://stackoverflow.com/questions/46421673/ios-11-extra-top-space-in-uitableview/46496562
     */
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))

    self.view.addSubview(containerView)
    self.view.addSubview(touchView)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if isModalPresenting {
      isModalPresenting = false
      // XXX: ModalViewController を閉じたので以前の ViewController を継続利用
      return
    }

    // Set the default view controller
    let viewController: UIViewController = delegate.sideMenuDefaultViewController(self)
    viewController.view.frame = {
      var frame: CGRect = self.containerView.frame
      frame.origin = CGPoint.zero
      return frame
    }()

    self.addChild(viewController)
    viewController.didMove(toParent: self)

    viewController.viewWillAppear(false)
    self.containerView.addSubview(viewController.view)
    viewController.viewDidAppear(false)

    self.currentViewController = viewController

    hideMenu(withDuration:0.0, delay: 0.0)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    // XXX: SMCSideMenuController が Disappear するのは Modal 状態の場合なので
    isModalPresenting = true

    super.viewWillDisappear(animated)
  }

  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    if #available(iOS 11.0, *) {
      self.view.frame = {
        let insets = self.view.safeAreaInsets
        var frame: CGRect  = self.view.frame
        frame.size.height -= insets.bottom
        return frame
      }()
    }
  }
}

extension SMCSideMenuController
{
  @objc func tapGestureHandler(gesture: UITapGestureRecognizer) {
    hideMenu()
  }
}

extension SMCSideMenuController
{
  @objc public func showMenu() {
    guard !isAnimating, !isMenuVisible else { return }

    isAnimating = true
    isMenuVisible = true

    touchView.isHidden = false
    tableView.scrollsToTop = true

    let animationsHandler: () -> Void = {
      [unowned self] in
      var frame: CGRect = self.containerView.frame
      frame.origin.x = self.sideMenuWidth
      self.containerView.frame = frame
    }
    let completionHandler: (Bool) -> Void = {
      [unowned self] (finished: Bool) in
      self.isAnimating = false
      if let viewController = self.currentViewController {
        self.delegate.sideMenu(self, didShowMenu: viewController)
      }
      NotificationCenter.default.post(name: Notification.Name.SMCSideMenu.ShowSideMenu, object: nil)
    }
    UIView.animate(withDuration: kRevealAnimationSpeed,
                   animations: animationsHandler,
                   completion: completionHandler
    )
  }

  public func hideMenu() {
    hideMenu(withDuration: kRevealAnimationSpeed, delay: 0.0)
  }

  func hideMenu(withDuration duration: TimeInterval, delay: TimeInterval) {
    guard !isAnimating, isMenuVisible else { return }

    isAnimating = true
    isMenuVisible = false

    touchView.isHidden = true
    tableView.scrollsToTop = false

    let animationsHandler: () -> Void = {
      [unowned self] in
      var frame: CGRect = self.containerView.frame
      frame.origin = CGPoint.zero
      self.containerView.frame = frame
    }
    let completionHandler: (Bool) -> Void = {
      [unowned self] (finished: Bool) in
      self.isAnimating = false
      if let viewController = self.currentViewController {
        self.delegate.sideMenu(self, didHideMenu: viewController)
      }
      NotificationCenter.default.post(name: Notification.Name.SMCSideMenu.HideSideMenu, object: nil)
    }
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: [.curveLinear],
                   animations: animationsHandler,
                   completion: completionHandler)
  }

  func setRootViewController(_ viewController: UIViewController) {
    self.addChild(viewController)
    viewController.didMove(toParent: self)

    // Reset the frame view
    var frame: CGRect = self.containerView.frame
    frame.origin = CGPoint.zero
    viewController.view.frame = frame

    let animationsHandler: () -> Void = {
      [unowned self] in
      // Remove the old view controller
      self.currentViewController?.willMove(toParent: nil)
      self.currentViewController?.removeFromParent()
      // Reset the pointer
      self.currentViewController = viewController
    }
    let completionHandler: (Bool) -> Void = {
      [unowned self] (finished: Bool) in
      // Hide the menu
      let kHideMenuDelay: TimeInterval = 0.2
      self.hideMenu(withDuration: kRevealAnimationSpeed, delay: kHideMenuDelay)
    }
    // Perform the view transition
    self.transition(from: self.currentViewController!,
                    to: viewController,
                    duration: 0.0,
                    options: [],
                    animations: animationsHandler,
                    completion: completionHandler)
  }
}

// MARK: - UITableViewDataSource
extension SMCSideMenuController: UITableViewDataSource
{
  public func numberOfSections(in tableView: UITableView) -> Int {
    return delegate.numberOfSections(in: self)
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return delegate.sideMenu(self, numberOfRowsInSection:section)
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: kSideMenuTableViewCellIdentifier, for: indexPath)
    cell.selectionStyle = .default
    cell.accessoryType = .none
    cell.accessoryView = nil
    cell.imageView?.image = nil
    cell.textLabel?.text = nil
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    return delegate.sideMenu(self, configure: cell, forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let height = delegate.sideMenu(self, heightForHeaderInSection: section)
    return height < 0.0 ? kSectionHeaderLabelHeight : height
  }
}

// MARK: - UITableViewDelegate
extension SMCSideMenuController: UITableViewDelegate
{
  public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kSideMenuHeaderIdentifier) as? SideMenuHeader {
      headerView.titleLabel.text = delegate.sideMenu(self, titleForHeaderInSection: section)
      if let color = delegate.textColorOfHeader(in: section) {
        headerView.titleLabel.textColor = color
      }
      if let color = delegate.backgroundColorOfHeader(in: section) {
        headerView.contentView.backgroundColor = color
      }
      return headerView
    }
    return nil
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
      autoreleasepool {
        DispatchQueue.main.async {
          [weak self] in
          if let weakSelf = self {
            let viewController: UIViewController = weakSelf.delegate.sideMenu(weakSelf, viewControllerForRowAt: indexPath)
            // Add the view controller as a child
            if let currentViewController = weakSelf.currentViewController,
               currentViewController == viewController {
              weakSelf.hideMenu()
            }
            else {
              weakSelf.setRootViewController(viewController)
            }
          }
        }
      }
    }
  }
}

extension SMCSideMenuController
{
  public func menuIcon(color: UIColor = .white) -> UIImage? {
    let   size: CGSize  = CGSize(width: 32.0, height: 32.0)
    let opaque: Bool    = false
    let  scale: CGFloat = 0.0

    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
    color.setFill()

    let x: CGFloat = 2.0
    var y: CGFloat = 7.0
    let w: CGFloat = 28.0
    let h: CGFloat = 3.0
    var path = UIBezierPath(rect: CGRect(x: x, y: y, width: w, height: h))
    path.fill()
    y += (h + 5.0)
    path = UIBezierPath(rect: CGRect(x: x, y: y, width: w, height: h))
    path.fill()
    y += (h + 5.0)
    path = UIBezierPath(rect: CGRect(x: x, y: y, width: w, height: h))
    path.fill()

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image?.withRenderingMode(.alwaysOriginal)
  }

  public func menuButtonItem() -> UIBarButtonItem {
    let image: UIImage? = menuIcon()
    let button: UIButton = UIButton(type: .custom)
    button.setImage(image, for: .normal)
    let color: UIColor = UIColor(white: 1.0, alpha: 0.5)
    button.setImage(menuIcon(color: color), for: .disabled)
    button.setImage(menuIcon(color: color), for: .highlighted)
    button.sizeToFit()
    button.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
    return UIBarButtonItem(customView: button)
  }
}
