package com.tnkfactory.tnkadvertiser;

import com.tnkfactory.ad.TnkSession;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class MainActivity extends Activity {
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        TnkSession.enableLogging(true);
        
        // 어플리케이션 시작시 호출
        TnkSession.applicationStarted(this);
        
        // 버튼을 눌러 액션을 완료하면 호출
        final Button actionButton = (Button)findViewById(R.id.main_action);
        actionButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				TnkSession.actionCompleted(MainActivity.this);
			}
        });
        
    }
}