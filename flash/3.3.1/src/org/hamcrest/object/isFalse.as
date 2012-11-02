package org.hamcrest.object
{
  import org.hamcrest.Matcher;
  
  /**
   * Matches item if it is strictly equal to <code>false</code>. 
   * 
   * @see org.hamcrest.object#isTruthy() for a non-strict falsiness matcher.
   * 
   * @example
   * <listing version="3.0">
   *  assertThat( checkBox.selected, isFalse() );
   * </listing>
   * 
   * @author Drew Bourne
   */
  public function isFalse():Matcher 
  {
    return new IsFalseMatcher();
  }
}