/**
 * Lightning Web Component for RefCorp Flow Screens used to provide custom navigational support
 * 
 * CREATED BY:      Mike Miller
 * 
 * RELEASE NOTE:    No notes at this time
 * 
 * 2021-03-08   v0.1.0 - Initial version.
 * 
 */

import {
    LightningElement,
    api
} from 'lwc';

import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';

export default class navToFlowFinish extends LightningElement() {

    @api availableActions = [];

    @api flowCtrl1Text;
    @api flowCtrl1Hide;
    @api flowCtrl1Clicked;
    @api flowCtrl1Variant;
    @api flowCtrl1HAlign;

    @api flowCtrl2Text;
    @api flowCtrl2Hide;
    @api flowCtrl2Clicked;
    @api flowCtrl2Variant;
    @api flowCtrl2HAlign;

    @api backText;
    @api backHide;
    @api backHAlign;
    @api backVariant

    @api nextText;
    @api nextHide;
    @api nextHAlign;
    @api nextVariant;

    @api finishText;
    @api finishHide;
    @api finishHAlign;
    @api finishVariant;

    backjustify;
    nextjustify;
    finishjustify;

    nextFiniDisplay;    

    // connectedCallback will fire whenever the component loads similar to html onLoad or Aura init
    connectedCallback() {
        this.init();
    }
    
