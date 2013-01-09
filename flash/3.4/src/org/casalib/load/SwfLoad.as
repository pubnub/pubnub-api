/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2011, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package org.casalib.load {
	import flash.display.AVM1Movie;
	import flash.display.MovieClip;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import org.casalib.load.CasaLoader;
	import org.casalib.util.ClassUtil;
	
	
	/**
		Provides an easy and standardized way to load SWF files and external class assets.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 02/13/10
		@example
			<code>
				package {
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.SwfLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _swfLoad:SwfLoad;
						
						
						public function MyExample() {
							super();
							
							this._swfLoad = new SwfLoad("external.swf");
							this._swfLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._swfLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							this.addChild(this._swfLoad.contentAsMovieClip);
						}
					}
				}
			</code>
			
			For external classes:
			<code>
				package {
					import flash.display.DisplayObject;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.SwfLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _swfLoad:SwfLoad;
						
						
						public function MyExample() {
							super();
							
							this._swfLoad = new SwfLoad("myExternalLib.swf");
							this._swfLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._swfLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var externalAsset:DisplayObject = this._swfLoad.createClassByName("RedBox");
							
							this.addChild(externalAsset);
						}
					}
				}
			</code>
			
			For embedded SWFs:
			<code>
				package {
					import flash.display.DisplayObject;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.SwfLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _swfLoad:SwfLoad;
						
						[Embed(source="myExternalLib.swf", mimeType="application/octet-stream")]
						protected const Boxes:Class;
						
						
						public function MyExample() {
							super();
							
							this._swfLoad = new SwfLoad(Boxes);
							this._swfLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._swfLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var embeddedAsset:DisplayObject = this._swfLoad.createClassByName("RedBox");
							
							this.addChild(embeddedAsset);
						}
					}
				}
			</code>
	*/
	public class SwfLoad extends CasaLoader {
		protected var _classRequest:Class;
		
		
		/**
			Creates and defines a SwfLoad.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the SWF you wish to load or the <code>Class</code> of the embeded SWF.
			@param context: An optional LoaderContext object.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
			@throws <code>Error</code> if you try to load an empty <code>String</code> or <code>URLRequest</code>.
		*/
		public function SwfLoad(request:*, context:LoaderContext = null) {
			super(request, context);
		}
		
		/**
			The data received from the DataLoad data typed as MovieClip. Available after load is complete.
			
			@throws <code>Error</code> if method is called before the SWF has loaded.
			@throws <code>Error</code> if method cannot convert content to a MovieClip.
		*/
		public function get contentAsMovieClip():MovieClip {
			if (this.loaderInfo.contentType != CasaLoader.FLASH_CONTENT_TYPE)
				throw new Error('Cannot convert content to a MovieClip.');
			
			return this.content as MovieClip;
		}
		
		/**
			The data received from the DataLoad data typed as AVM1Movie. Available after load is complete.
			
			@throws <code>Error</code> if method is called before the SWF has loaded.
			@throws <code>Error</code> if method cannot convert content to an AVM1Movie.
		*/
		public function get contentAsAvm1Movie():AVM1Movie {
			if (this.loaderInfo.contentType != CasaLoader.FLASH_CONTENT_TYPE)
				throw new Error('Cannot convert content to an AVM1Movie.');
			
			return this.content as AVM1Movie;
		}
		
		/**
			Gets a public definition from the loaded SWF.
			
			@param name: The name of the definition.
			@return The object associated with the definition.
			@throws <code>Error</code> if method is called before the SWF has loaded.
		*/
		public function getDefinition(name:String):Object {
			if (!this.loaded)
				throw new Error('Cannot access an external asset until the SWF has loaded.');
			
			return this.loaderInfo.applicationDomain.getDefinition(name);
		}
		
		/**
			Checks to see if a public definition exists within the loaded SWF.
			
			@param name: The name of the definition.
			@return Returns <code>true</code> if the specified definition exists; otherwise <code>false</code>.
			@throws <code>Error</code> if method is called before the SWF has loaded.
		*/
		public function hasDefinition(name:String):Boolean {
			if (!this.loaded)
				throw new Error('Cannot access an external asset until the SWF has loaded.');
			
			return this.loaderInfo.applicationDomain.hasDefinition(name);
		}
		
		/**
			Retrieves an externally loaded class.
			
			@param className: The full name of the class you wish to receive from the loaded SWF.
			@return A Class reference.
			@throws <code>Error</code> if method is called before the SWF has loaded.
		*/
		public function getClassByName(className:String):Class {
			return this.getDefinition(className) as Class;
		}
		
		/**
			Instatiates an externally loaded class.
			
			@param className: The full name of the class you wish to instantiate from the loaded SWF.
			@param arguments: The optional parameters to be passed to the class constructor.
			@return A reference to the newly instantiated class.
			@throws <code>Error</code> if method is called before the SWF has loaded.
		*/
		public function createClassByName(className:String, arguments:Array = null):* {
			arguments ||= new Array();
			arguments.unshift(this.getClassByName(className));
			
			return ClassUtil.construct.apply(null, arguments);
		}
		
		override protected function _load():void {
			if (this._classRequest == null)
				this._loadItem.load(this._request, this._context);
			else
				this._loadItem.loadBytes(new this._classRequest() as ByteArray, this._context);
		}
		
		override protected function _createRequest(request:*):void {
			if (request is Class)
				this._classRequest = request;
			else
				super._createRequest(request);
		}
	}
}