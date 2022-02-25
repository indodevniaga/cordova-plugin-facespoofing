package cordova.plugin.facespoofing;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class FaceSpoofing extends CordovaPlugin {

  private CallbackContext callbackContext;
  private static final int REQUEST_CODE = 3;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    this.callbackContext = callbackContext;
    if (action.equals("detect")) {
      String message = args.getString(0);
      this.detectMethod(message, callbackContext);
      return true;
    }
    return false;
  }

  private void detectMethod(String message, CallbackContext callbackContext) {
    if (message != null && message.length() > 0) {
      cordova.setActivityResultCallback(this);
      keepCallback(callbackContext);
      openNewActivityDetect(cordova.getActivity(), REQUEST_CODE, message);
    } else {
      callbackContext.error("Expected one non-empty string argument.");
    }
  }

  private void openNewActivityDetect(Context context, int REQUEST_CODE, String message) {
    Intent intent = new Intent(context, FaceRecognitionProcess.class);
    intent.putExtra("image", message);
    cordova.startActivityForResult(this, intent, REQUEST_CODE);
  }

  private void keepCallback(CallbackContext callbackContext) {
    PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
    r.setKeepCallback(true);
    callbackContext.sendPluginResult(r);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (data == null) return;
    CallbackContext callback = this.callbackContext;
    if (requestCode == REQUEST_CODE) {
      if (resultCode == Activity.RESULT_OK && data.hasExtra("data")) {
        try {
          JSONObject resData = new JSONObject(data.getStringExtra("data"));
          boolean error = resData.getBoolean("error");
          resData.put("status", error ? "FAIL" : "SUCCESS");
          PluginResult result = new PluginResult(PluginResult.Status.OK, resData);
          result.setKeepCallback(true);
          callback.sendPluginResult(result);
        } catch (JSONException e) {
          e.printStackTrace();
          PluginResult result = new PluginResult(PluginResult.Status.ERROR);
          result.setKeepCallback(true);
          callback.sendPluginResult(result);
        }
      } else {
        PluginResult result = new PluginResult(PluginResult.Status.ERROR, "Unable to identify user");
        result.setKeepCallback(true);
        callback.sendPluginResult(result);
      }
    }
  }

}
