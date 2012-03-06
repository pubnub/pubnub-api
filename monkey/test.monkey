Import mojo
Import monkey.stack
Import pubnub

Const FONT_WIDTH := 7
Const FONT_HEIGHT = 13
Const FONT_SPACING := 2

Const FONT_CHAT := 0
Const FONT_INFO := 1
Const FONT_QUIET := 2
Const FONT_BAD := 3
Const FONT_GOOD := 4
Const FONT_EMOTE := 5

Const PUBLISH_KEY := "pub-3952b16f-e320-4157-ba03-7c440cbc3772"
Const SUBSCRIBE_KEY := "sub-ad02a5d7-613d-11e1-b257-9b39841ddee9"

Const CHANNEL_LOBBY:String = "monkey_lobby"

Const MESSAGE_USER_JOINED := 1
Const MESSAGE_USER_CHAT := 2
Const MESSAGE_USER_EMOTE := 3

Function Main()
	New MyApp
End

Class MyApp Extends App
	Field screenChanged:Int = True
	
	Field ms:Int
	Field loading := False
	Field loaded := False
	Field connecting := False
	Field connected := False
	Field channel:PubNubChannel
	
	Field fonts:Image[6]
	
	Field username:String
	Field mode:string = ""
	
	Field logo:Image
	Field logoScale:Float
	
	Field screenBufferHr:String
	Field screenBufferCharsHorizontal:Int
	Field screenBufferCharsVertical:Int
	Field screenBufferX:Int = 5
	Field screenBufferY:Int = 5
	Field screenBufferWidth:Int
	Field screenBufferHeight:Int
	Field screenBufferText:String[]
	Field screenBufferFont:Int[]
	
	Field inputX:Int
	Field inputY:Int
	Field inputWidth:Int
	Field inputHeight:Int = FONT_HEIGHT
	Field inputCharsHorizontal:Int
	Field inputCharsVertical:Int = 1
	
	Field keyboardBuffer:String = ""
	Field keyboardResult := New StringStack
	Field keyboardCursorState := false
	field keyboardCursorTime:Int
	
	Method OnCreate()
		' --- setup the runtime ---
		'setup app
		SetUpdateRate(60)
		
		'load fonts
		fonts[FONT_CHAT] = LoadImage("font_chat.png",96,Image.XPadding)
		fonts[FONT_INFO] = LoadImage("font_info.png",96,Image.XPadding)
		fonts[FONT_QUIET] = LoadImage("font_quiet.png",96,Image.XPadding)
		fonts[FONT_BAD] = LoadImage("font_bad.png",96,Image.XPadding)
		fonts[FONT_GOOD] = LoadImage("font_good.png",96,Image.XPadding)
		fonts[FONT_EMOTE] = LoadImage("font_emote.png",96,Image.XPadding)
		
		'setup the screen text buffer
		screenBufferWidth = DeviceWidth() - 10
		screenBufferHeight = DeviceHeight() - 15 - FONT_HEIGHT
		screenBufferCharsHorizontal = screenBufferWidth / FONT_WIDTH
		screenBufferCharsVertical =  Ceil(Float(screenBufferHeight)/FONT_HEIGHT)
		screenBufferText = New String[screenBufferCharsVertical]
		screenBufferFont = New Int[screenBufferCharsVertical]
		
		screenBufferHr = ""
		For Local index := 0 until screenBufferCharsHorizontal
			screenBufferHr += "_"
		Next
		
		'setup the logo
		logo = LoadImage("monkey.png")
		logo.SetHandle(logo.Width()/2,logo.Height()/2)
		if DeviceHeight() > DeviceWidth()
			logoScale = Float(DeviceWidth()) / logo.Width()
		Else
			logoScale = Float(DeviceHeight()) / logo.Width()
		EndIf
		
		'setup input
		inputX = 5 + FONT_WIDTH + FONT_SPACING
		inputY = DeviceHeight() - 5 - FONT_HEIGHT
		inputWidth = DeviceWidth() - 10 - FONT_WIDTH - FONT_SPACING
		inputCharsHorizontal = inputWidth / FONT_WIDTH
		
		'add author stuff
		AddText("PubNub Module Example",FONT_QUIET)
		AddText("Written by Jonathan Pittock (skn3)",FONT_QUIET)
		AddText("http://www.skn3.com",FONT_QUIET)
		AddText(" ",FONT_QUIET)
		
		'setup mode
		mode = "username"
		AddText("Please enter your username:",FONT_INFO)
		
		EnableKeyboard()
	End
	
	Method OnUpdate()
		' --- update app ---
		ms = Millisecs()
		
		Select mode
			Case "username"
				'input username mode
				UpdateKeyboard()
				
				'check for available keyboard result
				If keyboardResult.IsEmpty() = False
					username = keyboardResult.Top()
					
					if username.Length < 3
						AddText("Username was too short!",FONT_BAD)
						AddText("Please enter your username:",FONT_INFO)
						
						keyboardResult.Clear()
						keyboardBuffer = ""
					ElseIf username.Length > 20
						AddText("Username was too long!",FONT_BAD)
						AddText("Please enter your username:",FONT_INFO)
						
						keyboardResult.Clear()
						keyboardBuffer = ""
					Else
						AddText("Username set to '"+username+"'",FONT_GOOD)
						
						keyboardResult.Clear()
						keyboardBuffer = ""
						mode = "connect"
					EndIf
				EndIf
				
			Case "connect"
				UpdateKeyboard()
				
				'initialising pubnub
				if loaded = False
					if loading = False
						loading = True
						loaded = False
						
						'start pubnub
						PubNubStart(PUBLISH_KEY,SUBSCRIBE_KEY)
						
						'add message
						AddText("Attempting to initialise PubNub",FONT_INFO)
					Else
						If PubNubLoaded()
							loaded = True
							loading = False
							
							'add message
							AddText("PubNub was initialised ok!",FONT_GOOD)
						EndIf
					EndIf
				EndIf
				
				'join channel
				If loaded = True
					if connecting = False
						connecting = true
						connected = False
						
						'start pubnub
						channel = PubNubSubscribe(CHANNEL_LOBBY)
						
						'add message
						AddText("Attempting to join channel '"+CHANNEL_LOBBY+"'",FONT_INFO)
					Else
						'look for finished connection
						if channel.Connected()
							connected = True
							connecting = false
							mode = "history"
							
							'add message
							AddText("You successfully joined the channel '"+channel.Id()+"'",FONT_GOOD)
							AddText(screenBufferHr,FONT_QUIET)
							AddText("Fetching chat history",FONT_QUIET)
							
							'get history
							channel.Fetch(20)
						EndIf
					EndIf
				EndIf
				
				'just handle keyboard for impatient people :D
				If keyboardResult.IsEmpty() = False
					keyboardResult.Clear()
					AddText("You are not connected yet!",FONT_QUIET)
				EndIf
				
			Case "history"
				UpdateKeyboard()
				
				'look for end of fetch
				If channel.Fetching() = False
					if channel.FetchAvailable()
						While channel.FetchAvailable()
							ProcessMessage(channel.NextFetch())
						Wend
					EndIf
					AddText(screenBufferHr,FONT_QUIET)
					
					'send connection message to pubnub
					channel.Send(String.FromChar(MESSAGE_USER_JOINED)+username)
					
					mode = "ready"
				EndIf
				
			Case "ready"
				UpdateKeyboard()
				
				'check for available keyboard result
				If keyboardResult.IsEmpty() = False
					Local text:string = keyboardResult.Top()
					keyboardResult.Clear()
					if text.Length > 0
						'check for commands or just text
						if text[0] = 47
							'split command text
							text = text[1..]
							Local pos := text.Find(" ")
							Local command:String
							if pos = -1
								command = text
							Else
								command = text[0..pos]
								text = text[pos+1..]
							EndIf
							
							'test commands
							Select command.ToLower()
								Case "me"
									'emote
									channel.Send(String.FromChar(MESSAGE_USER_EMOTE)+"* "+username+" "+text)
								Default
									'unknown command
									AddText("Unknown command!",FONT_QUIET)
							End
						Else
							'normal chat
							channel.Send(String.FromChar(MESSAGE_USER_CHAT)+"<"+username+"> "+text)
						EndIf
					EndIf
				EndIf
				
				'process incoming
				Local message:string
				While channel.MessageAvailable()
					ProcessMessage(channel.NextMessage())
				Wend
		End
	End
	
	Method OnRender()
		' --- render app ---
		IF screenChanged
			screenChanged = False
			Cls(0,0,0)
			SetColor(255,255,255)
			
			'render logo
			SetAlpha(0.1)
			DrawImage(logo,DeviceWidth()/2,DeviceHeight()/2,0,logoScale,logoScale)
			SetAlpha(1.0)
			
			'render input text
			Local text:String
			If keyboardBuffer.Length >= inputCharsHorizontal
				text = keyboardBuffer[keyboardBuffer.Length-inputCharsHorizontal..]
			Else
				text = keyboardBuffer
			EndIf
			Local textWidth := text.Length * FONT_WIDTH
			
			'text pointer and text
			SetFont(fonts[FONT_CHAT])
			DrawText(">",inputX-FONT_WIDTH-FONT_SPACING,inputY)
			DrawText(text,inputX,inputY)
			
			'cursor
			If keyboardCursorState
				SetColor(255,255,255)
			Else
				SetColor(55,55,55)
			EndIf
			DrawRect(inputX + FONT_SPACING + textWidth,inputY,FONT_WIDTH,FONT_HEIGHT)
			SetColor(255,255,255)
			
			'render the screen buffer
			Local screenX := screenBufferX
			Local screenY := screenBufferY+screenBufferHeight - FONT_HEIGHT
			Local screenColorDarkness:Float
			For Local index := 0 Until screenBufferText.Length
				screenColorDarkness = 1.0 - (0.7 / screenBufferCharsVertical) * index
				SetAlpha(screenColorDarkness)
				SetFont(fonts[screenBufferFont[index]])
				DrawText(screenBufferText[index],screenX,screenY)
				screenY = screenY - FONT_HEIGHT
			Next
		EndIf
	End
	
	Method UpdateKeyboard()
		' --- update keyboard input ---
		'do input
		Local char := GetChar()
		While char
			Select char
				Case CHAR_ENTER
					'return
					if keyboardBuffer.Length
						keyboardResult.Push(keyboardBuffer)
						keyboardBuffer = ""
						
						'flag screen update
						screenChanged = True
					EndIf
				Case CHAR_DELETE,CHAR_BACKSPACE
					'delete
					keyboardBuffer = keyboardBuffer[..keyboardBuffer.Length-1]
					'flag screen update
					screenChanged = True
				
				Default
					keyboardBuffer += String.FromChar(char)
					
					'flag screen update
					screenChanged = True
			End
			
			'next get char
			char = GetChar()
		wend
		
		'do cursor
		if keyboardCursorTime + 200 < ms
			keyboardCursorState = Not keyboardCursorState
			keyboardCursorTime = ms
			
			'flag screen update
			screenChanged = True
		EndIf
	End
	
	Method AddText(text:String,font:Int=FONT_CHAT)
		' --- add text to the screen buffer ---
		'figure out number of lines for new text
		Local rows:Int = Ceil(Float(text.Length) / screenBufferCharsHorizontal)
		if rows = 0 rows = 1
		
		'shift old text
		For Local index := screenBufferText.Length-1-rows to 0 step -1
			screenBufferText[index+rows] = screenBufferText[index]
			screenBufferFont[index+rows] = screenBufferFont[index]
		Next
		
		'add new text
		Local offset:Int
		For Local index = 0 until rows
			screenBufferText[rows-index-1] = text[offset..offset+screenBufferCharsHorizontal]
			screenBufferFont[rows-index-1] = font
			offset += screenBufferCharsHorizontal
		Next
		
		'flag screen update
		screenChanged = True
	End
	
	Method ProcessMessage(message:String)
		' --- process incoming message ---
		Local messageType:Int = message[0]
		message = message[1..]
			
		'process
		Select messageType
			Case MESSAGE_USER_CHAT
				AddText(message,FONT_CHAT)
			Case MESSAGE_USER_EMOTE
				AddText(message,FONT_EMOTE)
			Case MESSAGE_USER_JOINED
				AddText(message+" just joined!",FONT_GOOD)
		End
	End
End