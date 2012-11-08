package org.hamcrest.object
{
  import org.hamcrest.BaseMatcher;
  import org.hamcrest.Description;

  /**
   * Matches item if it is <code>false</code>.
   * 
   * When the constructor parameter <code>coerceToBoolean</code> is <code>true</code> 
   * Then any false-like value will also be matched. These include: <code>null</code>,
   * <code>0</code>, <code>NaN</code> <code>&quot;&quot;</code> (empty string).
   * 
   * @example
   * <listing version="3.0">
   *  assertThat( checkBox.selected, isFalse() );
   * </listing>
   */
  public class IsFalseMatcher extends BaseMatcher
  {
    private var _coerceToBoolean:Boolean;
    
    /**
     * Constructor.
     * 
     * @param coerceToBoolean Indicates if the Matcher should coerce the item 
     * being matched to a Boolean before strictly comparing to <code>false</code>. 
     */
    public function IsFalseMatcher(coerceToBoolean:Boolean = false)
    {
      super();
      
      _coerceToBoolean = coerceToBoolean;
    }
    
    override public function matches(item:Object):Boolean
    {
      return _coerceToBoolean
        ? Boolean(item) === false
        : item === false;
    }
    
    /**
     * Description of <code>isFalse()</code>, <code>"is false"</code>.
     */
    override public function describeTo(description:Description):void
    {
      description.appendText("is false");
    }
  }
}