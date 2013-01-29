//
//  UIDevice+PNAdditions.m
//  pubnub
//
//  Category was created to add few useful
//  methods.
//
//  Created by Sergey Mamontov on 01/29/13.
//
//

#import "UIDevice+PNAdditions.h"
#import <arpa/inet.h>
#import <ifaddrs.h>


#pragma mark Static

// Stores reference on WiFi/LAN interface name
static char * const kPNNetworkWirelessCableInterfaceName = "en0";

// Store reference on 3G/EDGE interface name
static char * const kPNNetworkCellularInterfaceName = "pdp_ip0";

// Stores reference on default IP address which means that
// interface is not really connected
static char * const kPNNetworkDefaultAddress = "0.0.0.0";


#pragma mark Public interface methods

@implementation UIDevice (PNAdditions)


#pragma mark - Instance methods

- (NSString *)networkAddress {

    // Initial setup
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *interface = NULL;

    // Retrieving list of interfaces
    if (getifaddrs(&interfaces) == 0) {

        interface = interfaces;
        while (interface != NULL) {

            // Checking whether found network interface or not
            sa_family_t family = interface->ifa_addr->sa_family;
            if (family == AF_INET || family == AF_INET6) {

                char *interfaceName = interface->ifa_name;
                char *interfaceAddress = inet_ntoa(((struct sockaddr_in*)interface->ifa_addr)->sin_addr);

                if (strcmp(interfaceName, kPNNetworkWirelessCableInterfaceName) == 0 ||
                    strcmp(interfaceName, kPNNetworkCellularInterfaceName) == 0) {

                    if (strcmp(interfaceAddress, kPNNetworkDefaultAddress) != 0) {

                        address = [NSString stringWithUTF8String:interfaceAddress];

                        break;
                    }

                }
            }
            
            interface = interface->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    
    
    return address;
}

#pragma mark -

@end
