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
	import flash.display.MovieClip;
	import org.casalib.errors.ArguementTypeError;
	
	
	/**
		Utilities for determining label positions and adding and removing frame scripts.
		
		@author Mike Creighton
		@author Aaron Clinger
		@version 02/12/10
	*/
	public class FrameUtil {
		
		
		/**
			Determines the frame number for the specified label.
			
			@param target: The MovieClip to search for the frame label in.
			@param label: The name of the frame label.
			@return The frame number of the label or <code>-1</code> if the frame label was not found.
		*/
		public static function getFrameNumberForLabel(target:MovieClip, label:String):int {
			var labels:Array = target.currentLabels;
			var l:int        = labels.length;
			
			while (l--)
				if (labels[l].name == label)
					return labels[l].frame;
			
			return -1;
		}
		
		/**
			Calls a specified method when a specific frame is reached in a MovieClip timeline.
			
			@param target: The MovieClip that contains the <code>frame</code>.
			@param frame: The frame to be notified when reached. Can either be a frame number (<code>uint</code>), or the frame label (<code>String</code>).
			@param notify: The function that will be called when the frame is reached.
			@return Returns <code>true</code> if the frame was found; otherwise <code>false</code>.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or <code>uint</code> to parameter <code>frame</code>.
		*/
		public static function addFrameScript(target:MovieClip, frame:*, notify:Function):Boolean {
			if (frame is String)
				frame = FrameUtil.getFrameNumberForLabel(target, frame);
			else if (!(frame is uint))
				throw new ArguementTypeError('frame');
			
			if (frame == -1 || frame == 0 || frame > target.totalFrames)
				return false;
			
			target.addFrameScript(frame - 1, notify);
			
			return true;
		}
		
		/**
			Removes a frame from triggering/calling a function when reached.
			
			@param target: The MovieClip that contains the <code>frame</code>.
			@param frame: The frame to remove notification from. Can either be a frame number (<code>uint</code>), or the frame label (<code>String</code>).
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or <code>uint</code> to parameter <code>frame</code>.
		*/
		public static function removeFrameScript(target:MovieClip, frame:*):void {
			if (frame is String)
				frame = FrameUtil.getFrameNumberForLabel(target, frame);
			else if (!(frame is uint))
				throw new ArguementTypeError('frame');
			
			if (frame == -1 || frame == 0 || frame > target.totalFrames)
				return;
			
			target.addFrameScript(frame - 1, null);
		}
	}
}