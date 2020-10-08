/*****************************************************************************
 *
 * FILE:	SideMenu.swift
 * DESCRIPTION:	SideMenuControllerDemo: Menu for SideMenuController
 * DATE:	Tue, Feb 19 2019
 * UPDATED:	Thu, Oct  8 2020
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2019-2020 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2019-2020 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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

import Foundation
import UIKit
import SideMenuControllerSwift

class SideMenu: SMCSideMenu
{
  override init() {
    super.init()

    self.viewControllerNames = [
      [
        "OneViewController",
        "TwoViewController",
        "ThreeViewController"
      ],
      [
        "FourViewController",
        "FiveViewController"
      ]
    ]
    self.sectionTitles = [
      "Main",
      "Others"
    ]
    self.menuTitles = [
      [
        "Timeline",
        "Favorites",
        "Bookmarks"
      ],
      [
        "Settings",
        "Information",
      ]
    ]
    self.menuIcons = [
      [
        UIImage(named: "icon_timeline"),
        UIImage(named: "icon_favorites"),
        UIImage(named: "icon_bookmarks")
      ],
      [
        UIImage(named: "icon_settings"),
        UIImage(named: "icon_info")
      ]
    ]
  }

  override open func sideMenu(_ sideMenuController: SMCSideMenuController, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) -> Void {
    cell.imageView?.tintColor = UIColor {
      (traitCollection: UITraitCollection) -> UIColor in
      switch traitCollection.userInterfaceStyle {
        case .light, .unspecified: return .systemBlue
        case .dark:                return .systemRed
        @unknown default:          return .systemGreen
      }
    }
  }

  override open func sideMenu(_ sideMenuController: SMCSideMenuController, didSelectRowAt indexPath: IndexPath) -> Void {
    UserDefaults.standard.set(indexPath, forKey: "LaunchKey")
  }

  override open func startupIndexPath() -> IndexPath? {
    return UserDefaults.standard.indexPath(forKey: "LaunchKey")
  }

  override open func textColorOfHeader(in section: Int) -> UIColor? {
    return UIColor {
      (traitCollection: UITraitCollection) -> UIColor in
      switch traitCollection.userInterfaceStyle {
        case .light, .unspecified: return .systemBlue
        case .dark:                return .label
        @unknown default:          return .systemRed
      }
    }
  }

  override open func backgroundColorOfHeader(in section: Int) -> UIColor? {
    return .clear
  }
}

extension UserDefaults
{
  func indexPath(forKey key: String) -> IndexPath? {
    if let data = data(forKey: key), let indexPath = try? JSONDecoder().decode(IndexPath.self, from: data) {
      return indexPath
    }
    return nil
  }

  func set(_ indexPath: IndexPath, forKey key: String) {
    if let data = try? JSONEncoder().encode(indexPath) {
      set(data, forKey: key)
    }
  }
}
