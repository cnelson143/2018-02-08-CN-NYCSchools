//
//  AppDelegate.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

// Added to new repo
/*
 
 Thank You for the opportunity to do this coding challenge, I enjoyed it.  I added comments primarily to the 'SchoolTableViewController'.  I generally comment most heavily when there are extremes or a complex subsystem or at the clients request.  I usually comment by the code flow and method names and property names. I did a simple test but the data is available for variety of test such as determining if there are any schools that do not have a borough, schools that have no tests and schools that have multiple test.

 Additional Features
 Changed the display name in the springboard to be NYC Schools versus the project name
 Handles startup or data refresh while offline
 Pull to refresh
 Search within the table view
 Filter table view to a specific borough
 Changed the Nav bar colors
 Allow calling the school over phone
 Allow emailing the school
 Allow visiting the school's website
 See the school in a map
 Select different display options for the map
 Allow launching the iOS Maps App to get directions
 Universal App

 Known Issues:
 Animation with pull to refresh does not always animate
 A weak network connection may cause a delay in refreshing the filter

 Additional Features:
 I chose to focus the iPhone experience, given additional time I would have made the iPad App utilize the master / detail design pattern
 Add additional testing fields
 Have the schema defined outside of the data objects to allow more flexibility in displaying additional details for the school on an additional screen
 With additional time more features would be added based on reviewing the data source schema

 I am new to GitLab I believe I have the project uploaded properly and added you correctly.  Feel free to call me or reply to this email with questions, etc.
 
 */
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navBarProxy : UINavigationBar = UINavigationBar.appearance()
        navBarProxy.barTintColor = UIColor.white
        navBarProxy.tintColor = UIColor.blue
        navBarProxy.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.blue]

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

