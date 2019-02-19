/*****************************************************************************
 *
 * FILE:	SMCSideMenuDelegate.swift
 * DESCRIPTION:	SideMenuController: Delegate Protocol
 * DATE:	Mon, Feb 18 2019
 * UPDATED:	Tue, Feb 19 2019
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
 * $Id: AppDelegate.m,v 1.6 2017/04/12 09:59:00 kouichi Exp $
 *
 *****************************************************************************/

import Foundation
import UIKit

public protocol SMCSideMenuDelegate: class
{
  // The default view controller to show on startup. This cannot be nil.
  func sideMenuDefaultViewController(_ sideMenuController: SMCSideMenuController) -> UIViewController

  // Return the view controller to be presented when a menu row is tapped.
  func sideMenu(_ sideMenuController: SMCSideMenuController, viewControllerForRowAt indexPath: IndexPath) -> UIViewController

  // DataSource for UITableView
  func numberOfSections(in sideMenuController: SMCSideMenuController) -> Int
  func sideMenu(_ sideMenuController: SMCSideMenuController, numberOfRowsInSection section: Int) -> Int
  func sideMenu(_ sideMenuController: SMCSideMenuController, configure cell: UITableViewCell, forRowAt indexPath: IndexPath) -> UITableViewCell
  func sideMenu(_ sideMenuController: SMCSideMenuController, heightForHeaderInSection section: Int) -> CGFloat

  // Delegate for UITableView
  func sideMenu(_ sideMenuController: SMCSideMenuController, titleForHeaderInSection section: Int) -> String?

  // Colors for Section Header in UITableView
  func textColorOfHeader(in section: Int) -> UIColor?
  func backgroundColorOfHeader(in section: Int) -> UIColor?

  // Events on Menu
  func sideMenu(_ sideMenuController: SMCSideMenuController, didShowMenu viewController: UIViewController) -> Void
  func sideMenu(_ sideMenuController: SMCSideMenuController, didHideMenu viewController: UIViewController) -> Void
}


// MARK: - Default Implementation
extension SMCSideMenuDelegate
{
  public func textColorOfHeader(in section: Int) -> UIColor? {
    return nil
  }

  public func backgroundColorOfHeader(in section: Int) -> UIColor? {
    return nil
  }
}

// MARK: - Default Implementation
extension SMCSideMenuDelegate
{
  public func numberOfSections(in sideMenuController: SMCSideMenuController) -> Int {
    return 1
  }

  public func sideMenu(_ sideMenuController: SMCSideMenuController, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  public func sideMenu(_ sideMenuController: SMCSideMenuController, configure cell: UITableViewCell, forRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }

  public func sideMenu(_ sideMenuController: SMCSideMenuController, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.0
  }
}

// MARK: - Default Implementation
extension SMCSideMenuDelegate
{
  public func sideMenu(_ sideMenuController: SMCSideMenuController, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
}

// MARK: - Default Implementation
extension SMCSideMenuDelegate
{
  public func sideMenu(_ sideMenuController: SMCSideMenuController, didShowMenu viewController: UIViewController) {
  }

  public func sideMenu(_ sideMenuController: SMCSideMenuController, didHideMenu viewController: UIViewController) {
  }
}
