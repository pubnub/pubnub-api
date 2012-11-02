package org.hamcrest.object
{
  import org.hamcrest.Matcher;
  
  /**
   * Matches item if it is strictly equal to <code>true</code>. 
   * 
   * @see org.hamcrest.object#isTruthy() for a non-strict truthiness matcher.
   * 
   * @example
   * <listing version="3.0">
   *  assertThat( checkBox.selected, isTrue() );
   * </listing>
   * 
   * @author Drew Bourne
   */
  public function isTrue():Matcher 
  {
    return new IsTrueMatcher();
  }
}