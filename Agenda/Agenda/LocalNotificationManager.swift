//
//  LocalNotificationManager.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 17/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import UIKit


class LocalNotificationManager {
	static let sharedInstance = LocalNotificationManager()
	private init(){
		let notificationSettings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound), categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
	}

	func scheduleNewNotification(#title: String, msg: String, action : String, options: [NSObject:AnyObject]?, toDate: NSDate = NSDate()){

		let settings = UIApplication.sharedApplication().currentUserNotificationSettings()

		if settings.types != UIUserNotificationType.None{

			let localNotification:UILocalNotification = UILocalNotification()

			localNotification.alertAction = action
			localNotification.alertTitle = title
			localNotification.alertBody = msg

			localNotification.timeZone = NSTimeZone.systemTimeZone()
			localNotification.fireDate = toDate
			localNotification.soundName = UILocalNotificationDefaultSoundName

			if options != nil{
				localNotification.userInfo = options;
			}

			UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
		}
	}

	func getAllScheduledNotifications() -> [UILocalNotification]{
		return UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
	}

	func cancelSingleScheduledNotification(notification: UILocalNotification){
		UIApplication.sharedApplication().cancelLocalNotification(notification)
	}

	func cancelAllScheduledNotification(){
		UIApplication.sharedApplication().cancelAllLocalNotifications()
	}
}