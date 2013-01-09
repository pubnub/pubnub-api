package org.hamcrest.object
{
  import org.hamcrest.Matcher;
  
  /**
   * Matches item if it can be coerced to <code>true</code>.
   * 
   * @see org.hamcrest.object#isTrue() for a strict truthiness matcher.
   * 
   * @example
   * <listing version="3.0">
   *  assertThat( checkBox.selected, isTruthy() );
   * </listing>
   * 
   * @author Drew Bourne
   */
  public function isTruthy():Matcher 
  {
    return new IsTrueMatcher(true);
  }
}