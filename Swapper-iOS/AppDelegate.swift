//
//  AppDelegate.swift
//  Swapper-iOS
//
//  Created by Timo Jääskeläinen on 20/03/16.
//  Copyright © 2016 Swapper. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        ExploreBooksCache.sharedInstance.update()
        MyBooksCache.sharedInstance.update()
        RequestedBooksCache.sharedInstance.update()
    }


}

