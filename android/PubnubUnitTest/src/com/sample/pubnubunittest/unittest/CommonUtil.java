package com.sample.pubnubunittest.unittest;

import java.math.BigDecimal;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class CommonUtil {

	static Handler mHandler;
	
	public static void setHandler(Handler pHandler)
	{
		mHandler=pHandler;
	}
	
	  public static  String getBigDecimal(double time) {

          BigDecimal big = new BigDecimal(time);
          return big.toString();
      }
	  
	  public static void PrintLog(String text)
      {
      	if(mHandler != null)
      	{
      		Message meg= new Message();
      		Bundle bundel= new Bundle();
      		bundel.putString("MESSAGE", text);
      		meg.setData(bundel);
      		mHandler.sendMessage(meg);
      	}
      }
	  public static void LogPass(boolean pass, String message) {
          if (pass) {
          	PrintLog("PASS -" + message);
              Log.e("Test", "PASS -" + message);
          } else {
          	PrintLog("-FAILE -" + message);
              Log.e("Test", "-FAILE -" + message);
          }
      }
	
}
