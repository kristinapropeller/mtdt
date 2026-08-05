/**
 * Created on 13/03/2023.
 */

import {LightningElement} from 'lwc';
import {TimeTrackerServices} from "c/timeTrackerServices";
import getResourcesWithAssignments from "@salesforce/apex/ResourceUtilizationController.getResourcesWithAssignments";

export default class ResourceUtilization extends LightningElement {
    viewPreset = 'days';
    resources = [];
    cases = [];
    bookings = [];
    vacations = [];
    isBusy = true;

    _timelineFirstDate = TimeTrackerServices.getMonday(new Date());
    _timelineLastDate = TimeTrackerServices.addDays(this._timelineFirstDate, 5 * 7);

    get isDaysPreset() {
        return this.viewPreset === 'days';
    }
    get isWeeksPreset() {
        return this.viewPreset === 'weeks';
    }
    get isMonthsPreset() {
        return this.viewPreset === 'months';
    }
    get timelineHeaderLevelOne() {
        let headers = [];
        // let lastMonth;
        let lastYear;
        switch (this.viewPreset) {
            case 'months':
                for (let i = 0; i < 13; i++) {
                    const monthStart = new Date(this._timelineFirstDate.getFullYear(), this._timelineFirstDate.getMonth() + i, 1);
                    if (!lastYear || lastYear !== monthStart.getFullYear()) {
                        headers.push({
                            startDate: monthStart,
                            endDate: new Date(monthStart.getFullYear(), monthStart.getMonth() + 1, 0),
                            label: monthStart.toLocaleDateString('en-US', {year: 'numeric'}),
                            colspan: 1
                        });
                    } else {
                        headers[headers.length - 1].endDate.setMonth(headers[headers.length - 1].endDate.getMonth() + 1);
                        headers[headers.length - 1].colspan++;
                    }
                    lastYear = monthStart.getFullYear();
                }
                break;
            case 'weeks':
                // for (let i = 0; i < 12 * 7; i++) {
                //     const d = TimeTrackerServices.addDays(this._timelineFirstDate, i);
                //     if (!lastMonth || lastMonth !== d.getMonth()) {
                //         headers.push({
                //             value: d,
                //             label: d.toLocaleDateString('en-US', {year: 'numeric', month: 'short'}),
                //             colspan: 1
                //         });
                //     } else {
                //         headers[headers.length - 1].colspan++;
                //     }
                //     lastMonth = d.getMonth();
                // }
                // break;
            default:
                for (let i = 0; i < 6; i++) {
                    const weekStart = TimeTrackerServices.addDays(this._timelineFirstDate, i * 7);
                    headers.push({
                        startDate: weekStart,
                        endDate: TimeTrackerServices.addDays(weekStart, 6),
                        label: weekStart.toLocaleDateString('en-US', {year: 'numeric', month: 'short', day: '2-digit'}),
                        colspan: 7
                    });
                }
        }
        return headers;
    }
    get timelineHeaderLevelTwo() {
        let headers = [];
        switch (this.viewPreset) {
            case 'months':
                for (let i = 0; i < 13; i++) {
                    const monthStart = new Date(this._timelineFirstDate.getFullYear(), this._timelineFirstDate.getMonth() + i, 1);
                    headers.push({
                        startDate: monthStart,
                        endDate: new Date(monthStart.getFullYear(), monthStart.getMonth() + 1, 0),
                        label: monthStart.toLocaleDateString('en-US', {year: 'numeric', month: 'short'}),
                        class: 'timeline-header-two timeline-header-two_month slds-text-align_center'
                    });
                }
                break;
            case 'weeks':
                // for (let i = 0; i < 12; i++) {
                //     const d = TimeTrackerServices.addDays(this._timelineFirstDate, i * 7);
                //     headers.push({
                //         value: d,
                //         label: d.toLocaleDateString('en-US', {month: 'short', day: '2-digit'}),
                //         colspan: 7
                //     });
                // }
                // break;
            default:
                for (let i = 0; i < 6 * 7; i++) {
                    const d = TimeTrackerServices.addDays(this._timelineFirstDate, i);
                    headers.push({
                        startDate: d,
                        endDate: d,
                        label: d.toLocaleDateString('en-US', {weekday: 'narrow'}),
                        class: 'timeline-header-two timeline-header-two_day slds-text-align_center'
                    });
                }
        }
        return headers;
    }

    connectedCallback() {
        this.loadUtilizationData();
    }

    handleChangeView(evt) {
        this.isBusy = true;
        this.viewPreset = evt.detail.value;
        this.handleThisClick();
    }
    handleShiftLeft(evt) {
        switch (this.viewPreset) {
            case 'months':
                this._timelineFirstDate = TimeTrackerServices.addMonths(this._timelineFirstDate, -1);
                this._timelineLastDate = TimeTrackerServices.addMonths(this._timelineFirstDate, 13);
                break;
            case 'weeks':
            default:
                this._timelineFirstDate = TimeTrackerServices.addDays(this._timelineFirstDate, -7);
                this._timelineLastDate = TimeTrackerServices.addDays(this._timelineFirstDate, 5 * 7);
        }
        this.loadUtilizationData();
    }
    handleThisClick(evt) {
        const now = new Date();
        switch (this.viewPreset) {
            case 'months':
                this._timelineFirstDate = new Date(now.getFullYear(), now.getMonth(), 1);
                this._timelineLastDate = TimeTrackerServices.addMonths(this._timelineFirstDate, 13);
                break;
            case 'weeks':
            default:
                this._timelineFirstDate = TimeTrackerServices.getMonday(new Date());
                this._timelineLastDate = TimeTrackerServices.addDays(this._timelineFirstDate, 5 * 7);
        }
        this.loadUtilizationData();
    }
    handleShiftRight(evt) {
        switch (this.viewPreset) {
            case 'months':
                this._timelineFirstDate = TimeTrackerServices.addMonths(this._timelineFirstDate, 1);
                this._timelineLastDate = TimeTrackerServices.addMonths(this._timelineFirstDate, 13);
                break;
            case 'weeks':
            default:
                this._timelineFirstDate = TimeTrackerServices.addDays(this._timelineFirstDate, 7);
                this._timelineLastDate = TimeTrackerServices.addDays(this._timelineFirstDate, 5 * 7);
        }
        this.loadUtilizationData();
    }
    handleRefreshClick(evt) {
        this.isBusy = true;
        this.loadUtilizationData();
    }
    handleBookingsUpdate(evt) {
        this.loadUtilizationData();
    }

    loadUtilizationData() {
        getResourcesWithAssignments({
            dateFrom    : this._timelineFirstDate.toISOString().substring(0, 10),
            dateTo      : this._timelineLastDate.toISOString().substring(0, 10)
        })
            .then(result => {
                const data = result || {};
                console.log('loadUtilizationData', data);

                this.cases = data.cases;
                this.bookings = data.bookings;
                this.vacations = data.vacations;
                this.resources = data.resources;
                this.isBusy = false;
            })
            .catch(error => {
                console.error(error);
            });
    }
}