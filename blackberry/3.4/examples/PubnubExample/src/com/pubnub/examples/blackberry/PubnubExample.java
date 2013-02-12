package com.pubnub.examples.blackberry;

import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;

import com.pubnub.api.Pubnub;

/**
 * This class extends the UiApplication class, providing a
 * graphical user interface.
 */
public class PubnubExample extends UiApplication
{
    /**
     * Entry point for application
     * @param args Command line arguments (not used)
     */
    public static void main(String[] args)
    {

        // Create a new instance of the application and make the currently
        // running thread the application's event dispatch thread.
        PubnubExample theApp = new PubnubExample();
        theApp.enterEventDispatcher();
    }


    /**
     * Creates a new PubnubExample object
     */
    public PubnubExample()
    {
        // Push a screen onto the UI stack for rendering.
        pushScreen(new PubnubExampleScreen());
    }

    /**
     * Presents a dialog to the user with a given message
     *
     * @param message
     *            The text to display
     */
    public static void alertDialog(final String message) {
        UiApplication.getUiApplication().invokeLater(new Runnable() {
            public void run() {
                Dialog.alert(message);
            }
        });
    }
}
