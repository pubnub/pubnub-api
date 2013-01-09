package org.hamcrest.core
{
	import org.hamcrest.Matcher;

	/**
	 * Matches if a specified Boolean condition evaluates to true.
	 * 
	 * Used in coordination with <code>anyOf</code> and <code>allOf</code> to express 
	 * conditional logic as a short-circuit functional style conditional expression.
	 * 
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
	public function evaluate( condition:Boolean ):Matcher
	{
		return new EvaluateMatcher( condition );
	}
}