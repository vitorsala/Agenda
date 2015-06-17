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
        
        //salva dentro desse metodo
        TarefaManager.sharedInstance.insertNewTarefa(textField.text, disc: materia, data: datePicker.date, tipo: self.tipoSelector.selectedSegmentIndex)
        
        
        if(em.verificaPermissao()){
            em.insertEvent(datePicker.date, nome: textField.text, materia: materia.nomeMateria);
        }
        
        
        //mandei tudo pro TarefaManager
//        //cria notif
//        let ud = NSUserDefaults.standardUserDefaults()
//        for i in 0...7 {
//            
//            //montando o horario correto - favor testar
//            var dia = NSDate()
//            var unitFlags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit |  NSCalendarUnit.DayCalendarUnit
//            var calendar = NSCalendar.currentCalendar()
//            var comps = calendar.components(unitFlags, fromDate: dia)
//            comps.day -= i
//            comps.hour = calendar.component(NSCalendarUnit.HourCalendarUnit, fromDate: (ud.valueForKey("horaAlerta") as! NSDate))
//            comps.minute = calendar.component(NSCalendarUnit.MinuteCalendarUnit, fromDate: (ud.valueForKey("horaAlerta") as! NSDate))
//            comps.second = 0
//            var newDate = calendar.dateFromComponents(comps)
//            
//            var message:String
//            
//            if i == 0 {
//                message = "A data da atividade é hoje!"
//            }
//            else if i == 1 {
//                message = "Falta um dia para a data d atividade."
//            }
//            else{
//                message = "Faltam \(i) dias para a data da atividade."
//            }
//            
//            LocalNotificationManager.sharedInstance.scheduleNewNotification(title: "\(self.materia.nomeMateria): \(textField.text)", msg: message, action: "Nem sei o que vem aqui", options: [], toDate: <#NSDate#>)
//        }
        
        
        textField.text = ""
        
        self.navigationController?.popViewControllerAnimated(true)
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
