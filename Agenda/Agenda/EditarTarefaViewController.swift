//
//  EditarTarefaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/10/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class EditarTarefaViewController: UIViewController {

    var tarefa:Atividade!
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navItem.title = "Editar \(tarefa.nomeAtiv)"
        self.textField.text = tarefa.nomeAtiv
        self.datePicker.date = tarefa.dataEntrega
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
        
        //REGEX
        EventManager.sharedInstance.editaEvento(textField.text, nData: datePicker.date, tarefa: tarefa);
        tarefa.nomeAtiv = textField.text
        tarefa.dataEntrega = datePicker.date
        
        TarefaManager.sharedInstance.save()
        
        TarefaManager.sharedInstance.atualizaNotif(tarefa)
        
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
