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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.casalib.core.IDestroyable;
	
	
	/**
		Provides utility functions for DisplayObjects/DisplayObjectContainers.
		
		@author Aaron Clinger
		@author Jon Adams
		@version 10/09/11
	*/
	public class DisplayObjectUtil {
		
		
		/**
			Removes and optionally destroys children of a <code>DisplayObjectContainer</code> or the states of a <code>SimpleButton</code>.
			
			@param parent: The <code>DisplayObjectContainer</code> from which to remove children or a <code>SimpleButton</code> from which to remove its states.
			@param destroyChildren: If a child implements {@link IDestroyable} call its {@link IDestroyable#destroy destroy} method <code>true</code>, or don't destroy <code>false</code>; defaults to <code>false</code>.
			@param recursive: Call this method with the same arguments on all of the children's children (all the way down the display list) <code>true</code>, or leave the children's children <code>false</code>; defaults to <code>false</code>.
		*/
		public static function removeAllChildren(parent:DisplayObject, destroyChildren:Boolean = false, recursive:Boolean = false):void {
			if (parent is SimpleButton) {
				DisplayObjectUtil._removeButtonStates(parent as SimpleButton, destroyChildren, recursive);
				return;
			} else if (parent is Loader || !(parent is DisplayObjectContainer))
				return;
			
			const container:DisplayObjectContainer = parent as DisplayObjectContainer;
			
			while (container.numChildren)
				DisplayObjectUtil._checkChild(container.removeChildAt(0), destroyChildren, recursive);
		}
		
		/**
			Returns the children of a <code>DisplayObjectContainer</code> as an <code>Array</code>.
			
			@param parent: The <code>DisplayObjectContainer</code> from which to get the children from.
			@return All the children of the <code>DisplayObjectContainer</code>.
		*/
		public static function getChildren(parent:DisplayObjectContainer):Array {
			const children:Array = new Array();
			var i:int            = -1;
			
			while (++i < parent.numChildren)
				children.push(parent.getChildAt(i));
			
			return children;
		}
		
		/**
			Returns the X and Y offset to the top left corner of the <code>DisplayObject</code>. The offset can be used to position <code>DisplayObject</code>s whose alignment point is not at 0, 0 and/or is scaled.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@return The X and Y offset to the top left corner of the <code>DisplayObject</code>.
			@example
				<code>
					var box:CasaSprite = new CasaSprite();
					box.scaleX         = -2;
					box.scaleY         = 1.5;
					box.graphics.beginFill(0xFF00FF);
					box.graphics.drawRect(-20, 100, 50, 50);
					box.graphics.endFill();
					
					const offset:Point = DisplayObjectUtil.getOffsetPosition(box);
					
					trace(offset)
					
					box.x = 10 + offset.x;
					box.y = 10 + offset.y;
					
					this.addChild(box);
				</code>
		*/
		public static function getOffsetPosition(displayObject:DisplayObject):Point {
			const bounds:Rectangle = displayObject.getBounds(displayObject);
			const offset:Point     = new Point();
			
			offset.x = (displayObject.scaleX > 0) ? bounds.left * displayObject.scaleX * -1 : bounds.right * displayObject.scaleX * -1;
			offset.y = (displayObject.scaleY > 0) ? bounds.top * displayObject.scaleY * -1 : bounds.bottom * displayObject.scaleY * -1;
			
			return offset;
		}
		
		/**
			Returns the first display object with the specified name that exists in the display tree of the provided <code>DisplayObjectContainer</code>.
			
			@param parent: The <code>DisplayObjectContainer</code> in which to get the child from.
			@param name: The name of the child to return.
			@return The first child display object with the specified name, or <code>null</code> if no display object was found.
		*/
		public static function getChildByNameRecursive(parent:DisplayObjectContainer, name:String):DisplayObject {
			var child:DisplayObject = parent.getChildByName(name);
			
			if (child != null)
				return child;
			
			var i:int = -1;
			
			while (++i < parent.numChildren) {
				child = parent.getChildAt(i);
				
				if (child is DisplayObjectContainer) {
					child = DisplayObjectUtil.getChildByNameRecursive(child as DisplayObjectContainer, name);
					
					if (child != null)
						return child;
				}
			}
			
			return null;
		}
		
		protected static function _removeButtonStates(parent:SimpleButton, destroyStates:Boolean, recursive:Boolean):void {
			if (parent.downState != null) {
				DisplayObjectUtil._checkChild(parent.downState, destroyStates, recursive);
				parent.downState = null;
			}
			
			if (parent.hitTestState != null) {
				DisplayObjectUtil._checkChild(parent.hitTestState, destroyStates, recursive);
				parent.hitTestState = null;
			}
			
			if (parent.overState != null) {
				DisplayObjectUtil._checkChild(parent.overState, destroyStates, recursive);
				parent.overState = null;
			}
			
			if (parent.upState != null) {
				DisplayObjectUtil._checkChild(parent.upState, destroyStates, recursive);
				parent.upState = null;
			}
		}
		
		protected static function _checkChild(child:DisplayObject, destroy:Boolean, recursive:Boolean):void {
			if (destroy && child is IDestroyable) {
				const dest:IDestroyable = child as IDestroyable;
				
				if (!dest.destroyed)
					dest.destroy();
			}
			
			if (recursive)
				DisplayObjectUtil.removeAllChildren(child, destroy, recursive);
		}
	}
}