global class PastVacationScheduler implements Schedulable {
    /*
	 * System.schedule('Update Past Vacations', '0 0 1 ? * *', new PastVacationScheduler());
	 */

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PastVacationBatch(), 50);
    }
}