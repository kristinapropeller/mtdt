/**
 * Created on 13/03/2023.
 */

import {api, LightningElement} from 'lwc';
import {deleteRecord} from "lightning/uiRecordApi";
import {TimeTrackerServices} from "c/timeTrackerServices";
import UtilizationBookingModal from "c/utilizationBookingModal";
import ConfirmationModal from "c/confirmationModal";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class UtilizationGridRow extends LightningElement {
    @api viewPreset;

    _resource = {};
    _cases = [];
    _bookings = [];
    _vacations = [];
    _timeLineHeaders;
    _expanded = false;

    @api
    get resource() {
        return this._resource;
    }
    set resource(val) {
        let res = val ? {...val} : val;
        if (res) res.url = `/${res.Id}`;
        this._resource = res;
    }
    @api
    get cases() {
        return this._cases;
    }
    set cases(val) {
        this._cases = val;
    }
    @api
    get bookings() {
        return this._bookings;
    }
    set bookings(val) {
        this._bookings = val;
    }
    @api
    get vacations() {
        return this._vacations;
    }
    set vacations(val) {
        this._vacations = val;
    }
    @api
    get timeLineHeaders() {
        return this._timeLineHeaders;
    }
    set timeLineHeaders(val) {
        this._timeLineHeaders = val;
    }
    @api
    get expanded() {
        return this._expanded;
    }
    set expanded(val) {
        this._expanded = val;
    }

    get expandButtonClass() {
        return `slds-m-right_x-small ${this.assignments.length > 0 ? '' : 'slds-is-disabled'}`;
    }
    get resourceTimeline() {
        let timeline = [];
        for (let i = 0; i < this._timeLineHeaders.length; i++) {
            const cellLabel = this._timeLineHeaders[i].startDate.toLocaleDateString('en-US', this.viewPreset === 'months'
                ? {year: 'numeric', month: 'short'}
                : {year: 'numeric', month: 'short', day: '2-digit'});
            if (this.viewPreset === 'days' && this.isWeekend(this._timeLineHeaders[i].startDate)) {
                timeline.push({id: i + 1, value: '', label: cellLabel, class: 'timeline-cell timeline-cell_weekend'});
            } else {
                let cell = {id: i + 1, value: 0, label: cellLabel, class: 'timeline-cell'};
                // if (this.viewPreset === 'weeks') cell.colspan = 7;
                cell.value += this.calculateTotalSpanEfforts(
                    this._timeLineHeaders[i].startDate,
                    this._timeLineHeaders[i].endDate,
                    '_cases',
                    'Start_Date__c',
                    'Due_Date__c',
                    'ContactId',
                    'Estimated_Time__c',
                    0);
                cell.value += this.calculateTotalSpanEfforts(
                    this._timeLineHeaders[i].startDate,
                    this._timeLineHeaders[i].endDate,
                    '_bookings',
                    'Start_Date__c',
                    'End_Date__c',
                    'Contact__c',
                    'Planned_Time__c',
                    8);
                cell.value += this.calculateTotalSpanEfforts(
                    this._timeLineHeaders[i].startDate,
                    this._timeLineHeaders[i].endDate,
                    '_vacations',
                    'Vacation_Start_Date__c',
                    'Vacation_End_Date__c',
                    'Employee__c',
                    '',
                    8);
                const spanMaxEffort = this.viewPreset === 'months' ? this.getEffortForRange(this._timeLineHeaders[i].startDate, this._timeLineHeaders[i].endDate, 8) : 8;
                if (cell.value > 0) cell.class += ' ' + (cell.value < spanMaxEffort ? 'timeline-cell_underallocated' : (cell.value > spanMaxEffort ? 'timeline-cell_overallocated' : 'timeline-cell_optimallyallocated'));
                else cell.value = '';
                timeline.push(cell);
            }
        }
        return timeline;
    }

    get assignments() {
        let assignments = [];
        for (let i = 0; i < this._cases.length; i++) {
            if (this._resource.Id === this._cases[i].ContactId) {
                assignments.push(this.getAssignmentWithTimeline(
                    this._cases[i],
                    'Id',
                    'Subject',
                    'Start_Date__c',
                    'Due_Date__c',
                    'Estimated_Time__c',
                    0
                ));
            }
        }
        for (let i = 0; i < this._bookings.length; i++) {
            if (this._resource.Id === this._bookings[i].Contact__c) {
                assignments.push(this.getAssignmentWithTimeline(
                    this._bookings[i],
                    'Id',
                    'Name',
                    'Start_Date__c',
                    'End_Date__c',
                    'Planned_Time__c',
                    8
                ));
            }
        }
        for (let i = 0; i < this._vacations.length; i++) {
            if (this._resource.Id === this._vacations[i].Employee__c) {
                assignments.push(this.getAssignmentWithTimeline(
                    this._vacations[i],
                    'Id',
                    'Vacation_Type__c',
                    'Vacation_Start_Date__c',
                    'Vacation_End_Date__c',
                    '',
                    8
                ));
            }
        }
        assignments.sort((a, b) => {
            if (a.startDate < b.startDate) return -1;
            if (a.startDate > b.startDate) return 1;

            if (a.name && !b.name) return 1;
            if (!a.name && b.name) return -1;
            return a.name && b.name ? (a.name < b.name ? -1 : (a.name > b.name ? 1 : 0)) : 0;
        });
        // console.log('assignments', assignments);
        return assignments;
    }

    handleExpand(evt) {
        this._expanded = !this._expanded;
    }
    handleAddBooking(evt) {
        UtilizationBookingModal.open({
            size            : 'small',
            header          : 'New Booking',
            contactId       : this._resource.Id,
            bookingType     : 'booking',
        }).then((result) => {
            // console.log(result);
            if (result === 'saved') {
                this.handleBookingUpdated();
                this.dispatchEvent(new ShowToastEvent({
                    variant: 'success',
                    title: 'Success!',
                    message: 'Booking added.',
                }));
            }
        });
    }
    handleEditBooking(evt) {
        const recordId = evt.target.dataset.record;

        UtilizationBookingModal.open({
            size            : 'small',
            header          : 'Edit Booking',
            recordId        : recordId,
            contactId       : this._resource.Id,
        }).then((result) => {
            // console.log(result);
            if (result === 'saved') {
                this.handleBookingUpdated();
                this.dispatchEvent(new ShowToastEvent({
                    variant: 'success',
                    title: 'Success!',
                    message: 'Booking updated.',
                }));
            }
        });
    }
    handleRemoveBooking(evt) {
        const recordId = evt.target.dataset.record;

        ConfirmationModal.open({
            size            : 'small',
            header          : 'Delete Booking',
            content         : `Are you sure you want to delete this Booking?`,
            primaryButton   : 'Delete',
        }).then((result) => {
            console.log(result);
            if (result === 'primary') {
                this.deleteBooking(recordId);
            }
        });
    }
    handleBookingUpdated() {
        this.dispatchEvent(new CustomEvent('bookingsupdated'));
    }

    deleteBooking(recordId) {
        const that = this;
        deleteRecord(recordId)
            .then(() => {
                that.handleBookingUpdated();
                that.dispatchEvent(new ShowToastEvent({
                    variant: 'success',
                    title: 'Success!',
                    message: 'Booking deleted.',
                }));
            })
            .catch(error => {
                console.error(error);
                that.dispatchEvent(new ShowToastEvent({
                    variant: 'error',
                    title: 'Error!',
                    message: error.body.message,
                }));
            });
    }

    calculateTotalSpanEfforts(spanStart, spanEnd, collectionVarName, startDateField, endDateField, resourceField, effortsField, dayEffort) {
        let efforts = 0;
        for (let i = 0; i < this[collectionVarName].length; i++) {
            let endDate = new Date(this[collectionVarName][i][endDateField]);
            let startDate = this[collectionVarName][i][startDateField] ? new Date(this[collectionVarName][i][startDateField]) : endDate;
            endDate = TimeTrackerServices.addDays(endDate, 1);
            const workingDaysNum = this.calculateWorkingDays(startDate, endDate);
            if (this.viewPreset === 'days' && this._resource.Id === this[collectionVarName][i][resourceField] && spanEnd >= startDate && spanStart <= endDate) {
                efforts += effortsField && this[collectionVarName][i][effortsField] ? this.getDayEffort(this[collectionVarName][i][effortsField], workingDaysNum) : dayEffort;
            } else if (this.viewPreset === 'months' && this._resource.Id === this[collectionVarName][i][resourceField] && spanEnd >= startDate && spanStart <= endDate) {
                startDate = spanStart < startDate ? startDate : spanStart;
                endDate = spanEnd > endDate ? endDate : spanEnd;
                const workingDaysInMonth = this.calculateWorkingDays(startDate, endDate);
                // console.log('workingDaysInMonth', this[collectionVarName][i], startDate, endDate, workingDaysInMonth);
                efforts += effortsField && this[collectionVarName][i][effortsField] ? this.getMonthEffort(this[collectionVarName][i][effortsField], workingDaysNum, workingDaysInMonth) : dayEffort * workingDaysInMonth;
            }
        }
        return efforts;
    }
    getAssignmentWithTimeline(record, idField, nameField, startDateField, endDateField, effortsField, dayEffort) {
        let assignment = {
            id: record[idField],
            url: `/${record[idField]}`,
            name: record[nameField],
            startDate: new Date(record[startDateField] ? record[startDateField] : record[endDateField]),
            endDate: TimeTrackerServices.addDays(new Date(record[endDateField]), 1),
            efforts: effortsField && record[effortsField] ? record[effortsField] : 0,
            timeline: []
        };
        if (nameField === 'Subject') assignment.isCase = true;
        if (nameField === 'Vacation_Type__c') assignment.isVacation = true;
        if (!assignment.isCase && !assignment.isVacation) assignment.isBooking = true;
        if ((assignment.isCase || assignment.isBooking) && record.Project__c && record.Project__r && record.Project__r.Name) assignment.name = `${assignment.name} [${record.Project__r.Name}]`;
        const workingDaysNum = this.calculateWorkingDays(assignment.startDate, assignment.endDate);
        console.log('workingDaysNum', assignment.name, assignment.startDate, assignment.endDate, workingDaysNum);
        if (!assignment.efforts && dayEffort) assignment.efforts = dayEffort * workingDaysNum;
        for (let i = 0; i < this._timeLineHeaders.length; i++) {
            const cellLabel = this._timeLineHeaders[i].startDate.toLocaleDateString('en-US', this.viewPreset === 'months'
                ? {year: 'numeric', month: 'short'}
                : {year: 'numeric', month: 'short', day: '2-digit'});
            let cell = { id: i + 1, value: '', label: cellLabel, class: 'timeline-cell' };
            // if (this.viewPreset === 'weeks') cell.colspan = 7;
            if (this.viewPreset === 'days' && this.isWeekend(this._timeLineHeaders[i].startDate)) {
                cell.class = 'timeline-cell timeline-cell_weekend';
            } else if (this.viewPreset === 'months' && assignment.startDate <= this._timeLineHeaders[i].endDate && this._timeLineHeaders[i].startDate <= assignment.endDate) {
                const monthWorkStart = this._timeLineHeaders[i].startDate < assignment.startDate ? assignment.startDate : this._timeLineHeaders[i].startDate;
                const monthWorkEnd = this._timeLineHeaders[i].endDate > assignment.endDate ? assignment.endDate : this._timeLineHeaders[i].endDate;
                const workingDaysInMonth = this.calculateWorkingDays(monthWorkStart, monthWorkEnd);
                // console.log('workingDaysInMonth', assignment.name, monthWorkStart, monthWorkEnd, workingDaysInMonth);
                cell.value = assignment.efforts ? this.getMonthEffort(assignment.efforts, workingDaysNum, workingDaysInMonth) : 0;
            } else if (this.viewPreset === 'days' && this._timeLineHeaders[i].endDate >= assignment.startDate && this._timeLineHeaders[i].startDate <= assignment.endDate) {
                cell.value = assignment.efforts ? this.getDayEffort(assignment.efforts, workingDaysNum) : 0;
            }
            assignment.timeline.push(cell);
        }
        return assignment;
    }

    calculateWorkingDays(startDate, endDate) {
        let count = 0;
        const d = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
        const lastDate = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
        while (d < lastDate) {
            if (!this.isWeekend(d)) count++;
            d.setDate(d.getDate() + 1);
        }
        return count;
    }
    getDayEffort(efforts, daysNum) {
        return Math.round((efforts / daysNum + Number.EPSILON) * 100) / 100;
    }
    getMonthEffort(efforts, daysNum, daysNumInMonth) {
        return Math.round((efforts / daysNum * daysNumInMonth + Number.EPSILON) * 100) / 100;
    }
    getEffortForRange(startDate, endDate, dayEffort) {
        return dayEffort * this.calculateWorkingDays(startDate, endDate);
    }
    isWeekend(d) {
        return d.getDay() === 6 || d.getDay() === 0;
    }
}