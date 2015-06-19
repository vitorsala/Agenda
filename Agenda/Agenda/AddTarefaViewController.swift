//
//  AddTarefaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class AddTarefaViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tipoSelector: UISegmentedControl!
    
    
    var materia:Materia!
    let em:EventManager = EventManager.sharedInstance;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...7 {
            
            var localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Ver a tarefa"
            
            var diasRestantes = 7 - i
            var strNotif = "\(textField) de \(materia)"
            
            if diasRestantes == 0 {
                localNotification.alertBody = "'\(strNotif)' entrega é para hoje."
            }
            else if diasRestantes == 1 {
                localNotification.alertBody = "Falta \(diasRestantes) dia para entregar '\(strNotif)'"
            }
            else {
                localNotification.alertBody = "Faltam \(diasRestantes) dias para entregar '\(strNotif)'!"
            }
            
            
            let dateFix: NSTimeInterval = floor(datePicker.date.timeIntervalSinceReferenceDate / 60.0) * 60.0
            
            var horario: NSDate = NSDate(timeIntervalSinceReferenceDate: dateFix)
            
            let intervalo: NSTimeInterval = -NSTimeInterval(60*60*24 * (diasRestantes))
            
            localNotification.fireDate = NSDate(timeInterval: intervalo, sinceDate: horario)
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
//            var interval: NSTimeInterval = 60 * 7 + 10
//            
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: (interval - NSTimeInterval( 60 * diasRestantes)))
//            
//            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        
        //Se o usuário não permitiu que usassem o calendário anteriormente, pergunta de novo lol.
//        if(!em.verificaPermissao()){
//            em.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
//                {[weak self] (granted: Bool, error: NSError!) -> Void in
//                    if granted {
//                        println("porra ligo no granted");
//                    } else {
//                        println("Access denied")
//                    }
//                })
//        }
        
        if(em.verificaPermissao()){
            em.criaCalendario();
        }
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.textField.resignFirstResponder()
    }
    
    @IBAction func salvar(sender: AnyObject) {
        //MAIS REGEXES

		let name : String = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

		if Util.nameRegex(name){

			//salva dentro desse metodo
			TarefaManager.sharedInstance.insertNewTarefa(textField.text, disc: materia, data: datePicker.date, tipo: self.tipoSelector.selectedSegmentIndex)


			if(em.verificaPermissao()){
				em.insertEvent(datePicker.date, nome: textField.text, materia: materia.nomeMateria);
			}

			textField.text = ""

			self.navigationController?.popViewControllerAnimated(true)
		}
		else{
			let alert = UIAlertController(title: "A tarefa não foi adicionada", message: "O nome só pode possuir letras, números e espaços", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in

			}))
			self.presentViewController(alert, animated: true, completion: nil)
		}
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
