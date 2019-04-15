//
//  CAPSPageMenu+Configuration.swift
//  PageMenuNoStoryboardConfigurationDemo
//
//  Created by Matthew York on 3/6/17.
//  Copyright © 2017 UACAPS. All rights reserved.
//

import UIKit

extension CAPSPageMenu {
    func configurePageMenu(options: [CAPSPageMenuOption]) {
        for option in options {
            switch (option) {
            case let .selectionIndicatorHeight(value):
                configuration.selectionIndicatorHeight = value
            case let .menuItemSeparatorWidth(value):
                configuration.menuItemSeparatorWidth = value
            case let .scrollMenuBackgroundColor(value):
                configuration.scrollMenuBackgroundColor = value
            case let .viewBackgroundColor(value):
                configuration.viewBackgroundColor = value
            case let .bottomMenuHairlineColor(value):
                configuration.bottomMenuHairlineColor = value
            case let .selectionIndicatorColor(value):
                configuration.selectionIndicatorColor = value
            case let .menuItemSeparatorColor(value):
                configuration.menuItemSeparatorColor = value
            case let .menuMargin(value):
                configuration.menuMargin = value
            case let .menuItemMargin(value):
                menuItemMargin = value
            case let .menuHeight(value):
                configuration.menuHeight = value
            case let .selectedMenuItemLabelColor(value):
                configuration.selectedMenuItemLabelColor = value
            case let .unselectedMenuItemLabelColor(value):
                configuration.unselectedMenuItemLabelColor = value
            case let .useMenuLikeSegmentedControl(value):
                configuration.useMenuLikeSegmentedControl = value
            case let .menuItemSeparatorRoundEdges(value):
                configuration.menuItemSeparatorRoundEdges = value
            case let .menuItemFont(value):
                configuration.menuItemFont = value
            case let .menuItemSeparatorPercentageHeight(value):
                configuration.menuItemSeparatorPercentageHeight = value
            case let .menuItemWidth(value):
                configuration.menuItemWidth = value
            case let .enableHorizontalBounce(value):
                configuration.enableHorizontalBounce = value
            case let .addBottomMenuHairline(value):
                configuration.addBottomMenuHairline = value
            case let .menuItemWidthBasedOnTitleTextWidth(value):
                configuration.menuItemWidthBasedOnTitleTextWidth = value
            case let .titleTextSizeBasedOnMenuItemWidth(value):
                configuration.titleTextSizeBasedOnMenuItemWidth = value
            case let .scrollAnimationDurationOnMenuItemTap(value):
                configuration.scrollAnimationDurationOnMenuItemTap = value
            case let .centerMenuItems(value):
                configuration.centerMenuItems = value
            case let .hideTopMenuBar(value):
                configuration.hideTopMenuBar = value
            case let .itemsScaleToFill(value):
                configuration.itemsScaleToFill = value
            case let .bottomMenuHairlineHeight(value):
                configuration.bottomMenuHairlineHeight = value
            }
        }
        
        if configuration.hideTopMenuBar {
            configuration.addBottomMenuHairline = false
            configuration.menuHeight = 0.0
            configuration.bottomMenuHairlineHeight = 0.0
        }
    }
    
    func setUpUserInterface() {
        // Set up controller scroll view
        controllerScrollView.isPagingEnabled = true
        controllerScrollView.translatesAutoresizingMaskIntoConstraints = false
        controllerScrollView.alwaysBounceHorizontal = configuration.enableHorizontalBounce
        controllerScrollView.bounces = configuration.enableHorizontalBounce
        
        controllerScrollView.frame = CGRect(x: 0.0, y: configuration.menuHeight, width: self.view.frame.width, height: self.view.frame.height - configuration.menuHeight)
        
        self.view.addSubview(controllerScrollView)
        
        
        // Set up menu scroll view
        menuScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        menuScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: configuration.menuHeight)
        
        self.view.addSubview(menuScrollView)
        
//        controllerScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        controllerScrollView.rightAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        controllerScrollView.topAnchor.constraint(equalTo: menuScrollView.bottomAnchor).isActive = true
//        controllerScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//
//        menuScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        menuScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        menuScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        menuScrollView.heightAnchor.constraint(equalToConstant: configuration.menuHeight).isActive = true
        
        // Add hairline to menu scroll view
        if configuration.addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()
            
            menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(menuBottomHairline)
            
            menuBottomHairline.frame = CGRect(x: 0, y: configuration.menuHeight, width: view.width, height: configuration.bottomMenuHairlineHeight)
            
//            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuBottomHairline]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
//            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(configuration.menuHeight)-[menuBottomHairline(\(configuration.bottomMenuHairlineHeight))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
//
//            self.view.addConstraints(menuBottomHairline_constraint_H)
//            self.view.addConstraints(menuBottomHairline_constraint_V)
            
