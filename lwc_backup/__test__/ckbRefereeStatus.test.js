import { createElement } from 'lwc';
import WireGetRefereeStatusValues from 'c/ckbRefereeStatus';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

// Mock realistic data
const mockGetPicklistValues = require('./data/getPicklistValues.json');

// Register as an LDS wire adapter. Some tests verify the provisioned values trigger desired behavior.
const getPicklistValuesAdapter = registerLdsTestWireAdapter(getPicklistValues);

describe('c-wire-get-picklist-values', () => {

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    describe('getPicklistValues @wire data', () => {
        it('renders seven lightning-input fields of type radio', () => {
            // Create element
            const element = createElement('c-wire-get-picklist-values', {
                is: WireGetRefereeStatusValues
            });
            document.body.appendChild(element);

            // Emit data from @wire
            getPicklistValuesAdapter.emit(mockGetPicklistValues);

            // Return a promise to wait for any asynchronous DOM updates. Jest
            // will automatically wait for the Promise chain to complete before
            // ending the test and fail the test if the promise rejects.
            return Promise.resolve().then(() => {
                // Select elements for validation
                const radioEls = element.shadowRoot.querySelectorAll(
                    'lightning-radio-group'
                );

                expect(radioEls.length).toBe(
                    mockGetPicklistValues.values.length
                );

                //radioEls.forEach((radioEls) => {
                //    expect(radioEls.type).toBe('radio');
                //});
            });
        });
    });



});