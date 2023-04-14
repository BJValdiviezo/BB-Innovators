import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class unidadView extends NavigationMixin (LightningElement)  {
    @api unit
    @api checkunit

    get Testunit() {
        return this.checkunit.includes(this.unit.Id);

    }
    ViewUnit(event) {
        console.log('entre en el boton')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.dataset.prop,
                "objectApiName": "Unidad__c",
                "actionName": "view"
            },
        });

    }
}