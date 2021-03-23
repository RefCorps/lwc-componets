/**
 * Lightning Web Component for RefCorp Flow Screens used to provide custom navigational support
 * 
 * CREATED BY:      Mike Miller
 * 
 * RELEASE NOTE:    
 * This LWC (customizedFlowFooter) currently supports these standard buttons:
 *   BACK (can float left or right)
 *   NEXT (floats right)
 *   FINISH (floats right)
 * I’ve omitted PAUSE.
 * 
 * In addition, there are currently two (2) custom buttons, CTRL1 and CTRL2 (both float left or right), that will set a Boolean that can be evaluated in a condition.
 * 
 * Common property settings include:  
 * 
 * Button Alt Text
 * All buttons have a default.  You can provide an alternate name as needed, e.g., Next = Submit
 * 
 * Button Hidden
 * The BACK, NEXT, and FINISH buttons are controlled both by the screen settings "Control Navigation."  Disabling a button in "Control Navigation" will also disable the custom button.  The CTRL1 and CTRL2 are completely controlled by property settings.  You can pass in or read a button's Hidden setting.  This allows you control settings in the Flow.
 * 
 * Horiz Align
 * The options are 'left' or 'right'.  This option only pushes the button in the direction indicated.
 * 
 * Variant
 * All buttons allow you to change the background or text color. This setting is referred to as ‘...Variant.’ The default variant is neutral. To set a variant you must use one of the following:
 *     base - no border  
 *     brand - matches app brand settings (e.g., blue) 
 *     brand-outline - similar to brand with a neutral background
 *     destructive - typically the opposite of brand based upon app brand settings (e.g., red)
 *     destructive-text - similar to destructive with a neutral background
 *     success - matches app success setting (e.g., green)
 * Refer to App Manger – Builder – Themes to see the default color settings for your app. 
 * 
 * CTRL1 & CTRL2 State
 * These buttons are set to false by default.  Clicking these buttons changes the state to true.  You can see this setting in properties, but you currently cannot influence it.
 * 
 * To use customizedFlowFooter in a Flow Screen, you’ll want to uncheck Screen Properties - Configure Frame – Show Footer. You can check or uncheck Control Navigation options as needed. Keep in mind that at this time there is no PAUSE.
 * 
 * Note that you may see values in the properties - view these as Hints.  I suggest setting up Constants or Variables that contain settings to be used.
 * 
 * 2021-03-08   v0.1.0 - Initial version.
 * 2021-03-10   v0.1.1 - Updated notes - console.log changed to logmessage
 * 2021-03-23   v1.1.1 - Deploying to production
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

    enableLogging;


    // connectedCallback will fire whenever the component loads similar to html onLoad or Aura init
    connectedCallback() {
        this.init();
    }
    
    init() {

        this.enableLogging = true;

        logmessage('>> customizedFlowFooter');
        logmessage('customizedFlowFooter ctrl1 text: [' + this.flowCtrl1Text + '] hide: [' + this.flowCtrl1Hide + '] align: [' + this.flowCtrl1HAlign + '] variant [' + this.flowCtrl1Variant + ']');
        logmessage('customizedFlowFooter ctrl2 text: [' + this.flowCtrl2Text + '] hide: [' + this.flowCtrl2Hide + '] align: [' + this.flowCtrl2HAlign + '] variant [' + this.flowCtrl2Variant + ']');
        logmessage('customizedFlowFooter next text: [' + this.nextText + '] hide: [' + this.nextHide + '] align: [' + this.nextHAlign + '] variant [' + this.nextVariant + ']');
        logmessage('customizedFlowFooter back text: [' + this.backText + '] hide: [' + this.backHide + '] align: [' + this.backHAlign + '] variant [' + this.backVariant + ']');
        logmessage('customizedFlowFooter finishText: [' + this.finishText + '] hide: [' + this.finishHide + '] align: [' + this.finishHAlign + '] variant [' + this.finishVariant + ']');
        
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
                logmessage('customizedFlowFooter BACK availableActions');
                this.backHide = false;
            } else {
                logmessage('customizedFlowFooter NO BACK availableActions');
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
            logmessage('customizedFlowFooter NEXT availableActions');
            this.nextHide = false;
        } else {
            logmessage('customizedFlowFooter NO NEXT availableActions');
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
            logmessage('customizedFlowFooter FINISH availableActions');
            this.nextFiniDisplay = this.finishText;
            this.finishHide = false;
        } else {
            logmessage('customizedFlowFooter NO FINISH availableActions');
            this.finishHide = true;
        }
        }

        // check if NEXT is allowed on the flow screen
        /*
        if (this.availableActions.find(action => action === 'FINISH')) {
            logmessage('customizedFlowFooter set nextFiniDisplay = ' + this.finishText);
            this.nextFiniDisplay= this.finishText;
        }
        */
        logmessage('<< customizedFlowFooter');
        logmessage('customizedFlowFooter ctrl1 text: [' + this.flowCtrl1Text + '] hide: [' + this.flowCtrl1Hide + '] align: [' + this.flowCtrl1HAlign + '] variant [' + this.flowCtrl1Variant + ']');
        logmessage('customizedFlowFooter ctrl2 text: [' + this.flowCtrl2Text + '] hide: [' + this.flowCtrl2Hide + '] align: [' + this.flowCtrl2HAlign + '] variant [' + this.flowCtrl2Variant + ']');
        logmessage('customizedFlowFooter next text: [' + this.nextText + '] hide: [' + this.nextHide + '] align: [' + this.nextHAlign + '] variant [' + this.nextVariant + ']');
        logmessage('customizedFlowFooter back text: [' + this.backText + '] hide: [' + this.backHide + '] align: [' + this.backHAlign + '] variant [' + this.backVariant + ']');
        logmessage('customizedFlowFooter finishText: [' + this.finishText + '] hide: [' + this.finishHide + '] align: [' + this.finishHAlign + '] variant [' + this.finishVariant + ']');

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
            logmessage('navToFlowFinish handleGoNext PREVIOUS');
            const navigateNextEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        
    }

    handleNextFini() {
        
        logmessage('navToFlowFinish handleNextFini');
        // check if FINISH is allowed on the flow screen
        if (this.availableActions.find(action => action === 'FINISH')) {
            logmessage('navToFlowFinish handleNextFini FINISH');
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
        // check if NEXT is allowed on the flow screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            logmessage('navToFlowFinish handleNextFini NEXT');
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        
    }

    handleFinish() {
        //
        logmessage('navToFlowFinish handleFinish');
        // check if FINISH is allowed on the flow screen
        //if (this.availableActions.find(action => action === 'FINISH')) {
            logmessage('navToFlowFinish handleGoNext FINISH');
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        //}
        //
    }
    
    logmessage(message) {
        if (this.enableLogging) {
            console.log('maintDesignations ' + message);
        }
    }

}