/**
 * Created on 29/12/2022.
 */

import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ConfirmationModal extends LightningModal {
    @api header;
    @api content;
    @api secondaryButton = 'Cancel';
    @api primaryButton = 'OK';

    handlePrimary() {
        this.close('primary');
    }
    handleSecondary() {
        this.close('secondary');
    }
}