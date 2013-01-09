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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.casalib.util.ConversionUtil;
	import org.casalib.util.NumberUtil;
	
	
	/**
		Utilities for positioning, calculating and manipulating geometeric shapes and points.
		
		@author Aaron Clinger
		@author Jon Adams
		@version 05/11/11
	*/
	public class GeomUtil {
		
		
		/**
			Rotates a <code>Point</code> around another <code>Point</code> by the specified angle.
			
			@param point: The <code>Point</code> to rotate.
			@param centerPoint: The <code>Point</code> to rotate the <code>Point</code> around.
			@param angle: The angle (in degrees) to rotate the <code>Point</code>.
		*/
		public static function rotatePoint(point:Point, centerPoint:Point, angle:Number):void {
			const radians:Number = ConversionUtil.degreesToRadians(angle);
			const baseX:Number   = point.x - centerPoint.x;
			const baseY:Number   = point.y - centerPoint.y;
			
			point.x = (Math.cos(radians) * baseX) - (Math.sin(radians) * baseY) + centerPoint.x;
			point.y = (Math.sin(radians) * baseX) + (Math.cos(radians) * baseY) + centerPoint.y;
		}
		
		/**
			Determines the angle/degree between the first and second <code>Point</code>.
			
			@param first: The first <code>Point</code>.
			@param second: The second <code>Point</code>.
			@return The degree between the two points.
		*/
		public static function angle(first:Point, second:Point):Number {
			return Math.atan2(second.y - first.y, second.x - first.x) / (Math.PI / 180);
		}
		
		/**
			Places a <code>Point</code> randomly within a defined area.
			
			@param area: The area in which to randomly place the <code>Point</code>.
			@param snapToPixel: If the <code>Point</code> should only be placed on whole pixels <code>true</code>, or allow placement on sub-pixels <code>false</code>; defaults to <code>true</code>.
			@return A randomly placed <code>Point</code> within the defined bounds.
		*/
		public static function randomlyPlacePoint(area:Rectangle, snapToPixel:Boolean = true):Point {
			if (snapToPixel)
				return new Point(NumberUtil.randomIntegerWithinRange(Math.ceil(area.x), Math.floor(area.right)), NumberUtil.randomIntegerWithinRange(Math.ceil(area.y), Math.floor(area.bottom)));
			
			return new Point(NumberUtil.randomWithinRange(area.x, area.right), NumberUtil.randomWithinRange(area.y, area.bottom));
		}
		
		/**
			Places a <code>Rectangle</code> randomly within a defined area.
			
			@param area: The area in which to randomly place the <code>Rectangle</code>.
			@param rect: The <code>Rectangle</code> to randomly place within the bounds.
			@param snapToPixel: If the <code>Rectangle</code> should only be placed on whole pixels <code>true</code>, or allow placement on sub-pixels <code>false</code>; defaults to <code>true</code>.
			@return A new randomly placed <code>Rectangle</code> within the defined bounds.
			@throws <code>Error</code> if the area is too small to contain the <code>Rectangle</code>.
		*/
		public static function randomlyPlaceRectangle(area:Rectangle, rect:Rectangle, snapToPixel:Boolean = true):Rectangle {
			const zone:Rectangle = area.clone();
			const size:Rectangle = rect.clone();
			size.x               = area.x;
			size.y               = area.y;
			
			if ( ! zone.containsRect(size))
				throw new Error('Area needs to be large enough to contain the rectangle.');
				
			zone.right  -= size.width;
			zone.bottom -= size.height;
			
			const point:Point = GeomUtil.randomlyPlacePoint(zone, snapToPixel);
			
			return new Rectangle(point.x, point.y, rect.width, rect.height);
		}
		
		/**
			Takes the provided <code>Rectangle</code> and returns a new <code>Rectangle</code> that is flipped (width becomes height, height becomes width).
			
			@param rect: The <code>Rectangle</code> to flip.
			@return A new <code>Rectangle</code> that is flipped.
			@usageNote The <code>Rectangle</code>'s X and Y are unaffected.
		*/
		public static function flipRectangle(rect:Rectangle):Rectangle {
			return new Rectangle(rect.x, rect.y, rect.height, rect.width);
		}
		
		/**
			Calculates the perimeter of a <code>Rectangle</code>.
			
			@param rect: <code>Rectangle</code> to determine the perimeter of.
			@return The <code>Rectangle</code>'s perimeter.
		*/
		public static function getRectanglePerimeter(rect:Rectangle):Number {
			return rect.width * 2 + rect.height * 2;
		}
		
		/**
			Takes any degree value and returns the normalized 0-360 degree equivalent.
			
			@param degree: The degree to normalize.
			@return Returns a degree value between <code>0 </code> and <code>360</code>.
			@example
				<code>
					trace(GeomUtil.normalizeDegree(-90)); // Traces "270"
					trace(GeomUtil.normalizeDegree(1080)); // Traces "0"
				</code>
		*/
		public static function normalizeDegree(degree:Number):Number {
			degree %= 360;
			
			return (degree < 0) ? degree + 360 : degree;
		}
		
		/**
			Determines the shortest distance and direction between two degrees.
			
			@param startDegree: The first degree.
			@param endDegree: The second degree.
			@return Returns a degree value between <code>-180</code> and <code>180</code>.
			@example
				<code>
					trace(GeomUtil.distanceBetweenDegrees(45, 100)); // Traces "55"
					trace(GeomUtil.distanceBetweenDegrees(270, 10)); // Traces "100"
					trace(GeomUtil.distanceBetweenDegrees(0, 190)); // Traces "-170"
				</code>
		*/
		public static function distanceBetweenDegrees(startDegree:Number, endDegree:Number):Number {
			const start:Number = GeomUtil.normalizeDegree(startDegree);
			const end:Number   = GeomUtil.normalizeDegree(endDegree);
			const dif:Number   = Math.abs(start - end);
			var dis:Number     = (dif > 180) ? 360 - dif : dif;
			
			if (end != GeomUtil.normalizeDegree(start + dis))
				dis *= -1;
			
			return dis;
		}
	}
}