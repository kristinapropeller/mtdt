/**
 * Created on 19/03/2023.
 */

import {api, wire} from 'lwc';
import {getRecord} from "lightning/uiRecordApi";
import LightningModal from "lightning/modal";

export default class UtilizationBookingModal extends LightningModal {
    @api recordId;
    @api contactId;
    @api header;

    @api
    get bookingType() {
        return this._bookingType;
    }
    set bookingType(val) {
        this._bookingType = val;
    }

    typeOptions = [
        { label: 'Booking', value: 'booking' },
        { label: 'Vacation', value: 'vacation' },
    ];
    _bookingType;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Compact'], modes: ['View'] })
    wiredRecord;

    get isBooking() {
        return this._bookingType === 'booking' || (this.wiredRecord && this.wiredRecord.data && this.wiredRecord.data.apiName === 'Booking__c');
    }
    get isVacation() {
        return this._bookingType === 'vacation' || (this.wiredRecord && this.wiredRecord.data && this.wiredRecord.data.apiName === 'Vacation__c');
    }

    handleTypeChange(evt) {
        this._bookingType = evt.detail.value;
    }
    handleSaveSuccess(evt) {
        this.disableClose = false;
        this.close('saved');
    }
    handleSaveError(evt) {
        this.disableClose = false;
    }

    handleSave() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input-field'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && (!inputCmp.required || (typeof inputCmp.value !== "undefined" && inputCmp.value !== null));
        }, true);
        if (allValid) {
            this.disableClose = true;
            this.template.querySelector('lightning-record-edit-form').submit();
        }
    }
    handleCancel() {
        this.close('cancel');
    }
}