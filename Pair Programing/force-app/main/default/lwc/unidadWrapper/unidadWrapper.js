import { LightningElement, wire, api, track } from 'lwc';
import { MessageContext} from 'lightning/messageService';
import obtenerUnidad from '@salesforce/apex/UnitService.obtenerUnidad';
import usuarioUnidadRegistrar from '@salesforce/apex/UnitService.usuarioUnidadRegistrar';

export default class unidadWrapper extends LightningElement {
    @api recordId;

    unit;
    questionList;
    _wireResult;
    subscription = null;
    points;
    name;
    time;
    description;
    preguntas;

    @wire(MessageContext)
    messageContext;


    @wire(obtenerUnidad, { idU: '$recordId' })
    unitdata(result) {
        const { data, error } = result;
        this._wireResult = result;

        console.log();
        if (data) {
            this.unit = data.unit;
            //this.questionList = data.isCompleted ? undefined : data.QuestionList;
            this.name = this.unit.Name;
            this.points = this.unit.Puntos__c;
            this.time = this.unit.Tiempo__c;
            this.description = this.unit.Contenido__c;
            console.log("==================================Empieza 1==================================");
            console.log(this.description);
            console.log("finaliza 1");
            console.log("==================================Empieza 2==================================");
            console.log(this.unit.Contenido__c);
            console.log("finaliza 2");
            this.preguntas = data.questions;
            console.log('kkkkkkk' +
                JSON.stringify(this.preguntas));

        }

    }
    @track
    optionSelected = [];
    optionSelectedjson = {};
    answerSelected(event) {

        console.log(JSON.stringify(event.detail) + 'detail event');
        this.optionSelectedjson[event.detail.questionId] = event.detail.optionId;
        console.log('objeto' + JSON.stringify(this.optionSelectedjson));
        this.optionSelected = Object.values(this.optionSelectedjson);
        console.log('arraypadre' + this.optionSelected);
    }

    handleSubmit(event) {
        usuarioUnidadRegistrar({
                uId: this.recordId,
                strJs: JSON.stringify(this.optionSelectedjson)
            })
            .catch((error) => {
                console.log(error)
            })
    }
}