//
//  AppDelegate.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let event = EventManager.sharedInstance
        let notif = LocalNotificationManager.sharedInstance

		CloudKitManager.sharedInstance

//        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
     
////        navigationController!.navigationBar.barTintColor = UIColor
//        
//        UINavigationBar.appearance().barTintColor = UIColor(red: 225, green: 89, blue: 83, alpha: 1.0)
////      (red: 225, green: 89, blue: 83, alpha: 1.0)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.


    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.sharedInstance.saveContext()
    }
    
    //Notification
//    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        println("ayy local");
//        let sb = UIStoryboard(name: "Main", bundle: nil);
//        let agenda = sb.instantiateViewControllerWithIdentifier("tabBar") as! UINavigationController;
//        self.window?.rootViewController?.presentViewController(agenda, animated: false, completion: nil);
//    }
//    
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//
//    }


}

