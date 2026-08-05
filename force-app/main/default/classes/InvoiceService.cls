public class InvoiceService {

	/* -------------------------------------------------------------------------------------------------------------------- */
	/*  CONSTANTS  */
	/* -------------------------------------------------------------------------------------------------------------------- */
	private static final String INVOICE_STATUS_DRAFT = 'Draft';
	private static final String INVOICE_DEFAULT_TERMS = '30 days';
	private static final String INVOICE_PL_REMARKS = 'Reverse charge - VAT is charged to the buyer.\n' +
			'Do rozliczenia podatku VAT zobowiązany jest nabywca usługi (odwrotne obciążenie).';
	private static final String INVOICE_PL_VAT_RATE = 'np';


	private static final String INVOICE_LINE_ITEM_TYPE_DEVELOPMENT = 'Development';
	private static final String INVOICE_LINE_ITEM_DEFAULT_UNIT = 'h.';

	private static final Map<String, List<String>> DIGITS = new Map<String, List<String>>{
			'EN' => new List<String>{'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'},
			'PL' => new List<String>{'zero', 'jeden', 'dwa', 'trzy', 'cztery', 'pięć', 'sześć', 'siedem', 'osiem', 'dziewięć'}
	};
	private static final Map<String, List<String>> TEENS = new Map<String, List<String>>{
			'EN' => new List<String>{'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'},
			'PL' => new List<String>{'dziesięć', 'jedenaście', 'dwanaście', 'trzynaście', 'czternaście', 'piętnaście', 'szesnaście', 'siedemnaście', 'osiemnaście', 'dziewiętnaście'}
	};
	private static final Map<String, List<String>> TENS = new Map<String, List<String>>{
			'EN' => new List<String>{'', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'},
			'PL' => new List<String>{'', '', 'dwadzieścia', 'trzydzieści', 'czterdzieści', 'pięćdziesiąt', 'sześćdziesiąt', 'siedemdziesiąt', 'osiemdziesiąt', 'dziewięćdziesiąt'}
	};
	private static final List<String> HUNDREDS_PL = new List<String>{'', 'sto', 'dwieście', 'trzysta', 'czterysta', 'pięćset', 'sześćset', 'siedemset', 'osiemset', 'dziewięćset'};
	private static final List<String> PLACES_EN = new List<String>{'hundred', 'thousand'};
	private static final List<List<String>> PLACES_PL = new List<List<String>>{
			new List<String>(),
			new List<String>{'tysięcy', 'tysiąc', 'tysiące', 'tysiące', 'tysiące', 'tysięcy', 'tysięcy', 'tysięcy', 'tysięcy', 'tysięcy'}
	};
	private static final Map<String, String> JUNCTION_WORD = new Map<String, String>{
			'EN' => 'and',
			'PL' => 'i'
	};


	public static void prepareInvoices() {
		Set<Id> invoices = InvoiceService.generateInvoices();
		Database.executeBatch(new InvoiceGenerationScheduler(invoices), Test.isRunningTest() ? 200 : 1);

	}

	@future(callout = true)
	public static void generateInvoicesPDF(Set<Id> invoiceIds) {
		if (invoiceIds == null || invoiceIds.isEmpty()) {
			return;
		}
		List<Invoice__c> invoices = new pp_Query('Invoice__c')
				.selectAllFields()
				.selectAllFields('Account__r')
				.selectAllFields('Billed_To__r')
				.selectAllFields('Billed_By__r')
				.selectAllFields('Payee_Bank_Account__r')
				.selectAllFields('Payee_Bank_Account__r.Bank__r')
				.selectAllFields('Payee_Bank_Account__r.Bank__r.Account__r')
				.addSubquery(
						pp_Query.subquery('Invoice_Line_Items__r')
								.selectAllFields()
				)
				.byId(invoiceIds)
				.run();
		for (Invoice__c inv: invoices) {
			try {
				if (!Test.isRunningTest()) PDFMonkeyConnector.ResponseDocument result = PDFMonkeyConnector.createDocument('8E339346-F647-4FE3-A986-7FAD1BD71F37', inv.Invoice_Number__c.replaceAll('/', '_') + '.pdf', inv.Id, prepareMapping(inv));
			} catch (pp_RestExplorer.ErrorResponseException ex) {
				pp_R.debug.run(ex.getMessage());
			}
		}
	}

	public static Set<Id> generateInvoices() {
		Date fromDate = Date.today().addMonths(-1).toStartOfMonth();
		Date toDate = Date.today().toStartOfMonth().addDays(-1);
		Set<Id> activeProjects = InvoiceService.getActiveByDateProjects(fromDate, toDate);
		return InvoiceService.generateInvoices(activeProjects, fromDate, toDate);
	}

	public static Set<Id> generateInvoices(Set<Id> projectIds, Date fromDate, Date toDate) {
		if (projectIds.isEmpty() || fromDate == null || toDate == null) {
			return new Set<Id>();
		}
		List<pp_MObject> mos = new List<pp_MObject>();
		List<AggregateResult> results = selectNonInternalByDatesGroupByProject(fromDate, toDate);
		Map<String, Object> accountProjects = pp_R.of(new pp_Query('Project__c')
						.selectAllFields()
						.selectAllFields('Account__r')
						.byId(projectIds)
						.run())
				.groupBy(pp_R.prop.apply('Account__c'))
				.toMap();
		Setting__c setting = Setting__c.getOrgDefaults();
		pp_Moment today = new pp_Moment(System.today());
		Boolean isFirstWorkingDayOfMonth = today.day() == 1 || today.dayOfWeek() == 1;
		if (setting.PL_Invoice_Monthly_Counter__c == null || (isFirstWorkingDayOfMonth && !setting.Prevent_Next_PL_Counter_Reset__c)) {
			setting.PL_Invoice_Monthly_Counter__c = 0;
		}
		Integer counter = (Integer)setting.PL_Invoice_Monthly_Counter__c;
		for (String accountId: accountProjects.keySet()) {
			List<Project__c> projects = (List<Project__c>)pp_R.of(accountProjects.get(accountId)).toSObjectList();
			if (projects.isEmpty()) {
				continue;
			}
			if (projects.get(0).Account__r.Contractor_Need_Formatted_Invoice_Number__c && projects.get(0).Account__r.Contractor_Country_Code__c == 'PL') {
				counter++;
			}
			pp_MObject moInvoice = InvoiceService.generateNewInvoice(fromDate, toDate, projects, counter);
			List<pp_MObject> moInvoiceLines = InvoiceService.generateNewLineItems(projects, results);
			Decimal totalTimePerInvoice = 0;
			for (pp_MObject li : moInvoiceLines) {
				totalTimePerInvoice += (Decimal)li.get('Time_Spent__c');
			}
			if (projects.get(0).Account__r.Contractor_Need_Formatted_Invoice_Number__c
					&& projects.get(0).Account__r.Contractor_Country_Code__c == 'PL'
					&& totalTimePerInvoice < setting.Invoice_Minimum_Time_to_Bill__c) {
				moInvoice.put('Invoice_Number__c', 'Draft');
				counter--;
			}
			moInvoice.put('Invoice_Line_Items__r', moInvoiceLines);
			mos.add(moInvoice);
		}
		pp_MObject.persist(mos);
		Set<Id> invoiceIds = new Set<Id>();
		for (pp_MObject mo : mos) {
			invoiceIds.add((Id)mo.get('Id'));
		}
		setting.PL_Invoice_Monthly_Counter__c = counter;
		setting.Prevent_Next_PL_Counter_Reset__c = false;
		upsert setting;
		return invoiceIds;
	}

	// Convert an amount to string in words
	public static String convertAmountToWords(Decimal amount, String lang) {
		if (amount == 0) return DIGITS.get(lang)[0];

		Integer integerPart = Integer.valueOf(amount);
		Integer fractionalPart = Integer.valueOf((amount - integerPart) * 100);

		String integerWords = convertIntegerToWords(integerPart, lang);
		String fractionalWords = '.' + String.valueOf(fractionalPart).leftPad(2, '0');

		return integerWords + ' ' + JUNCTION_WORD.get(lang) + ' ' + fractionalWords;
	}

	// Convert an integer to words
	private static String convertIntegerToWords(Integer amount, String lang) {
		if (amount == 0) return '';

		String result = '';
		Integer placesCounter = 0;
		while (amount > 0) {
			Integer digit = Math.mod(amount, 1000);
//			R.debug.run('convertIntegerToWords', amount, digit);
			if (lang == 'PL') result = convertDigitToWords(digit, lang) + (placesCounter > 0 ? ' ' + PLACES_PL[placesCounter][(digit != 1 && Math.mod(digit, 10) == 1) || (Math.mod(digit, 100) > 10 && Math.mod(digit, 100) < 20) ? 0 : Math.mod(digit, 10)] : '') + ' ' + result;
			else result = convertDigitToWords(digit, lang) + (placesCounter > 0 ? ' ' + PLACES_EN[placesCounter] : '') + ' ' + result;
			amount = amount / 1000;
			placesCounter++;
		}

		return result.normalizeSpace().trim();
	}

	// Convert a digit to words
	private static String convertDigitToWords(Integer amount, String lang) {
		if (amount == 0) return '';

		String result = '';
		Boolean initialAmountHasHundreds = amount >= 100;
		while (amount > 0) {
			Integer digit = Math.mod(amount, 100);
//			R.debug.run('convertDigitToWords', amount, digit);
			if (digit >= 20) {
				result = TENS.get(lang)[digit / 10] + (Math.mod(digit, 10) > 0 ? ' ' + DIGITS.get(lang)[Math.mod(digit, 10)] : '') + ' ' + result;
			} else if (digit >= 10) {
				result = TEENS.get(lang)[Math.mod(digit, 10)] + ' ' + result;
			} else if (digit > 0) {
				if (lang == 'PL') result = (initialAmountHasHundreds && amount < 10 ? HUNDREDS_PL[digit] : DIGITS.get(lang)[digit]) + ' ' + result;
				else result = DIGITS.get(lang)[digit] + (initialAmountHasHundreds && amount < 10 ? ' ' + PLACES_EN[digit / 10] : '') + ' ' + result;
			}
			amount = amount / 100;
		}

		return result.normalizeSpace().trim();
	}

	private static pp_MObject generateNewInvoice(Date fromDate, Date toDate, List<Project__c> projects, Integer counter) {
		Invoice__c invoice = new Invoice__c(
				Working_Period_Start__c = fromDate,
				Working_Period_End__c = toDate,
				Status__c = INVOICE_STATUS_DRAFT,
				Terms__c = INVOICE_DEFAULT_TERMS,
				Account__c = projects.get(0).Account__c,
				Submission_Date__c = Date.today(),
				Billed_By__c = projects.get(0).Account__r.Billing_Contact__c,
				Billed_To__c = projects.get(0).Account__r.Contractor__c,
				Payee_Bank_Account__c = projects.get(0).Account__r.Contractor_Bank_Account__c,
				CurrencyIsoCode = projects.get(0).Account__r.CurrencyIsoCode,
				Invoice_Title__c = String.format('SFDC development on demand for {0} - {1}', new List<String>{
						Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0))
								.format('MM/d/YYYY'),
						Datetime.newInstance(toDate, Time.newInstance(0, 0, 0, 0))
								.format('MM/d/YYYY')
				})
		);
		Datetime todayDatetime = Datetime.newInstance(toDate.year(), toDate.month(), toDate.day());
		if (projects.get(0).Account__r.Contractor_Country_Code__c == 'PL') {
			if (projects.get(0).Account__r.Contractor_Need_Formatted_Invoice_Number__c) {
				invoice.Invoice_Number__c = String.format('FV-{0}/{1}/{2}', new List<String>{
						String.valueOf(invoice.Working_Period_End__c.year()).substring(2, 4),
						String.valueOf(invoice.Working_Period_End__c.month()).leftPad(2, '0'),
						String.valueOf(counter)
				});
			}
			invoice.Comments__c = INVOICE_PL_REMARKS;
		} else if (projects.get(0).Account__r.Agreement_Number__c != null) {
			invoice.Invoice_Number__c = String.format(
					'{0}-INV-{1}',
					new List<String>{projects.get(0).Account__r.Agreement_Number__c,
							String.valueOf(todayDatetime.format('MMyy'))});
		}
		return pp_MObject.create(invoice);
	}

	private static List<pp_MObject> generateNewLineItems(List<Project__c> projects, List<AggregateResult> results) {
		List<Invoice_Line_Item__c> lineItems = new List<Invoice_Line_Item__c>();
		for (Project__c project: projects) {
			Invoice_Line_Item__c line = new Invoice_Line_Item__c(
					Project__c = project.Id,
					Rate__c = project.Rate__c,
					Unit__c = INVOICE_LINE_ITEM_DEFAULT_UNIT,
					Time_Spent__c = InvoiceService.getTimespentByProjectId(results, project.Id),
					Type__c = INVOICE_LINE_ITEM_TYPE_DEVELOPMENT,
					CurrencyIsoCode = project.Account__r.CurrencyIsoCode
			);
			lineItems.add(line);
		}
		return pp_MObject.createList(lineItems);
	}


	private static Decimal getTimespentByProjectId(List<AggregateResult> results, Id projectId) {
		if (projectId == null) {
			return 0;
		}
		for (AggregateResult result: results) {
			if (result.get('Project__c') == projectId) {
				return (Decimal) result.get('effort');
			}
		}
		return 0;
	}

	private static Set<Id> getActiveByDateProjects(Date fromDate, Date toDate) {
		Set<Id> activeProjects = new Set<Id>();
		List<AggregateResult> results = selectNonInternalByDatesGroupByProject(fromDate, toDate);
		for (AggregateResult result: results) {
			if ((Decimal) result.get('effort') > 0) {
				activeProjects.add((Id) result.get('Project__c'));
			}
		}
		return activeProjects;
	}

	private static List<AggregateResult> selectNonInternalByDatesGroupByProject(Date fromDate, Date toDate) {
		Id ignoringRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
		if (ignoringRecordType == null) {
			throw new Exceptions.MissingDataException();
		}
		return new pp_Query('Timecard__c')
				.selectField('Case__r.Project__c')
//				.sum('Effort__c', 'effort') commented 01/06/2024 artsiom
				.sum('Effort_with_Coefficient__c', 'effort')
				.addConditionGe('Work_Date__c', fromDate)
				.addConditionLe('Work_Date__c', toDate)
				.addConditionNotEq('Case__r.Project__r.Account__r.RecordTypeId', ignoringRecordType)
				.groupBy('Case__r.Project__c')
				.aggregate();
	}

	private static List<Timecard__c> selectByDates(Date fromDate, Date toDate) {
		return new pp_Query('Timecard__c')
				.selectField('Case__r.Project__c')
				.selectField('Id')
				.selectField('Project__c')
				.selectField('Invoice_Line_Item__c')

				.addConditionGe('Work_Date__c', fromDate)
				.addConditionLe('Work_Date__c', toDate)
				.addConditionNull('Invoice_Line_Item__c')
				.run();

//		[SELECT Id, Case__r.Project__c
//		FROM Timecard__c
//		WHERE Work_Date__c >=: fromDate AND Work_Date__c <=: toDate
//		];
	}

	public static void linkTimeCardsToInvoiceLineItems(Set<Id> invoiceIds) {
		List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Invoice__c, Invoice__r.Working_Period_Start__c, Invoice__r.Working_Period_End__c, Project__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoiceIds];
		if (invoiceLineItems.size() == 0) return;
		System.debug('invoiceLineItems: ' + invoiceLineItems.size());
		Map<Id, Id> invoiceLineItemsByProjectIdMap = new Map<Id, Id>();
		for (Invoice_Line_Item__c invoiceLineItem : invoiceLineItems) {
			invoiceLineItemsByProjectIdMap.put(invoiceLineItem.Project__c, invoiceLineItem.Id);
		}
		Date fromDate = invoiceLineItems[0].Invoice__r.Working_Period_Start__c;
		Date toDate =invoiceLineItems[0].Invoice__r.Working_Period_End__c;
		System.debug('fromDate: ' + fromDate + ', toDate: ' + toDate + ', invoiceLineItemsByProjectIdMap: ' + invoiceLineItemsByProjectIdMap.size());

		List<Timecard__c> timeCards = selectByDates(fromDate, toDate);
		List<Timecard__c> timeCardsToUpdate = new List<Timecard__c>();
		System.debug('timeCards: ' + timeCards.size());
		for (Timecard__c timecard : timeCards) {
			if (timecard.Invoice_Line_Item__c != null) continue;
			System.debug('timecard: ' + timecard);
			System.debug('timecard.Project__c: ' + timecard.Project__c);
			System.debug('timecard.Case__r.Project__c: ' + timecard.Case__r.Project__c);

			if (invoiceLineItemsByProjectIdMap.get(timecard.Case__r.Project__c) != null) {
				timecard.Invoice_Line_Item__c = invoiceLineItemsByProjectIdMap.get(timecard.Case__r.Project__c);
				timeCardsToUpdate.add(timecard);
			}
		}

		if (timeCardsToUpdate.size() > 0) {
			System.debug('updating timeCardsToUpdate: ' + timeCardsToUpdate.size());
			update timeCardsToUpdate;

		}
	}

	public static Map<String, Object> prepareMapping(Invoice__c inv) {
		Map<String, Map<String, Map<String, String>>> allTranslations = PDFMonkeyConnector.getTranslations();
		Map<String, Map<String, String>> translationsForInvoice = allTranslations.get(inv.Payee_Country_Code__c);
		pp_Mapper.DTO d = (pp_Mapper.DTO)new pp_Mapper()
				.mapFields(new Map<String, Object>{
						'format' => 'Payee_Country_Code__c',
						'payer_name' => 'Account__r.Account_Legal_Name__c',
						'payer_billing_street' => 'Account__r.BillingStreet',
						'payer_billing_city' => 'Account__r.BillingCity',
						'payer_billing_state' => 'Account__r.BillingState',
						'payer_billing_zip' => 'Account__r.BillingPostalCode',
						'payer_billing_country' => 'Account__r.BillingCountry',
						'payer_vat_number' => 'Account__r.VAT_Number__c',
						'payee_name' => 'Payee_Bank_Account__r.Bank__r.Account__r.Account_Legal_Name__c',
						'payee_billing_street' => 'Payee_Bank_Account__r.Bank__r.Account__r.BillingStreet',
						'payee_billing_city' => 'Payee_Bank_Account__r.Bank__r.Account__r.BillingCity',
						'payee_billing_state' => 'Payee_Bank_Account__r.Bank__r.Account__r.BillingState',
						'payee_billing_zip' => 'Payee_Bank_Account__r.Bank__r.Account__r.BillingPostalCode',
						'payee_billing_country' => 'Payee_Bank_Account__r.Bank__r.Account__r.BillingCountry',
						'payee_vat_number' => 'Payee_Bank_Account__r.Bank__r.Account__r.VAT_Number__c',
						'invoice_date' => 'Submission_Date__c',
						'service_date' => 'Working_Period_End__c',
						'invoice_number' => 'Invoice_Number__c',
						'invoice_title' => 'Invoice_Title__c',
						'net_amount' => 'Total__c',
						'total_amount' => 'Total__c',
						'total_in_words' => 'Total_In_Words__c',
						'remarks' => 'Comments__c',
						'currency' => 'CurrencyIsoCode',
						'bank_name' => 'Payee_Bank_Account__r.Bank__r.Legal_Name__c',
						'iban' => 'Payee_Bank_Account__r.IBAN_Account_Number__c',
						'ach' => 'Payee_Bank_Account__r.ACH_Routing_Number__c',
						'intermediary_bank_name' => 'Payee_Bank_Account__r.Intermediary_Bank_Name__c',
						'intermediary_swift' => 'Payee_Bank_Account__r.Intermediary_SWIFT_BIC__c',
						'correspondent_account_number' => 'Payee_Bank_Account__r.Correspondent_Account_Number__c'
				})
				.mapField('payer_billing_country_translated', 'Account__r.BillingCountry', pp_R.prop.apply(pp_R.placeholder, translationsForInvoice?.get('country')))
				.mapField('payee_billing_country_translated', 'Payee_Bank_Account__r.Bank__r.Account__r.BillingCountry', pp_R.prop.apply(pp_R.placeholder, translationsForInvoice?.get('country')))
				.mapField('swift', new List<String>{ 'Payee_Bank_Account__r.SWIFT_BIC__c', 'Payee_Bank_Account__r.Bank__r.SWIFT_BIC__c' }, pp_R.defaultTo)
				.toDTO()
				.run(inv);
		d.setDate('due_date', inv.Submission_Date__c.addDays(inv.Terms__c != null ? Integer.valueOf(inv.Terms__c.split(' ')[0]) : 30));
		if (inv.Payee_Country_Code__c == 'PL') {
			d.setString('tax_rate', INVOICE_PL_VAT_RATE);
			d.setDecimal('tax_amount', 0);
			if (inv.Status__c == 'Cancelled') d.setBoolean('isCancellation', true);
		}
		d.setList('lineItems', pp_R.of(inv.Invoice_Line_Items__r).doMap(new pp_Mapper()
				.inputAs(new List<String>{ 'const', 'line' })
				.mapFields(new Map<String, Object>{
						'quantity' => 'line.Time_Spent__c',
						'unit_price' => 'line.Rate__c',
						'net_price' => 'line.Total__c',
						'total_price' => 'line.Total__c',
						'unit' => 'line.Unit__c',
						'tax_rate' => 'const.tax_rate',
						'tax_amount' => 'const.tax_amount'
				})
				.mapField('description', new List<String>{ 'line.Project_Name__c', 'line.Name_for_Invoice__c' }, pp_R.defaultTo)
				.mapField('unit_translated', 'line.Unit__c', pp_R.prop.apply(pp_R.placeholder, translationsForInvoice?.get('unit')))
				.toMap()
				.apply(new Map<String, Object>{
						'tax_rate' => INVOICE_PL_VAT_RATE,
						'tax_amount' => 0
				})));
		return d.toMap();
	}
}