package com.sample.pubnubunittest.gui;

import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.sample.pubnubunittest.unittest.CL_155;
import com.sample.pubnubunittest.unittest.CL_165;
import com.sample.pubnubunittest.unittest.CL_216;
import com.sample.pubnubunittest.unittest.CL_259;

public class ItemDetailFragment extends Fragment {

    public static final String ARG_ITEM_ID = "item_id";
    UnitTestExicute exicute=null;
    MenuItemContent.MenuItem mItem;
    TextView text;
    public ItemDetailFragment() {
    }
    

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments().containsKey(ARG_ITEM_ID)) {
            mItem = MenuItemContent.ITEM_MAP.get(getArguments().getString(ARG_ITEM_ID));
           
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_item_detail, container, false);
        if (mItem != null) {
             text= (TextView) rootView.findViewById(R.id.item_detail);
             exicute= new UnitTestExicute();
             exicute.execute(mItem.id+"");
        }
        return rootView;
    }
    
    Handler handler= new Handler()
    {
    	@Override
    	public void handleMessage(Message msg) {
    		// TODO Auto-generated method stub
    		super.handleMessage(msg);
    		String message=msg.getData().getString("MESSAGE");
    		text.setText(text.getText()+"\n"+message);
    	}
    	
    };
    public void onDestroy() {
    	
    	if(exicute !=null)
    	{
    		exicute.cancel(true);
    	}
    	super.onDestroy();
    };
    
    class UnitTestExicute extends AsyncTask<String, Void, Boolean> {

        @Override
        protected Boolean doInBackground(String... params) {
           
        	int id=Integer.parseInt(params[0]);
        	
        	switch (id) {
			case 1:
				CL_155 ut= new  CL_155();
	        	ut.RunUnitTest(handler);
				break;
			case 2:
				CL_165 cl165= new CL_165();
				cl165.RunUnitTest(handler);
				break;
			case 3:
				CL_216 cl216= new CL_216();
				cl216.RunUnitTest(handler);
				break;
			case 4:
				CL_259 cl259= new CL_259();
				cl259.RunUnitTest(handler);
				break;
			default:
				break;
			}
        
              
            return Boolean.TRUE;
        }

        @Override
        protected void onPreExecute() {
        }

        protected void onPostExecute(Boolean result) {
        }
    }
    
}
