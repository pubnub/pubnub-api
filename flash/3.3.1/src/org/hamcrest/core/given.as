package org.hamcrest.core
{
	import org.hamcrest.Matcher;
	import org.hamcrest.object.equalTo;
	
	/**
	 * Conditionally matches a value or Matcher. 
	 * 
	 * Used in coordination with <code>anyOf</code> and <code>allOf</code> to express 
	 * conditional logic as a short-circuit functional style conditional expression.
	 *  
	 * Syntax shortcut (vs <code>evaluate()</code>) for expressing simple conditional matcher logic.
	 * 
	 * If the specified <code>condition</code> is true, matches the specified value or Matcher.  
	 * Else, it either matches or does not match depending on the optional <code>otherwise</code> parameter.
	 * 
	 * @see org.hamcrest.core#evaluate()
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
	public function given( condition:Boolean, valueOrMatcher:Object, otherwise:Boolean = false ):Matcher
	{
		var valueMatcher:Matcher = valueOrMatcher is Matcher
			? valueOrMatcher as Matcher
			: equalTo( valueOrMatcher );
		
		return new GivenMatcher( condition, valueMatcher, otherwise );
	}
}