package org.hamcrest.collection
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.allOf;

    /**
     * Matches if the item being matched matches with all of the given matchers.
     *
     * Typically used to check if an Array has the expected items.
     *
     * @param ...rest Matcher or Object to be wrapped in <code>equalTo</code>
     *
     * @see org.hamcrest.collection#hasItem()
     * @see org.hamcrest.core#allOf()
     * @see org.hamcrest.object#equalTo()
     *
     * @example
     * <listing version="3.0">
     *  assertThat([1, 2, 3, 4], hasItems(equalTo(2), equalTo(4)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function hasItems(... rest):Matcher
    {
        return allOf.apply(null, rest.map(hasItemsIterator));
    }
}

import org.hamcrest.Matcher;
import org.hamcrest.collection.hasItem;

internal function hasItemsIterator(value:Object, i:int, a:Array):Matcher
{
    return hasItem(value);
}