    init() {

        console.log('>> customizedFlowFooter');
        console.log('customizedFlowFooter ctrl1 text: [' + this.flowCtrl1Text + '] hide: [' + this.flowCtrl1Hide + '] align: [' + this.flowCtrl1HAlign + '] variant [' + this.flowCtrl1Variant + ']');
        console.log('customizedFlowFooter ctrl2 text: [' + this.flowCtrl2Text + '] hide: [' + this.flowCtrl2Hide + '] align: [' + this.flowCtrl2HAlign + '] variant [' + this.flowCtrl2Variant + ']');
        console.log('customizedFlowFooter next text: [' + this.nextText + '] hide: [' + this.nextHide + '] align: [' + this.nextHAlign + '] variant [' + this.nextVariant + ']');
        console.log('customizedFlowFooter back text: [' + this.backText + '] hide: [' + this.backHide + '] align: [' + this.backHAlign + '] variant [' + this.backVariant + ']');
        console.log('customizedFlowFooter finishText: [' + this.finishText + '] hide: [' + this.finishHide + '] align: [' + this.finishHAlign + '] variant [' + this.finishVariant + ']');
        
        const alignLeft = "slds-float_left";
        const alignRight = "slds-float_right";
        
        
        // BEGIN flowCtrl1 setup
        this.flowCtrl1Text = this.flowCtrl1Text ? this.flowCtrl1Text : 'Ctr1';
        this.flowCtrl1Variant = this.flowCtrl1Variant ? this.flowCtrl1Variant : 'neutral';
        this.flowCtrl1Clicked = false;
        this.ctrl1justify = alignLeft;
        if (this.flowCtrl1HAlign && (this.flowCtrl1HAlign).toLowerCase() === 'right') {
            this.ctrl1justify = alignRight;
        }
        if (typeof this.flowCtrl1Hide !== "boolean"){
            this.flowCtrl1Hide = true;
        }

        // BEGIN flowCtrl2 setup
        this.flowCtrl2Text = this.flowCtrl2Text ? this.flowCtrl2Text : 'Ctr2';
        this.flowCtrl2Variant = this.flowCtrl2Variant ? this.flowCtrl2Variant : 'neutral';
        this.flowCtrl1Clicked = false;
        this.ctrl2justify = alignLeft;
        if (this.flowCtrl1HAlign && (this.flowCtrl1HAlign).toLowerCase() === 'right') {
            this.ctrl2justify = alignRight;
        }
        if (typeof this.flowCtrl2Hide !== "boolean"){
            this.flowCtrl2Hide = true;
        }

        // BEGIN Back Button setup
        this.backText = this.backText ? this.backText : 'Previous';
        this.backVariant = this.backVariant ? this.backVariant : 'neutral';
        //this.backHAlign = this.backHAlign ? this.backHAlign : 'right';
        this.backjustify = alignRight;
        if (this.backHAlign && (this.backHAlign).toLowerCase() === 'left') {
            this.backjustify = alignLeft;
        }
        if (!this.backHide) {
            if (this.availableActions.find(action => action === 'BACK')) {
                console.log('customizedFlowFooter BACK availableActions');
                this.backHide = false;
            } else {
                console.log('customizedFlowFooter NO BACK availableActions');
                this.backHide = true;
            }
        }

        // BEGIN Next (Finish) Button setup
        this.nextText = this.nextText ? this.nextText : 'Next';
        this.nextHAlign = this.nextHAlign ? this.nextHAlign : 'right';
        this.nextVariant = this.nextVariant ? this.nextVariant : 'brand';
        this.nextjustify = alignRight;
        if ((this.nextHAlign).toLowerCase() === 'left') {
            this.nextjustify = alignLeft;
        }
        if(!this.nextHide) {
        if (this.availableActions.find(action => action === 'NEXT')) {
            console.log('customizedFlowFooter NEXT availableActions');
            this.nextHide = false;
        } else {
            console.log('customizedFlowFooter NO NEXT availableActions');
            this.nextHide = true;
        }
        }

        // BEGIN Finish Button setup    
        this.finishText = this.finishText ? this.finishText : "Finish";
        this.finishHAlign = this.finishHAlign ? this.finishHAlign : 'right';
        this.finishVariant = this.finishVariant ? this.finishVariant : 'brand';
        this.finishjustify = alignRight;
        if((this.finishHAlign).toLowerCase() === 'left' ) {
            this.finishjustify = alignLeft;
        }
        if(!this.finishHide) {
        if (this.availableActions.find(action => action === 'FINISH')) {
            console.log('customizedFlowFooter FINISH availableActions');
            this.nextFiniDisplay = this.finishText;
            this.finishHide = false;
        } else {
            console.log('customizedFlowFooter NO FINISH availableActions');
            this.finishHide = true;
        }
        }

        // check if NEXT is allowed on the flow screen
        /*
        if (this.availableActions.find(action => action === 'FINISH')) {
            console.log('customizedFlowFooter set nextFiniDisplay = ' + this.finishText);
            this.nextFiniDisplay= this.finishText;
        }
        */
        console.log('<< customizedFlowFooter');
        console.log('customizedFlowFooter ctrl1 text: [' + this.flowCtrl1Text + '] hide: [' + this.flowCtrl1Hide + '] align: [' + this.flowCtrl1HAlign + '] variant [' + this.flowCtrl1Variant + ']');
        console.log('customizedFlowFooter ctrl2 text: [' + this.flowCtrl2Text + '] hide: [' + this.flowCtrl2Hide + '] align: [' + this.flowCtrl2HAlign + '] variant [' + this.flowCtrl2Variant + ']');
        console.log('customizedFlowFooter next text: [' + this.nextText + '] hide: [' + this.nextHide + '] align: [' + this.nextHAlign + '] variant [' + this.nextVariant + ']');
        console.log('customizedFlowFooter back text: [' + this.backText + '] hide: [' + this.backHide + '] align: [' + this.backHAlign + '] variant [' + this.backVariant + ']');
        console.log('customizedFlowFooter finishText: [' + this.finishText + '] hide: [' + this.finishHide + '] align: [' + this.finishHAlign + '] variant [' + this.finishVariant + ']');

    }    

    handleFlowCtrl1() {
        this.flowCtrl1Clicked = true;
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNext = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNext); 
        }
        if (this.availableActions.find(action => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }

    handleFlowCtrl2() {
        this.flowCtrl2Clicked = true;
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNext = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNext); 
        }
        if (this.availableActions.find(action => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }

    
    handleBack() {
        
        if (this.availableActions.find(action => action === 'BACK')) {
            console.log('navToFlowFinish handleGoNext PREVIOUS');
            const navigateNextEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        
    }

    handleNextFini() {
        
        console.log('navToFlowFinish handleNextFini');
        // check if FINISH is allowed on the flow screen
        if (this.availableActions.find(action => action === 'FINISH')) {
            console.log('navToFlowFinish handleNextFini FINISH');
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
        // check if NEXT is allowed on the flow screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            console.log('navToFlowFinish handleNextFini NEXT');
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        
    }

    handleFinish() {
        //
        console.log('navToFlowFinish handleFinish');
        // check if FINISH is allowed on the flow screen
        //if (this.availableActions.find(action => action === 'FINISH')) {
            console.log('navToFlowFinish handleGoNext FINISH');
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        //}
        //
    }
    

}