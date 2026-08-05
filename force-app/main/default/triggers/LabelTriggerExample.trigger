trigger LabelTriggerExample on Contact (before insert) {
    for (Contact c : Trigger.new) {
        c.Description = Label.HOHO_LABEL;
    }
}