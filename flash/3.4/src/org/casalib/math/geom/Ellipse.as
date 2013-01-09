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
package org.casalib.math.geom {
	import flash.geom.Point;
	
	/**
		Stores position and size of an ellipse (circle or oval).
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 04/13/08
	*/
	public class Ellipse {
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:Number;
		protected var _height:Number;
		
		
		/**
			Creates new Ellipse object.
			
			@param x: The horizontal position of the ellipse.
			@param y: The vertical position of the ellipse.
			@param width: Width of the ellipse at its widest horizontal point.
			@param height: Height of the ellipse at its tallest point.
		*/
		public function Ellipse(x:Number, y:Number, width:Number, height:Number) {
			this.x      = x;
			this.y      = y;
			this.width  = width;
			this.height = height;
		}
		
		/**
			The horizontal coordinate of the point.
		*/
		public function get x():Number {
			return this._x;
		}
		
		public function set x(xPos:Number):void {
			this._x = xPos;
		}
		
		/**
			The vertical coordinate of the point.
		*/
		public function get y():Number {
			return this._y;
		}
		
		public function set y(yPos:Number):void {
			this._y = yPos;
		}
		
		/**
		 	The width of the ellipse.
		*/
		public function get width():Number {
			return this._width;
		}
		
		public function set width(width:Number):void {
			this._width = width;
		}
		
		/**
		 	The height of the rectangle.
		*/
		public function get height():Number {
			return this._height;
		}
		
		public function set height(height:Number):void {
			this._height = height;
		}
		
		/**
			The center of the ellipse.
		*/
		public function get center():Point {
			return new Point(this.x + this.width * 0.5, this.y + this.height * 0.5);
		}
		
		public function set center(c:Point):void {
			this.x = c.x - this.width * 0.5;
			this.y = c.y - this.height * 0.5;
		}
		
		/**
			The size of the ellipse, expressed as a Point object with the values of the width and height properties.
		*/
		public function get size():Point {
			return new Point(this.width, this.height);
		}
		
		/**
			The circumference of the ellipse.
			
			@usageNote Calculating the circumference of an ellipse is difficult; this is an approximation but should be accurate for most cases.
		*/
		public function get perimeter():Number {
			return (Math.sqrt(0.5 * (Math.pow(this.width, 2) + Math.pow(this.height, 2))) * Math.PI * 2) * 0.5;
		}
		
		/**
			The area of the ellipse.
		*/
		public function get area():Number {
			return Math.PI * (this.width * 0.5) * (this.height * 0.5);
		}
		
		/**
			Finds the <code>x</code>, <code>y</code> position of the degree along the circumference of the ellipse.
			
			@param degree: Number representing a degree on the ellipse.
			@return A Point object.
			@usageNote <code>degree</code> can be over 360 or even negitive numbers; minding <code>0 = 360 = 720</code>, <code>540 = 180</code>, <code>-90 = 270</code>, etc.
		*/
		public function getPointOfDegree(degree:Number):Point {
			var radian:Number  = (degree - 90) * (Math.PI / 180);
			var xRadius:Number = this.width * 0.5;
			var yRadius:Number = this.height * 0.5;
			
			return new Point(this.x + xRadius + Math.cos(radian) * xRadius, this.y + yRadius + Math.sin(radian) * yRadius);
		}
		
		/**
			Finds if a point is contained inside of the ellipse perimeter.
			
			@param point: A Point object.
			@return Returns <code>true</code> if shape's area contains point; otherwise <code>false</code>.
		*/
		public function containsPoint(point:Point):Boolean {
			var xRadius:Number = this.width * 0.5;
			var yRadius:Number = this.height * 0.5;
			var xTar:Number    = point.x - this.x - xRadius;
			var yTar:Number    = point.y - this.y - yRadius;
			
			return Math.pow(xTar / xRadius, 2) + Math.pow(yTar / yRadius, 2) <= 1;
		}
		
		/**
			Determines if the Ellipse specified in the <code>ellipse</code> parameter is equal to this Ellipse object.
			
			@param ellipse: An Ellipse object.
			@return Returns <code>true</code> if object is equal to this Ellipse; otherwise <code>false</code>.
		*/
		public function equals(ellipse:Ellipse):Boolean {
			return this.x == ellipse.x && this.y == ellipse.y && this.width == ellipse.width && this.height == ellipse.height;
		}
		
		/**
			@return A new Ellipse object with the same values as this Ellipse.
		*/
		public function clone():Ellipse {
			return new Ellipse(this.x, this.y, this.width, this.height);
		}
	}
}