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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.system.LoaderContext;
	import org.casalib.load.CasaLoader;
	
	
	/**
		Provides an easy and standardized way to load images.
		
		@author Aaron Clinger
		@version 02/13/10
		@example
			<code>
				package {
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.ImageLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _imageLoad:ImageLoad;
						
						
						public function MyExample() {
							super();
							
							this._imageLoad = new ImageLoad("test.jpg");
							this._imageLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._imageLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							this.addChild(this._imageLoad.contentAsBitmap);
						}
					}
				}
			</code>
	*/
	public class ImageLoad extends CasaLoader {
		
		
		/**
			Creates and defines an ImageLoad.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file you wish to load.
			@param context: An optional LoaderContext object.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
			@throws <code>Error</code> if you try to load an empty <code>String</code> or <code>URLRequest</code>.
		*/
		public function ImageLoad(request:*, context:LoaderContext = null) {
			super(request, context);
		}
		
		/**
			The data received from the DataLoad data typed as Bitmap. Available after load is complete.
			
			@throws <code>Error</code> if method is called before the SWF has loaded.
			@throws <code>Error</code> if method cannot convert content to a Bitmap.
		*/
		public function get contentAsBitmap():Bitmap {
			if (!this.loaded || this.loaderInfo.contentType == CasaLoader.FLASH_CONTENT_TYPE)
				throw new Error('Cannot convert content to a Bitmap.');
			
			return this.content as Bitmap;
		}
		
		/**
			The data received from the DataLoad data typed as BitmapData. Available after load is complete.
			
			@throws <code>Error</code> if method is called before the SWF has loaded.
			@throws <code>Error</code> if method cannot convert content to BitmapData.
		*/
		public function get contentAsBitmapData():BitmapData {
			if (!this.loaded || this.loaderInfo.contentType == CasaLoader.FLASH_CONTENT_TYPE)
				throw new Error('Cannot convert content to BitmapData.');
			
			return this.contentAsBitmap.bitmapData;
		}
	}
}