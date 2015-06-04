//
//  AgendaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/2/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

//Classe para auxiliar a criação e controle de sections.
class DataQtd {
    var data:NSDate;
    var qtd:NSMutableArray;
    
    init(datinha: NSDate){
        data = datinha;
        qtd = NSMutableArray();
    }
}

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //0 - FUTURAS;   1 - RECENTES
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var atividades:NSMutableArray!
    var dias:NSMutableArray!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        atividades = NSMutableArray(array: TarefaManager.sharedInstance.fetchTarefasFuturas())
        
        //Array de DataQtd pro auxilio das sections.
        dias = NSMutableArray();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentButton(sender: AnyObject) {

        if self.segmentControl.selectedSegmentIndex == 0 {
            atividades = NSMutableArray(array: TarefaManager.sharedInstance.fetchTarefasFuturas())
        }
        else {
            atividades = NSMutableArray(array: TarefaManager.sharedInstance.fetchTarefasPassadas())
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //Por algum motivo, esse método é chamado 4 vezes quando essa view é criada pela primeira vez. Essa linha resolve o problema de calculo erroneo de sections.
        dias = NSMutableArray();
        
        //Usado pra ver se os dias são os mesmos.
        //O comparador de dias lá tava dando ruim, ai desse jeito fica mais prático.
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy";
        
        for a in atividades{
            if(dias.firstObject == nil){
                dias.addObject(DataQtd(datinha: (a as! Atividade).dataEntrega));
                (dias.objectAtIndex(dias.count - 1) as! DataQtd).qtd.addObject(a);
            } else if(dateFormatter.stringFromDate((dias.lastObject! as! DataQtd).data) == dateFormatter.stringFromDate((a as! Atividade).dataEntrega)){
                //Se os dias são iguais, bota a atividade naquele dia.
                (dias.objectAtIndex(dias.count - 1) as! DataQtd).qtd.addObject(a);
                
            } else {
                //Se não, adiciona um novo dia.
                dias.addObject(DataQtd(datinha: (a as! Atividade).dataEntrega));
                (dias.objectAtIndex(dias.count - 1) as! DataQtd).qtd.addObject(a);
            }
        }
        return dias.count;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy";
        
        return dateFormatter.stringFromDate((dias.objectAtIndex(section) as! DataQtd).data);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dias.objectAtIndex(section) as! DataQtd).qtd.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCellWithIdentifier("tarefaCelula") as! TarefasCell
        
        let ativ = (dias.objectAtIndex(indexPath.section) as! DataQtd).qtd.objectAtIndex(indexPath.row) as! Atividade;
        
        if self.segmentControl.selectedSegmentIndex == 1 {
            //se for trabalho
            if ativ.tipoAtiv == 1 {
                //se o trabalho nao tiver sido entregue, e seu prazo ja tiver passado
                if ativ.entregue == 0 {
                    cell.backgroundColor = UIColor.redColor()
                }
            }
        }
        
        cell.textLabel?.text = ativ.nomeAtiv
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm";
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(ativ.dataEntrega);
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ativ = (dias.objectAtIndex(indexPath.section) as! DataQtd).qtd.objectAtIndex(indexPath.row) as! Atividade;
        //se for atividade futura
        if self.segmentControl.selectedSegmentIndex == 0 {
            //se for prova
            if ativ.tipoAtiv == 0 {
                //não tem nada pra fazer se for uma prova futura - nao da pra "entregar", e tambem nao tem nota pra dar ainda
                return
            }
        }
        let statusVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StatusVC") as! StatusTarefaViewController
        statusVC.tarefa = ativ
        self.navigationController?.pushViewController(statusVC, animated: true)
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
