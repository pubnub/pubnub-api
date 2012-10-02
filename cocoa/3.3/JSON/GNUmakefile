include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = libjsonwire-oc
MAJOR_VERSION = 0
MINOR_VERSION = 1

libjsonwire-oc_INTERFACE_VERSION=$(MAJOR_VERSION).$(MINOR_VERSION)

libjsonwire-oc_OBJC_FILES = \
 iohelpers.m \
 ByteStream.m \
 ByteStreamDelegate.m \
 streamutils.m \
 jsunicode.m \
 NSObject+JSON.m \
 NSArray+JSON.m \
 NSDictionary+JSON.m \
 NSNumber+JSON.m \
 NSString+JSON.m \
 NSDictionary+JSONRPC.m \
 JSONPort.m \

libjsonwire-oc_HEADER_FILES = \
 ByteStream.h \
 JSONExtensions.h \
 JSONPort.h \

libjsonwire-oc_HEADER_FILES_INSTALL_DIR = JSONWire

include $(GNUSTEP_MAKEFILES)/library.make
