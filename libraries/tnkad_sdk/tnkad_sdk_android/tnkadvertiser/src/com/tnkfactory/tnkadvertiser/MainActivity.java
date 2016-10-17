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
        
        // ���ø����̼� ���۽� ȣ��
        TnkSession.applicationStarted(this);
        
        // ��ư�� ���� �׼��� �Ϸ��ϸ� ȣ��
        final Button actionButton = (Button)findViewById(R.id.main_action);
        actionButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				TnkSession.actionCompleted(MainActivity.this);
			}
        });
        
    }
}