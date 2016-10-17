package io.fiverocks.android.sample;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import io.fiverocks.android.ActionRequest;
import io.fiverocks.android.ActionRequestListener;
import io.fiverocks.android.FiveRocks;
import io.fiverocks.android.FiveRocksListener;

public class SampleActivity extends Activity {

  private ActionRequestListener actionRequestListener;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.sample);
    setupContentView();

    // First of all, initialize SDK with your app id and key that are provided on the 5Rocks dashboard.
    FiveRocks.init(this, "Your_App_Id", "Your_App_Key");

    FiveRocksListener fiverocksListener = new FiveRocksListener() {
      @Override
      public void onPlacementContentNone(String placement) {
        showMessage("No Content received for \"%s\" placement", placement);
      }

      @Override
      public void onPlacementContentReady(String placement) {
        showMessage("Content ready for \"%s\" placement", placement);
      }

      @Override
      public void onPlacementContentShow(String placement) {
        showMessage("Content is showing for \"%s\" placement", placement);
      }

      @Override
      public void onPlacementContentClose(String placement) {
        showMessage("Content has been closed by user for \"%s\" placement", placement);
      }

      @Override
      public void onPlacementContentClick(String placement, ActionRequest actionRequest) {
        showMessage("Content has been clicked by user for \"%s\" placement", placement);
        if (actionRequest != null) {
          actionRequest.dispatchTo(actionRequestListener);
        }
      }

      @Override
      public void onPlacementContentDismiss(String placement, ActionRequest actionRequest) {
        showMessage("Content has been dismissed for \"%s\" placement", placement);
        if (actionRequest != null) {
          actionRequest.dispatchTo(actionRequestListener);
        }
      }
    };
    FiveRocks.setListener(fiverocksListener);

    actionRequestListener = new ActionRequestListener() {
      @Override
      public void onPurchaseRequest(String campaignId, String productId) {
        showMessage("PurchaseRequest(campaignId=\"%s\", productId=\"%s\") received", campaignId,
            productId);
      }

      @Override
      public void onRewardRequest(String id, String name, int quantity, String token) {
        showMessage("RewardRequest(id=\"%s\", name=\"%s\", quantity=%d, token=\"%s\") received",
            id, name, quantity, token);
      }
    };
  }

  @Override
  protected void onStart() {
    super.onStart();
    FiveRocks.onActivityStart(this);
  }

  @Override
  protected void onStop() {
    FiveRocks.onActivityStop(this);
    super.onStop();
  }

  public void onClickToRequestPlacementContent(View v) {
    FiveRocks.requestPlacementContent(getPlacement(v));
  }

  public void onClickToShowPlacementContent(View v) {
    FiveRocks.showPlacementContent(getPlacement(v));
  }

  private static String getPlacement(View v) {
    return ((TextView) ((ViewGroup) v.getParent()).getChildAt(0)).getText().toString();
  }

  public void onClickToTrackEvent(View v) {
    FiveRocks.trackEvent("some event");
  }

  private void showMessage(String format, Object... args) {
    showMessage(String.format(format, args));
  }

  private void showMessage(String msg) {
    Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
  }

  private void setupContentView() {
    Spinner orientationSpinner = (Spinner) findViewById(R.id.orientation);
    ArrayList<String> orientations = new ArrayList<String>();
    orientations.add("Sensor");
    orientations.add("Portrait");
    orientations.add("Landscape");
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
      orientations.add("Reverse Portrait");
      orientations.add("Reverse Landscape");
    }
    ArrayAdapter<String> adapter =
        new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, orientations);
    adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
    orientationSpinner.setAdapter(adapter);
    orientationSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
      @SuppressLint("InlinedApi")
      @Override
      public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        switch (position) {
        case 0:
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR);
          } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);
          }
          break;
        case 1:
          setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
          break;
        case 2:
          setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
          break;
        case 3:
          setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT);
          break;
        case 4:
          setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
          break;
        }
      }

      @Override
      public void onNothingSelected(AdapterView<?> parent) {
      }
    });
  }
}
