package com.pubnub.gwt.examples.client;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.json.client.*;

import com.google.gwt.core.client.JavaScriptObject;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.DialogBox;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.pubnub.gwt.api.client.Callback;
import com.pubnub.gwt.api.client.Pubnub;
import com.google.gwt.user.client.ui.TabLayoutPanel;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TabPanel;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;

class ExamplePanel extends VerticalPanel {
    private HTML html = null;
    private int noOfLines = 0;
    private LinkedList<String> responses = new LinkedList<String>();
    
    class ExampleCb extends Callback {
        
        private native String toStr(Object message) /*-{
            return JSON.stringify(message);
        }-*/;
        @Override
        public void callback(String channel, Object message){
            html.setHTML("");
            responses.offer(toStr(message));
            if (noOfLines <= 4)
                noOfLines++;
            else 
                responses.poll();
            
            for (String response : responses) {
                html.setHTML(response + "<br><br>" + html.getHTML());
            }
        }

    }
    
    public ExamplePanel(HTML html){
        super();
        this.html = html;
        this.add(html);
        this.setSize("6cm", "5cm");
        html.setHeight("400px");
        html.setWidth("750px");

    }
    public void clearHTML(){
        html.setHTML("");
        responses.clear();
        noOfLines = 0;
    }
    
}

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class PubnubExample implements EntryPoint {
    /**
     * The message displayed to the user when the server cannot be reached or
     * returns an error.
     */
    private static final String SERVER_ERROR = "An error occurred while "
            + "attempting to contact the server. Please check your network "
            + "connection and try again.";


    public static native final void alert(Object message) /*-{
        alert(message);
    }-*/;

    /**
     * This is the entry point method.
     */
    public void onModuleLoad() {
        final Pubnub pubnub;
        pubnub = Pubnub.init();
        final Label errorLabel = new Label();

        
        // Add the nameField and sendButton to the RootPanel"
        // Use RootPanel.get() to get the entire body element
        RootPanel rootPanel = RootPanel.get("nameFieldContainer");
        RootPanel.get("errorLabelContainer").add(errorLabel);
        
        final TabPanel tabPanel = new TabPanel();
        rootPanel.add(tabPanel, 10, 66);
        
        final ExamplePanel panelHereNow = new ExamplePanel(new HTML("", true));
        final ExamplePanel panelSubscribe = new ExamplePanel(new HTML("", true));
        final ExamplePanel panelTimeUuid = new ExamplePanel(new HTML("", true));
        final ExamplePanel panelDetailedHistory = new ExamplePanel(new HTML("", true));
        final ExamplePanel panelHistory = new ExamplePanel(new HTML("", true));
        final ExamplePanel panelPublish = new ExamplePanel(new HTML("", true));
                
        tabPanel.add(panelPublish, "Publish", false);
        tabPanel.add(panelHistory, "History", false);
        tabPanel.add(panelDetailedHistory, "Detailed History", false);
        tabPanel.add(panelSubscribe, "Subscribe & Presence", false);
        tabPanel.add(panelHereNow, "Here Now", false);
        tabPanel.add(panelTimeUuid, "Time & UUID", false);
        

        HorizontalPanel horizontalPanel_1 = new HorizontalPanel();
        rootPanel.add(horizontalPanel_1, 20, 16);
        horizontalPanel_1.setWidth("750px");
        horizontalPanel_1.setSpacing(10);
        
        Label lblNewLabel_1 = new Label("Channel");
        horizontalPanel_1.add(lblNewLabel_1);
        horizontalPanel_1.setCellVerticalAlignment(lblNewLabel_1, HasVerticalAlignment.ALIGN_MIDDLE);
        horizontalPanel_1.setCellHorizontalAlignment(lblNewLabel_1, HasHorizontalAlignment.ALIGN_CENTER);
        
        final TextBox txtChannel = new TextBox();
        txtChannel.setText("gwt_test");
        horizontalPanel_1.add(txtChannel);
        txtChannel.setWidth("175px");
        
        class ClearHandler implements ClickHandler {
            public void onClick(ClickEvent event) {
                for (int i = 0; i < tabPanel.getWidgetCount(); i++) {
                    ExamplePanel ep = (ExamplePanel)tabPanel.getWidget(i);
                    if (ep.isVisible()) {
                        ep.clearHTML();
                    }
                }
            }
        }
        
        Button btnClearConsole = new Button("Clear Console");
        horizontalPanel_1.add(btnClearConsole);
        btnClearConsole.addClickHandler(new ClearHandler());


        
        setupPublishPanel(pubnub, panelPublish, txtChannel);
        setupSubscribePanel(pubnub, panelSubscribe, txtChannel);
        setupHistoryPanel(pubnub, panelHistory, txtChannel);
        setupDetailedHistoryPanel(pubnub, panelDetailedHistory, txtChannel);
        setupHereNowPanel(pubnub, panelHereNow, txtChannel);
        setupTimeUuidPanel(pubnub, panelTimeUuid, txtChannel);
        
        tabPanel.selectTab(0);

    }
    private void setupTimeUuidPanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel){
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        

        Button btn = new Button("Get Time & UUID");
        horizontalPanel.add(btn);
        btn.setWidth("125px");
        
        class Handler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                pubnub.time(cb);
                pubnub.uuid(cb);
            }
        }        
        btn.addClickHandler(new Handler());
        
    }

    private void setupHereNowPanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel){
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        

        Button btn = new Button("Get Here Now Data");
        horizontalPanel.add(btn);
        btn.setWidth("175px");
        
        class Handler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                pubnub.here_now(channel, cb);
            }
        }        
        btn.addClickHandler(new Handler());
        
    }

    
    private void setupDetailedHistoryPanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel){
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        
        Label lbl = new Label();
        lbl.setText("Count");
        horizontalPanel.add(lbl);
        horizontalPanel.setCellVerticalAlignment(lbl, HasVerticalAlignment.ALIGN_MIDDLE);
        
        final TextBox txtcount = new TextBox();
        horizontalPanel.add(txtcount);
        txtcount.setWidth("20px");
        txtcount.setText("10");
        
        Label lblstart = new Label();
        lblstart.setText("Start Time");
        horizontalPanel.add(lblstart);
        horizontalPanel.setCellVerticalAlignment(lblstart, HasVerticalAlignment.ALIGN_MIDDLE);
        
        final TextBox txtstart = new TextBox();
        horizontalPanel.add(txtstart);
        txtstart.setWidth("100px");
        txtstart.setText("");
        
        Label lblend = new Label();
        lblend.setText("End Time");
        horizontalPanel.add(lblend);
        horizontalPanel.setCellVerticalAlignment(lblend, HasVerticalAlignment.ALIGN_MIDDLE);
        
        final TextBox txtend = new TextBox();
        horizontalPanel.add(txtend);
        txtend.setWidth("100px");
        txtend.setText("");
        
        final CheckBox checkbox = new CheckBox();
        checkbox.setText("Reverse ?");
        horizontalPanel.add(checkbox);
        
        Button btn = new Button("Detailed History");
        horizontalPanel.add(btn);
        btn.setWidth("125px");
        
        class Handler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                Integer count = 10;
                Integer start = -1;
                Integer end = -1;
                String startstr = txtstart.getText();
                String endstr = txtend.getText();
                
                try {
                    count = Integer.parseInt(txtcount.getText());
                } catch (NumberFormatException e) {
                    PubnubExample.alert("Count should be integer");
                    return;
                }

                if (startstr.length() != 0) {
                    try {
                        start = Integer.parseInt(startstr);
                    } catch (NumberFormatException e) {
                        PubnubExample.alert("Start time should be long");
                        return;
                    }
                }
                if (endstr.length() != 0) {
                    try {
                        end = Integer.parseInt(endstr);
                    } catch (NumberFormatException e) {
                        PubnubExample.alert("Start time should be long");
                        return;
                    }
                }
                boolean reverse = checkbox.getValue();
                
                pubnub.detailedHistory(channel, start, end, count, reverse, cb);
            }
        }        
        btn.addClickHandler(new Handler());
    }

    private void setupHistoryPanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel){
        
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        
        Label lbl = new Label();
        lbl.setText("Limit");
        horizontalPanel.add(lbl);
        horizontalPanel.setCellVerticalAlignment(lbl, HasVerticalAlignment.ALIGN_MIDDLE);
        
        final TextBox txt = new TextBox();
        horizontalPanel.add(txt);
        txt.setWidth("20px");
        txt.setText("1");
    
        
        Button btn = new Button("Get History");
        horizontalPanel.add(btn);
        btn.setWidth("125px");
        
        class Handler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                String count = txt.getText();
                pubnub.history(channel,Integer.parseInt(count), cb);
            }
        }        
        btn.addClickHandler(new Handler());
    }

    private void setupPublishPanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel){
        
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        
        Label lbl = new Label();
        lbl.setText("Message");
        horizontalPanel.add(lbl);
        
        final TextBox txt = new TextBox();
        horizontalPanel.add(txt);
        txt.setWidth("300px");
        
        Button btn = new Button("Publish");
        horizontalPanel.add(btn);
        btn.setWidth("85px");
        
        class PublishHandler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                String msg = txt.getText();
                pubnub.publish(channel, msg, cb);
            }
        }        
        btn.addClickHandler(new PublishHandler());
    }
    
    private void setupSubscribePanel(final Pubnub pubnub, final ExamplePanel panel, final TextBox txtChannel) {
        HorizontalPanel horizontalPanel = new HorizontalPanel();
        horizontalPanel.setSpacing(10);
        panel.add(horizontalPanel);
        
        
        final Button btn = new Button("Subscribe");
        horizontalPanel.add(btn);
        btn.setWidth("85px");
        
        final Button btnUnsub = new Button("Unsubscribe");
        horizontalPanel.add(btnUnsub);
        btnUnsub.setWidth("85px");
        
        final Label lbl = new Label();
        lbl.setText("Not Connected");
        lbl.setWidth("100px");
        horizontalPanel.add(lbl);
        
        class SubscribeHandler implements ClickHandler {
            ExamplePanel.ExampleCb cb = panel. new ExampleCb();

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                pubnub.subscribe(channel, cb);
                pubnub.presence(channel, cb);
                btn.setEnabled(false);
                btnUnsub.setEnabled(true);
                lbl.setText("Connected");
            }
        }        
        class UnsubscribeHandler implements ClickHandler {

            public void onClick(ClickEvent event) {
                String channel = txtChannel.getText();
                pubnub.unsubscribe(channel);
                btn.setEnabled(true);
                btnUnsub.setEnabled(false);
                lbl.setText("Not Connected");
            }
        }        
        btn.addClickHandler(new SubscribeHandler());
        btnUnsub.addClickHandler(new UnsubscribeHandler());
        
    }
}
