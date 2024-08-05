package com.alivc.auicommon.common.base.util;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.IDestroyable;
import com.alivc.auicommon.common.base.log.Logger;

/**
 * Created by KyleCe on 2022/1/18
 */
public class PermissionStrategy implements IDestroyable {
    public static final String TAG = "PermissionStrategy";
    private static final int REQUEST_PERMISSION_OK = 1;
    protected PermissionHelper permissionHelper;
    @Nullable
    private Runnable permissionGrantedOneTimeAction;
    @Nullable
    private Runnable permissionRejectedOneTimeAction;
    @Nullable
    private Runnable permissionGuidanceAction;
    private boolean permissionRequestResultNeedsConcern;
    private boolean ignoreStrictCheck; // 是否忽略严格校验

    public PermissionStrategy(Activity activity, String[] permissions
            , @Nullable Runnable permissionGrantedAction, @Nullable Runnable permissionRejectedAction, @Nullable Runnable permissionGuidanceAction) {
        this(activity, permissions, false, permissionGrantedAction, permissionRejectedAction, permissionGuidanceAction);
    }

    public PermissionStrategy(Activity activity, String[] permissions, boolean ignoreStrictCheck
            , @Nullable Runnable permissionGrantedAction, @Nullable Runnable permissionRejectedAction, @Nullable Runnable permissionGuidanceAction) {
        this.permissionHelper = new PermissionHelper(activity, REQUEST_PERMISSION_OK, permissions);
        this.ignoreStrictCheck = ignoreStrictCheck;
        this.permissionGrantedOneTimeAction = permissionGrantedAction;
        this.permissionRejectedOneTimeAction = permissionRejectedAction;
        this.permissionGuidanceAction = permissionGuidanceAction;
    }

    public void onResume(@NonNull Object ref) {
        boolean hasRequestedAfterInstalled = SPUtil.Permission.hasRequestedAlreadyAfterInstalled(ref.getClass().getSimpleName());
        boolean hasGranted = permissionHelper.hasPermission();
        if (hasGranted) {
            executePermissionGrantedOneTimeAction();
        } else {
            if (!hasRequestedAfterInstalled) {
                permissionRequestResultNeedsConcern = permissionHelper.requestPermissionIfVital();
                if (permissionRequestResultNeedsConcern) {
                    SPUtil.Permission.markRequestedAlreadyAfterInstalled(ref.getClass().getSimpleName());
                }
            } else {
                if (ignoreStrictCheck) {
                    Logger.e(TAG, "onResume: end--invalid param: ignoreStrictCheck");
                    executePermissionGrantedOneTimeAction();
                } else {
                    Utils.run(permissionGuidanceAction);
                }
            }
        }
    }

    private void executePermissionGrantedOneTimeAction() {
        Logger.i(TAG, "executePermissionGrantedOneTimeAction: ");
        Utils.run(permissionGrantedOneTimeAction);
        permissionGrantedOneTimeAction = null;
    }

    public void handleRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                               @NonNull int[] grantResults) {
        permissionHelper.handleRequestPermissionsResult(requestCode, permissions, grantResults);
        permissionRequestResultNeedsConcern = false;
    }

    @Override
    public void destroy() {
        permissionGrantedOneTimeAction = null;
        permissionGuidanceAction = null;
        Utils.destroy(permissionHelper);
    }
}
