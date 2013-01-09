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
	import org.casalib.util.ConversionUtil;
	import org.casalib.util.NumberUtil;
	import org.casalib.math.Percent;
	
	/**
		Utilities for calculating a load's speed and progress.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 01/08/09
	*/
	public class LoadUtil {
		
		
		/**
			Calculates the load speed in bytes per second (Bps).
			
			@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
			@param startTime: Time in milliseconds when the load started.
			@param elapsedTime: Time in milliseconds since the load started or time when load completed.
			@return Bytes per second.
			@usageNote This method returns BYTES per second, not bits per second.
		*/
		public static function calculateBps(bytesLoaded:uint, startTime:uint, elapsedTime:uint):int {
			return Math.max(0, (bytesLoaded / ConversionUtil.millisecondsToSeconds(elapsedTime - startTime)));
		}
		
		/**
			Calculates the load speed in kilobytes per second (kBps).
			
			@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
			@param startTime: Time in milliseconds when the load started.
			@param elapsedTime: Time in milliseconds since the load started or time when load completed.
			@return Kilobytes per second.
			@usageNote This method returns kiloBYTES per second, not kilobits per second.
		*/
		public static function calculateKBps(bytesLoaded:uint, startTime:uint, elapsedTime:uint):Number {
			return ConversionUtil.bytesToKilobytes(LoadUtil.calculateBps(bytesLoaded, startTime, elapsedTime));
		}
		
		/**
			Calculates the percent the video has buffered.
			
			@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
			@param bytesTotal: Number of bytes total to be loaded.
			@param startTime: Time in milliseconds when the load started.
			@param elapsedTime: The current time in milliseconds or time when load completed.
			@param lengthInMilliseconds: The total duration/length of the video in milliseconds.
			@return The percent buffered.
		*/
		public static function calculateBufferPercent(bytesLoaded:uint, bytesTotal:uint, startTime:uint, elapsedTime:uint, lengthInMilliseconds:uint):Percent {
			var totalWait:Number           = bytesTotal / (bytesLoaded / (elapsedTime - startTime)) - lengthInMilliseconds;
			var millisecondsRemaining:uint = LoadUtil.calculateMillisecondsUntilBuffered(bytesLoaded, bytesTotal, startTime, elapsedTime, lengthInMilliseconds);
			
			return (totalWait == Number.POSITIVE_INFINITY) ? new Percent(0) : new Percent(NumberUtil.constrain(1 - millisecondsRemaining / totalWait, 0, 1));
		}
		
		/**
			Calculates the remaining time until the video is buffered.
			
			@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
			@param bytesTotal: Number of bytes total to be loaded.
			@param startTime: Time in milliseconds when the load started.
			@param elapsedTime: The current time in milliseconds or time when load completed.
			@param lengthInMilliseconds: The total duration/length of the video in milliseconds.
			@return The amount millisecond that remain before the video is buffered.
		*/
		public static function calculateMillisecondsUntilBuffered(bytesLoaded:uint, bytesTotal:uint, startTime:uint, elapsedTime:uint, lengthInMilliseconds:uint):uint {
			return Math.max(Math.ceil((bytesTotal - bytesLoaded) / (bytesLoaded / (elapsedTime - startTime))) - lengthInMilliseconds, 0);
		}
	}
}