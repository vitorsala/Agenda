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
		// Verifica e pede permisão para o app enviar notificações
		let notificationSettings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound), categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
	}

	/**
	Agenda uma nova notificação.

	:param: title   Título que aparecerá na notificação
	:param: msg     Mensagem que aparecerá na notificação
	:param: action  Ação que aparecerá quando o aparelho estiver bloqueado
	:param: options Dicionário que será enviado junto com a notificação
	:param: toDate  Data em que a notificação deverá ser disparado. (Padrão = momento que a notificação for postado)
	*/
	func scheduleNewNotification(#title: String, msg: String, action : String?, options: [NSObject:AnyObject]?, toDate: NSDate = NSDate()){

		let settings = UIApplication.sharedApplication().currentUserNotificationSettings()

		if settings.types != UIUserNotificationType.None{	// Verifica se as notificações estão bloqueados

			let localNotification:UILocalNotification = UILocalNotification()
			// Seta ação, título e mensagem.
			localNotification.alertAction = action
			localNotification.alertTitle = title
			localNotification.alertBody = msg
			// Data que a notificação será disparado
			localNotification.timeZone = NSTimeZone.systemTimeZone()
			localNotification.fireDate = toDate
			localNotification.soundName = UILocalNotificationDefaultSoundName
			// UserInfo
			if options != nil{
				localNotification.userInfo = options;
			}
			// Agenda notificação
			UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
		}
	}

	/**
	Retorna todas as notificações registradas.

	:returns: [UILocalNotification] contendo todas as notificações registradas
	*/
	func getAllScheduledNotifications() -> [UILocalNotification]{
		return UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
	}

	/**
	Retorna todas as notificações, registradas, que estão conforme a closure passada por parâmetro.
	
	closure:

		{(notification : UILocalNotification) -> (Bool) in
			//Tratamento para verificar se uma determinada notificação faz parte do resultado ou não.
			//Retornar **true** para uma determinada notificação fazer parte do resultado.
			//Retornar **false** caso contrário
		}

	:param: filter {(notification : UILocalNotification) -> (Bool)}

	:returns: [UILocalNotification] contendo todas as notificações registradas filtrado a partir do closure passado.
	*/
	func getNotificationUsingFilter(filter: (notification: UILocalNotification)->(Bool)) -> [UILocalNotification]{
		return getAllScheduledNotifications().filter(filter)
	}

	/**
	Cancela uma notificação registrada

	:param: notification instancia da notificação que desja cancelar.
	*/
	func cancelSingleScheduledNotification(notification: UILocalNotification){
		UIApplication.sharedApplication().cancelLocalNotification(notification)
	}

	/**
	Cancela todas as notificações registradas
	*/
	func cancelAllScheduledNotification(){
		UIApplication.sharedApplication().cancelAllLocalNotifications()
	}
}