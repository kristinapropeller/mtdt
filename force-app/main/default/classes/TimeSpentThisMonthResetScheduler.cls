global class TimeSpentThisMonthResetScheduler implements Schedulable {

	/*
	 * System.schedule('Test time reset', '0 57 * * * ?', new TimeSpentThisMonthResetScheduler());
	 */

	global void execute(SchedulableContext sc) {
		Database.executeBatch(new TimeSpentThisMonthBatch(), 50);
	}
}