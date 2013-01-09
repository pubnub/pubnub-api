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
package org.casalib.util {
	import flash.geom.Rectangle;
	import org.casalib.math.Percent;
	
	/**
		Provides utility functions for ratio scaling.
		
		@author Aaron Clinger
		@version 04/03/09
	*/
	public class RatioUtil {
		
		/**
			Determines the ratio of width to height.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
		*/
		public static function widthToHeight(size:Rectangle):Number {
			return size.width / size.height;
		}
		
		/**
			Determines the ratio of height to width.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
		*/
		public static function heightToWidth(size:Rectangle):Number {
			return size.height / size.width;
		}
		
		/**
			Scales an area's width and height while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param amount: The amount you wish to scale by.
			@param snapToPixel: Force the scale to whole pixels <code>true</code>, or allow sub-pixels <code>false</code>.
		*/
		public static function scale(size:Rectangle, amount:Percent, snapToPixel:Boolean = true):Rectangle {
			return RatioUtil._defineRect(size, size.width * amount.decimalPercentage, size.height * amount.decimalPercentage, snapToPixel);
		}
		
		/**
			Scales the width of an area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param height: The new height of the area.
			@param snapToPixel: Force the scale to whole pixels <code>true</code>, or allow sub-pixels <code>false</code>.
		*/
		public static function scaleWidth(size:Rectangle, height:Number, snapToPixel:Boolean = true):Rectangle {
			return RatioUtil._defineRect(size, height * RatioUtil.widthToHeight(size), height, snapToPixel);
		}
		
		/**
			Scales the height of an area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param width: The new width of the area.
			@param snapToPixel: Force the scale to whole pixels <code>true</code>, or allow sub-pixels <code>false</code>.
		*/
		public static function scaleHeight(size:Rectangle, width:Number, snapToPixel:Boolean = true):Rectangle {
			return RatioUtil._defineRect(size, width, width * RatioUtil.heightToWidth(size), snapToPixel);
		}
		
		/**
			Resizes an area to fill the bounding area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param bounds: The area to fill. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param snapToPixel: Force the scale to whole pixels <code>true</code>, or allow sub-pixels <code>false</code>.
		*/
		public static function scaleToFill(size:Rectangle, bounds:Rectangle, snapToPixel:Boolean = true):Rectangle {
			var scaled:Rectangle = RatioUtil.scaleHeight(size, bounds.width, snapToPixel);
			
			if (scaled.height < bounds.height)
				scaled = RatioUtil.scaleWidth(size, bounds.height, snapToPixel);
			
			return scaled;
		}
		
		/**
			Resizes an area to the maximum size of a bounding area without exceeding while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a <code>Rectangle</code>. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param bounds: The area the rectangle needs to fit within. The <code>Rectangle</code>'s <code>x</code> and <code>y</code> values are ignored.
			@param snapToPixel: Force the scale to whole pixels <code>true</code>, or allow sub-pixels <code>false</code>.
		*/
		public static function scaleToFit(size:Rectangle, bounds:Rectangle, snapToPixel:Boolean = true):Rectangle {
			var scaled:Rectangle = RatioUtil.scaleHeight(size, bounds.width, snapToPixel);
			
			if (scaled.height > bounds.height)
				scaled = RatioUtil.scaleWidth(size, bounds.height, snapToPixel);
			
			return scaled;
		}
		
		protected static function _defineRect(size:Rectangle, width:Number, height:Number, snapToPixel:Boolean):Rectangle {
			var scaled:Rectangle = size.clone();
			scaled.width         = snapToPixel ? Math.round(width) : width;
			scaled.height        = snapToPixel ? Math.round(height) : height;
			
			return scaled;
		}
	}
}