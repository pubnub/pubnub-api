/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.pubnub.api;

/**
 *
 * @author work1
 */


interface ResponseHandler {
    public abstract void handleResponse(String response, String channel);
}