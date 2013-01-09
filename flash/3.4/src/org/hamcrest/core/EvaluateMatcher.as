package org.hamcrest.core
{
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;
	
	/**
	 * Matches if a specified Boolean condition evaluates to true.
	 * 
	 * Used in coordination with <code>AnyOfMatcher</code> and <code>AllOfMatcher</code> to express 
	 * conditional logic as a short-circuit functional style conditional expression.
	 * 
	 * @see org.hamcrest.core#evaluate()
	 * @see org.hamcrest.core#given()
	 *
	 * @example
	 * <listing version="3.0">
	 *  assertThat( "evaluate 1 + 1 = 2", evaluate( 1 + 1 == 2 ) );
	 *  assertThat( "evaluate nameInput.enabled", evaluate( nameInput.enabled ), nameInput.text );
	 *  assertThat( "evaluate anotherMatcher match", evaluate( anotherMatcher.matches( value ) ), value );
	 * </listing>
	 *
	 * @author John Yanarella
	 */
	public class EvaluateMatcher extends BaseMatcher
	{
		// ========================================
		// Protected properties
		// ========================================	

		/**
		 * Boolean condition to be evaluated.
		 */
		protected var _condition:Boolean;
		
		// ========================================
		// Constructor
		// ========================================	

		/**
		 * Constructor.
		 *
		 * @param condition A Boolean condition.
		 */
		public function EvaluateMatcher(condition:Boolean)
		{
			super();
			
			_condition = condition;
		}

		// ========================================
		// Public methods
		// ========================================	

		/**
		 * Matches if the specified Boolean condition evaluates to true
		 */
		override public function matches(item:Object):Boolean
		{
			return _condition;
		}

		/**
		 * @inheritDoc
		 */
		override public function describeTo( description:Description ):void
		{
			description.appendText("a condition that evaluates as ")
				.appendValue( _condition );
		}	
	}
}
