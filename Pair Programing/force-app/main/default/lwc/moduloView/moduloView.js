import { api, LightningElement } from 'lwc';

export default class moduloView extends LightningElement {
    @api name;
    @api time;
    @api description;
    @api points;
    @api modulo;
    @api checkmodule;
    @api checkunit;

    get Testmodule() {

        console.log('esto es check unit' + this.checkunit);
        return this.checkmodule.includes(this.modulo.Id);
    }
}