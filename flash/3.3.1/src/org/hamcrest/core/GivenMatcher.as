package org.hamcrest.core
{
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	
	/**
	 * Conditionally matches a Matcher.
	 * 
	 * Used in coordination with <code>AnyOfMatcher</code> and <code>AllOfMatcher</code> to express 
	 * conditional logic as a short-circuit functional style conditional expression.
	 * 
	 * Syntax shortcut (vs <code>EvaluateMatcher</code>) for expressing simple conditional matcher logic.
	 * 
	 * If the specified <code>condition</code> is true, matches the specified Matcher.  
	 * Else, it either matches or does not match depending on the optional <code>otherwise</code> parameter.
	 * 
	 * @see org.hamcrest.core#given()
	 * 
	 * @example
	 * <listing version="3.0">
	 *  assertThat( "given quantity is restricted, quantity is less than 5", given( ( model.isQuantityRestricted == true ), lessThanOrEqualTo( 5 ) ), model.quantity );
	 *  assertThat( "given valueInput is enabled, valueInput contains required substring, otherwise true", given( valueInput.enabled, containsString( "required substring" ), valueInput.text ) );
	 *  assertThat( "given another matcher matches the value, value is equal to 5", given( anotherMatcher.matches( value ), equalTo( 5 ), value ) );
	 * </listing>
	 * 
	 * @author John Yanarella
	 */
	public class GivenMatcher extends BaseMatcher
	{
		// ========================================
		// Protected properties
		// ========================================	

		/**
		 * Implicitly evaluated Boolean condition.
		 */
		protected var _condition:Boolean;

		/**
		 * Matcher to evaluate if the given <code>condition</code> is true.
		 */
		protected var _valueMatcher:Matcher;

		/**
		 * Optional matching result to return if the given <code>condition</code> is false.
		 */
		protected var _otherwise:Boolean;
		
		// ========================================
		// Constructor
		// ========================================	

		/**
		 * Constructor.
		 *
		 * @param condition A Boolean condition.
		 */
		public function GivenMatcher( condition:Boolean, valueMatcher:Matcher, otherwise:Boolean = false )
		{
			super();
			
			_condition = condition;
			_valueMatcher = valueMatcher;
			_otherwise = otherwise;
		}
		
		// ========================================
		// Public methods
		// ========================================	
		
		/**
		 * Matches if the specified Boolean condition evaluates to true
		 */
		override public function matches( item:Object ):Boolean
		{
			if ( _condition )
				return _valueMatcher.matches( item );
			else
				return _otherwise;
		}

		/**
		 * @inheritDoc
		 */
		override public function describeTo( description:Description ):void
		{
			if ( _condition )
			{
				description.appendText("given a condition that evaluates as ")
					.appendValue( _condition )
					.appendText( ", " )
					.appendDescriptionOf( _valueMatcher );
			}
			else
			{
				description.appendText("given a condition that evaluates as ")
					.appendValue( _condition );
				
				if ( _otherwise )
				{
					description.appendText(", where otherwise was specified as ")
						.appendValue( _otherwise );
				}
			}
		}	
	}
}
