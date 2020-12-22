import { override } from '@microsoft/decorators';
import { Log } from '@microsoft/sp-core-library';
import {
  BaseApplicationCustomizer
} from '@microsoft/sp-application-base';
import { Dialog } from '@microsoft/sp-dialog';

import * as strings from 'InjectJsApplicationCustomizerStrings';

const LOG_SOURCE: string = 'InjectJsApplicationCustomizer';

/**
 * If your command set uses the ClientSideComponentProperties JSON input,
 * it will be deserialized into the BaseExtension.properties object.
 * You can define an interface to describe it.
 */
export interface IInjectJsApplicationCustomizerProperties {
  // This is an example; replace with your own property
  testMessage: string;
}

/** A Custom Action which can be run during execution of a Client Side Application */
export default class InjectJsApplicationCustomizer
  extends BaseApplicationCustomizer<IInjectJsApplicationCustomizerProperties> {

    private _JS: string = "https://m365x502029.sharepoint.com/sites/communication_site/Shared%20Documents/MyScript.js";
    @override
    public onInit(): Promise<void> {
  
      if ((document.location.href).toLowerCase().indexOf("sites/communication_site") > 0) {
        //Add the piece of code to add the HTMLScriptElement to the DOM Element
        let articleRedirectScriptTag: HTMLScriptElement = document.createElement("script");
        articleRedirectScriptTag.src = this._JS;
        articleRedirectScriptTag.type = "text/javascript";
        document.body.appendChild(articleRedirectScriptTag);
      }
      return Promise.resolve();
    }
}
