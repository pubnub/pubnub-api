package org.hamcrest.object
{
  import org.hamcrest.Matcher;
  
  /**
   * Matches item if it can be coerced to <code>false</code>. 
   * 
   * @see org.hamcrest.object#isTruthy() for a strict falsiness matcher.
   * 
   * @example
   * <listing version="3.0">
   *  assertThat( input.text, isFalsey() );
   * </listing>
   * 
   * @author Drew Bourne
   */
  public function isFalsey():Matcher 
  {
    return new IsFalseMatcher(true);
  }
}