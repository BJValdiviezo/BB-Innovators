import { api, LightningElement, wire } from 'lwc';
import trail from '@salesforce/apex/JSController.trail';
export default class trailView extends LightningElement {
    @api recordId;
    name;
    time;
    description;
    points;
    progress;
    error = undefined;
    modulos;
    checkmodule;
    checkunit;

    @wire(trail, { idTr: '$recordId' })
    trail(Result) {
        const { data, error } = Result;
        if (data) {
            //console.log(data);
            this.name = data.trail.Name;
            this.time = data.trail.Tiempo_Total__c;
            this.description = data.trail.Descripcion__c;
            this.points = data.trail.Puntos_Totales__c;
            this.progress = Math.round((data.passedUnitIds.length/data.trail.CantU__c)*100);
            //this.progress =  Number.parseFloat((data.passedUnitIds.length/data.trail.CantU__c)*100).toFixed(0); 
            this.modulos = data.modules;
            this.checkmodule = data.passedModuleIds;
            this.checkunit = data.passedUnitIds;
        } else if (error) {
            this.trailWrapper = undefined;
            this.error = error;
        }
    }
}    

