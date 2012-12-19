/*
 * Copyright 2007 Sxip Identity Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.pubnub.api;

public class ServiceProviderException extends Exception {

    private int http_response_code;
    private String http_response_body;

    public ServiceProviderException() {
        super();
    }

    public ServiceProviderException(String message) {
        super(message);
    }

    public ServiceProviderException(String message, Throwable cause) {
        super(message); //, cause);
    }

    public ServiceProviderException(String message, int http_response_code, String http_response_body) {
        super(message);
        this.http_response_code = http_response_code;
        this.http_response_body = http_response_body;
    }

    public int getHTTPResponseCode() {
        return http_response_code;
    }

    public String getHTTPResponse() {
        return http_response_body;
    }
}