            menuBottomHairline.backgroundColor = configuration.bottomMenuHairlineColor
        }
        
        // Disable scroll bars
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        
        // Set background color behind scroll views and for menu scroll view
        self.view.backgroundColor = configuration.viewBackgroundColor
        menuScrollView.backgroundColor = configuration.scrollMenuBackgroundColor
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func configureUserInterface() {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CAPSPageMenu.handleMenuItemTap(_:)))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        
        // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
        // but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
        // If more than one scroll view is found, none will be scrolled.
        // Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
        menuScrollView.scrollsToTop = false;
        controllerScrollView.scrollsToTop = false;
        
        // Configure menu scroll view
        if configuration.useMenuLikeSegmentedControl {
            menuScrollView.isScrollEnabled = false
            menuScrollView.contentSize = CGSize(width: self.view.frame.width, height: configuration.menuHeight)
            configuration.menuMargin = 0.0
        } else {
            menuScrollView.contentSize = CGSize(width: (configuration.menuItemWidth + configuration.menuMargin) * CGFloat(controllerArray.count) + configuration.menuMargin, height: configuration.menuHeight)
        }
        
        if configuration.itemsScaleToFill {
            let itemCount = CGFloat(controllerArray.count)
            configuration.menuItemWidth = (view.bounds.size.width - ((itemCount - 1) * menuItemMargin + configuration.menuMargin * 2)) / itemCount
        }
        
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(controllerArray.count), height: 0.0)
        
        var index : CGFloat = 0.0
        
        for controller in controllerArray {
            if index == 0.0 {
                // Add first two controllers to scrollview and as child view controller
                controller.viewWillAppear(true)
                addPageAtIndex(0)
                controller.viewDidAppear(true)
            }
            
            // Set up menu item for menu scroll view
            var menuItemFrame : CGRect = CGRect()
            
            if configuration.useMenuLikeSegmentedControl {
                //**************************拡張*************************************
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemFrame = CGRect(x: CGFloat(menuItemMargin * (index + 1)) + menuItemWidth * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: configuration.menuHeight)
                } else {
                    menuItemFrame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: configuration.menuHeight)
                }
                //**************************拡張ここまで*************************************
            } else if configuration.menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle : String? = controller.title
                
                let titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                let itemWidthRect : CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:configuration.menuItemFont], context: nil)
                configuration.menuItemWidth = itemWidthRect.width
                
                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + configuration.menuMargin + (configuration.menuMargin * index), y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if configuration.itemsScaleToFill {
                    menuItemFrame = CGRect(x: configuration.menuMargin + (configuration.menuItemWidth + menuItemMargin) * index, y: 0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                } else if configuration.centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * configuration.menuItemWidth) + (CGFloat(controllerArray.count - 1) * configuration.menuMargin))) / 2.0) -  configuration.menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRect(x: startingMenuMargin + configuration.menuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                } else {
                    menuItemFrame = CGRect(x: configuration.menuItemWidth * index + configuration.menuMargin * (index + 1) + startingMenuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                }
            }
            
            let menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
            menuItemView.configure(for: self, controller: controller, index: index)
            // Add menu item view to menu scroll view
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)
            
            index += 1
        }
        
        // Set new content size for menu scroll view if needed
        if configuration.itemsScaleToFill {
            menuScrollView.contentSize = CGSize(width: view.bounds.size.width, height: configuration.menuHeight)
        } else if configuration.menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSize(width: (totalMenuItemWidthIfDifferentWidths + configuration.menuMargin) + CGFloat(controllerArray.count) * configuration.menuMargin, height: configuration.menuHeight)
        }
        
        // Set selected color for title label of selected menu item
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].titleLabel != nil {
                menuItems[currentPageIndex].titleLabel!.textColor = configuration.selectedMenuItemLabelColor
            }
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect = CGRect()
        
        if configuration.itemsScaleToFill {
            selectionIndicatorFrame = CGRect(x: menuItems.first?.frame.origin.x ?? configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: menuItems.first?.bounds.size.width ?? self.view.frame.width / CGFloat(controllerArray.count), height: configuration.selectionIndicatorHeight)
        } else if configuration.useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRect(x: 0.0, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: self.view.frame.width / CGFloat(controllerArray.count), height: configuration.selectionIndicatorHeight)
        } else if configuration.menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRect(x: configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: menuItemWidths[0], height: configuration.selectionIndicatorHeight)
        } else {
            if configuration.centerMenuItems  {
                selectionIndicatorFrame = CGRect(x: startingMenuMargin + configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: configuration.menuItemWidth, height: configuration.selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRect(x: configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: configuration.menuItemWidth, height: configuration.selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = configuration.selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
    }
}

