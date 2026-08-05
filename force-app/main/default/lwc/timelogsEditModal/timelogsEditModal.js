/**
 * Created on 29/12/2022.
 */

import {api} from 'lwc';
import LightningModal from "lightning/modal";
import upsertLogs from '@salesforce/apex/TimeTrackerController.upsertLogs';
import {TimeTrackerServices} from "c/timeTrackerServices";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class TimelogsEditModal extends LightningModal {
    @api header;

    _rows = [];

    @api
    get rows() {
        return this._rows;
    }
    set rows(value) {
        this._rows = Array.isArray(value) ? value.filter(r => !!(r.logId)) : [];
    }

    get weekTotalDurationHours() {
        let totalDuration = this._rows.reduce((s, r) => ( s + r.duration ), 0);
        return TimeTrackerServices.formatDuration(totalDuration);
    }

    saveLogs() {
        const logs = this._rows.map(r => ({
            Id: r.logId,
            Effort__c: r.duration,
            Description__c: r.description,
            Work_Date__c: r.dateISO.substring(0, 10)
        }));
        upsertLogs({logsJSON: JSON.stringify(logs)})
            .then(result => {
                this.disableClose = false;
                this.close('saved');
            })
            .catch(error => {
                console.error(error);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error.message,
                        variant: "error"
                    })
                );
            });
    }

    handleDateChange(evt) {
        const rowIndex = parseInt(evt.target.dataset.row);
        let rowsTemp = JSON.parse(JSON.stringify(this._rows));
        rowsTemp[rowIndex].dateISO = evt.detail.value;
        this._rows = [];
        this._rows = rowsTemp;
    }
    handleDescriptionChange(evt) {
        const rowIndex = parseInt(evt.target.dataset.row);
        let rowsTemp = JSON.parse(JSON.stringify(this._rows));
        rowsTemp[rowIndex].description = evt.detail.value;
        console.log('rowsTemp', JSON.stringify(rowsTemp));
        this._rows = [];
        this._rows = rowsTemp;
    }
    handleDurationChange(evt) {
        const rowIndex = parseInt(evt.target.dataset.row);
        let rowsTemp = JSON.parse(JSON.stringify(this._rows));
        rowsTemp[rowIndex].durationHours = evt.detail.value;
        this._rows = [];
        this._rows = rowsTemp;
    }
    handleDurationBlur(evt) {
        const rowIndex = parseInt(evt.target.dataset.row);

        let rowsTemp = [...this._rows];
        const duration = TimeTrackerServices.parseDuration(rowsTemp[rowIndex].durationHours);
        rowsTemp[rowIndex].duration = duration;
        rowsTemp[rowIndex].durationHours = duration ? TimeTrackerServices.formatDuration(duration) : '';
        this._rows = [];
        this._rows = rowsTemp;
    }
    handleSave() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.disableClose = true;
            this.saveLogs();
        }
    }
    handleCancel() {
        this.close('cancel');
    }
}