import { LightningElement, api } from 'lwc';
import {FlowNavigationFinishEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';



export default class navToFlowFinish extends LightningElement() {

    @api availableActions = [];
    @api loopBack;

    handleLoopBack() {
        // check if NEXT is allowed on this screen
        //if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
        this.loopBack = true;
        const navigateNext = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNext); 
        //}
    }

    handleGoNext() {
        console.log('navToFlowFinish handleGoNext');
       // check if FINISH is allowed on the flow screen
       if (this.availableActions.find(action => action === 'FINISH')) {
           console.log('navToFlowFinish handleGoNext FINISH');
           const navigateFinishEvent = new FlowNavigationFinishEvent();
           this.dispatchEvent(navigateFinishEvent);
       }
       // check if NEXT is allowed on the flow screen
       if (this.availableActions.find(action => action === 'NEXT')) {
        console.log('navToFlowFinish handleGoNext NEXT');
           const navigateNextEvent = new FlowNavigationNextEvent();
           this.dispatchEvent(navigateNextEvent);
       }
    }

}