package com.sample.pubnubunittest.gui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MenuItemContent {

    public static class MenuItem {

        public String id;
        public String content;

        public MenuItem(String id, String content) {
            this.id = id;
            this.content = content;
        }

        @Override
        public String toString() {
            return content;
        }
    }

    public static List<MenuItem> ITEMS = new ArrayList<MenuItem>();
    public static Map<String, MenuItem> ITEM_MAP = new HashMap<String, MenuItem>();

    static {
        addItem(new MenuItem("1", "CL-155"));
        addItem(new MenuItem("2", "CL-165"));
        addItem(new MenuItem("3", "CL-216"));
        addItem(new MenuItem("4", "CL-259"));
     
    }

    private static void addItem(MenuItem item) {
        ITEMS.add(item);
        ITEM_MAP.put(item.id, item);
    }
}
