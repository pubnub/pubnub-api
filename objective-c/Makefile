XCODE = xcodebuild
PROJECT = PubNubLib.xcodeproj
TARGETS = pubnub
BUILD = build
CLEAN = clean

all: clean
	for t in $(TARGETS); do $(XCODE) -project $(PROJECT) -target $$t build; done

clean:
	for t in $(TARGETS); do $(XCODE) -project $(PROJECT) -target $$t clean; done
