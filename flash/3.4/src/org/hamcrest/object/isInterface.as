package org.hamcrest.object
{
	import org.hamcrest.Matcher;

	/**
	 * Matches a Class reference that defines an interface.
	 *  
	 * @example
	 * <listing version="3.0">
	 *	assertThat(IExternalizable, isInterface()); 
	 * </listing>
	 */
	public function isInterface():Matcher
	{
		return new IsInterfaceMatcher();
	}
}