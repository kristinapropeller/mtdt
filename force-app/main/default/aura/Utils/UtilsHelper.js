({
	init: function(component) {

		var contextComponent = component.get('v.context');
		var utilsProps = {
			_component: {
				writable: false,
				configurable: false,
				enumerable: false,
				value: contextComponent,
			},
		};

		var utils = Object.create(this.getUtils(), utilsProps);

		var componentProps = {
			writable: false,
			configurable: false,
			enumerable: false,
			value: utils,
		};
		Object.defineProperty(contextComponent, 'utils', componentProps);
	},

	getUtils: function() {
		if (!this._utils) {
			this._utils = this.createUtils();
		}

		return this._utils;
	},

	createUtils: function() {

		return {
			callApex : this.callApex,
			callApexPromise : this.callApexPromise,
			execute: this.execute,
			showToast: this.showToast,
			showError: this.showError,
			showErrors: this.showErrors,
			showSuccess: this.showSuccess,
			showSpinner: this.showSpinner,
			hideSpinner: this.hideSpinner,
			validateInputs: this.validateInputs,
			validate: this.validate,
			validateComponents: this.validateComponents,
			createComponent: this.createComponent,
			flatten: this.flatten,
			getRandomString: this.getRandomString
		}

	},

	showSpinner: function(component) {
		var spinner = component.find("spinner");
		if (spinner) {
			$A.util.removeClass(spinner, "slds-hide");
		}
	},

	hideSpinner: function(component) {
		var spinner = component.find("spinner");
		if (spinner) {
			$A.util.addClass(spinner, "slds-hide");
		}
	},
	callApexPromise: function (action, params) {
		return new Promise(function (resolve, reject) {
			action.setParams(params);
			action.setCallback(this, function (response) {
				var state = response.getState();
				console.log(':::::state::::' + state);
				if (state === "SUCCESS") {
					var retVal = response.getReturnValue();
					resolve(retVal);
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors.length && errors[0] && errors[0].message) {
						reject(new Error(errors[0].message));
					} else {
						reject(new Error("Unknown error"));
					}
				}
			});
			$A.enqueueAction(action);
		});
	},

	callApex: function(action, params, success, fail) {

		if(!action){
			console.log('No Action');
			throw 'No Action'
		}

		console.log('CALLAPEX', action, params);

		action.setParams(params);

		// action.setStorable({ignoreExisting: true});

		action.setCallback(this, function(a) {

			console.log(a.getState(), a.getReturnValue());

			if (a.getState() === "SUCCESS") {
				$A.log("Success", a.getReturnValue())
				if (success){
					success.apply(this, [a.getReturnValue()])
				}
			} else if (a.getState() === "ERROR") {
				$A.log("Errors", a.getError())
				if(fail){
					fail.apply(this, [a.getError()])
				} else {
					var error = a.getError()
					console.error('callApex error',error)
					if(error && error.length){
						alert(error[0].message)
					} else {
						throw error
					}
				}
			}
		});

		console.log('CALLAPEX enqueueAction');

		$A.enqueueAction(action);

		console.log('CALLAPEX enqueueAction OK');

	},

	execute: function (cmp, processor, request, success, fail) {

		var failFn = function (errors) {
			console.error('execute error', errors);
			if(fail){
				fail(errors);
			} else {
				throw errors;
			}
		}

		console.log('Calling: ', processor, request);

		this.callApex(
			cmp.get('c.execute'),
			{
				processor: processor,
				requestJSON: JSON.stringify(request)
			},
			function (responseJSON) {


				// var dateFormat = /^\d{4}-\d{2}-\d{2}$/;
				// var dateTimeFormat = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/;
				//
				// function reviver(key, value) {
				//     if (typeof value === "string" && (dateFormat.test(value) || dateTimeFormat.test(value))) {
				//         return new Date(value);
				//     }
				//
				//     return value;
				// }

				// var text = '{ "date": "2016-04-26T18:09:16Z" }';
				// var obj = JSON.parse(text, reviver);
				//
				// console.log(typeof obj.date);


				// var response = JSON.parse(responseJSON, reviver);
				var response = JSON.parse(responseJSON);
				console.log('Response: ', processor, response);
				if(response.isValid !== true){
					failFn.call(this, response.errors);
				} else {
					success.call(this, response);
				}
			},
			failFn
		)
	},

	showToast: function (params) {
		var toastEvent = $A.get("e.force:showToast");
		params = params || {};
		if(toastEvent){
			toastEvent.setParams(params);
			toastEvent.fire();
		} else {
			console.log('NO TOAST', params);
			alert(params.title || params.message || 'NO TOAST: ' + JSON.stringify(params));
		}
	},

	showError: function (component, error) {
		this.showErrors(component, [error]);
	},

	showErrors: function (component, errors) {
		for (var i = 0; i < errors.length; i++) {
			this.showToast({
				"title": "Error",
				"message": errors[i].message,
				"type": "error"
			});
		}
	},

	showSuccess: function (component, message) {
		this.showToast({
			"title": "Success",
			"message": message,
			"type": "success"
		});
	},

	validateInputs: function (component, inputIds) {

		var validationResult = {
			errorsByInputs : [],
			allValid: true,
			getErrorMessages : function () {
				var errors = [];
				this.errorsByInputs.forEach(function (errorsByInput) {
					errors.push(errorsByInput.errors.join(','));
				})

				return errors;
			}
		};

		inputIds.forEach(function (id) {

			var validationErrors = [
				'badInput',
				'customError',
				'patternMismatch',
				'rangeOverflow',
				'rangeUnderflow',
				'stepMismatch',
				'tooLong',
				'tooShort',
				'typeMismatch',
				'valueMissing'
			];

			var defaultErrorMessages = {
				badInput: 'Enter a valid value.',
				patternMismatch: 'Your entry does not match the allowed pattern.',
				rangeOverflow: 'The number is too high.',
				rangeUnderflow: 'The number is too low.',
				stepMismatch: 'Your entry isn\'t a valid increment.',
				tooLong: 'Your entry is too long.',
				tooShort: 'Your entry is too short.',
				typeMismatch: 'You have entered an invalid format.',
				valueMissing: 'Complete this field.'
			};

			var capitalizeFirstLetter = function (string) {
				return string.charAt(0).toUpperCase() + string.slice(1);
			}

			var inputCmp = component.find(id);
			if (inputCmp) {
				var validity = inputCmp.get('v.validity');
				if (validity && validity.valid == false) {

					var errors = [];
					validationErrors.forEach(function (validationErrorField) {
						if (validity[validationErrorField] == true) {
							var errorMessageField = 'v.messageWhen' + capitalizeFirstLetter(validationErrorField);
							// debugger
							var errorMessage = inputCmp.get(errorMessageField) ||
								defaultErrorMessages[validationErrorField];
							if (errorMessage) {
								errors.push(errorMessage);
							} else {
								errors.push('Please check: ' + inputCmp.get('v.label'));
							}
						}
					});

					validationResult.errorsByInputs.push({
						id: id,
						inputCmp: inputCmp,
						errors: errors
					});

					validationResult.allValid = false;

					if (inputCmp.reportValidity != undefined) {
						inputCmp.reportValidity();
					} else if (inputCmp.showHelpMessageIfInvalid != undefined) {
						inputCmp.showHelpMessageIfInvalid();
					}
				}
			}
		});

		return validationResult;
	},

	validate: function (containerComponent, options){

		options = options || {}
		options.additionalComponentTypes = options.additionalComponentTypes || [];

		var componentTypes = [
			'lightning:input',
			'lightning:select',
			'lightning:textarea',
			'lightning:radioGroup',
			'c:strike_lookup'
		];
		var inputComponents = [];

		componentTypes = componentTypes.concat(options.additionalComponentTypes);

		componentTypes.forEach(function (componentType) {
			inputComponents = inputComponents.concat(containerComponent.find({instancesOf: componentType}));
		});

		return this.validateComponents(inputComponents);
	},

	validateComponents: function (components) {

		var validationResult = {
			errorsByInputs : [],
			allValid: true,
			getErrorMessages : function () {
				var errors = [];
				this.errorsByInputs.forEach(function (errorsByInput) {
					errors.push(errorsByInput.errors.join(','));
				})

				return errors;
			}
		};

		components.forEach(function (inputCmp) {

			var validationErrors = [
				'badInput',
				'customError',
				'patternMismatch',
				'rangeOverflow',
				'rangeUnderflow',
				'stepMismatch',
				'tooLong',
				'tooShort',
				'typeMismatch',
				'valueMissing'
			];

			var defaultErrorMessages = {
				badInput: 'Enter a valid value.',
				patternMismatch: 'Your entry does not match the allowed pattern.',
				rangeOverflow: 'The number is too high.',
				rangeUnderflow: 'The number is too low.',
				stepMismatch: 'Your entry isn\'t a valid increment.',
				tooLong: 'Your entry is too long.',
				tooShort: 'Your entry is too short.',
				typeMismatch: 'You have entered an invalid format.',
				valueMissing: 'Complete this field.'
			};


			var capitalizeFirstLetter = function (string) {
				return string.charAt(0).toUpperCase() + string.slice(1);
			}

			if(inputCmp){

				var validity;
				try {
					validity = inputCmp.get('v.validity');
				} catch (e) {}


				if(validity == undefined){

					var hasShowErrorMethod = inputCmp.get('c.showError') != undefined;
					if(hasShowErrorMethod == true){
						if (inputCmp.get('c.hideError') != undefined) {
							inputCmp.hideError();
						}
						var isRequired = inputCmp.get('v.required');
						var isEmptyValue = $A.util.isEmpty(inputCmp.get('v.value'));

						if (isRequired && isEmptyValue){

							inputCmp.showError('Complete this field.');

							validationResult.errorsByInputs.push({
								inputCmp: inputCmp,
								errors: [
									inputCmp.get('v.label') + ': Complete this field.'
								]
							});

							validationResult.allValid = false;
						}
					}

				} else if(validity && validity.valid == false){

					var errors = [];
					validationErrors.forEach(function (validationErrorField) {
						if(validity[validationErrorField] == true){
							var errorMessageField = 'v.messageWhen' + capitalizeFirstLetter(validationErrorField);
							var errorMessage = inputCmp.get(errorMessageField);
							errorMessage = errorMessage || defaultErrorMessages[validationErrorField];
							if(errorMessage){
								errors.push(inputCmp.get('v.label') + ': ' + errorMessage);
							} else {
								errors.push(inputCmp.get('v.label') + ': ' + inputCmp.get('v.label'));
							}
						}
					})

					validationResult.errorsByInputs.push({
						inputCmp: inputCmp,
						errors: errors
					});

					validationResult.allValid = false;

					// debugger

					if(inputCmp.reportValidity != undefined){
						inputCmp.reportValidity();
					} else if(inputCmp.showHelpMessageIfInvalid != undefined){
						inputCmp.showHelpMessageIfInvalid();
					}

				}

			}
		})

		return validationResult;
	},

	createComponent: function (componentName, params) {
		return new Promise($A.getCallback(function(resolve, reject) {
			$A.createComponent(
				componentName,
				params,
				function(newCmp, status, errorMessage){
					if (status === "SUCCESS") {
						resolve(newCmp);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
					else if (status === "ERROR") {
						reject(errorMessage);
					}
				}
			);
		}));
	},

	flatten: function(data) {
		var result = {};
		function recurse (cur, prop) {
			if (Object(cur) !== cur) {
				result[prop] = cur;
			} else if (Array.isArray(cur)) {
				for(var i=0, l=cur.length; i<l; i++)
					recurse(cur[i], prop + "[" + i + "]");
				if (l == 0)
					result[prop] = [];
			} else {
				var isEmpty = true;
				for (var p in cur) {
					isEmpty = false;
					recurse(cur[p], prop ? prop+"."+p : p);
				}
				if (isEmpty && prop)
					result[prop] = {};
			}
		}
		recurse(data, "");
		return result;
	},

	getRandomString: function(strLength) {
		var text = "";
		var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

		for (var i = 0; i < strLength; i++)
			text += possible.charAt(Math.floor(Math.random() * possible.length));

		return text;
	}
})