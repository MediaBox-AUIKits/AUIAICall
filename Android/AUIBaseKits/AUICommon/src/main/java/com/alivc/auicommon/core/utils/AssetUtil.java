package com.alivc.auicommon.core.utils;

import android.content.Context;
import android.content.res.AssetManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by baorunchen on 2021/4/29.
 * <p>
 * Android asset file util
 */
public class AssetUtil {
    /**
     * Copy asset file or folder to sdcard
     *
     * @param context      android context
     * @param srcFilePath  src asset path, file or folder
     * @param destFilePath dest sdcard path
     * @return true->success, false->failed.
     * <p>
     * Such as:
     * srcFilePath: ai.bundle/face.model
     * destFilePath: /data/xxx/yyy/zzz/ai.bundle/face.model
     * result: /data/xxx/yyy/zzz/ai.bundle/face.model
     */
    public static boolean copyAssetToSdCard(@Nullable Context context, @Nullable String srcFilePath, @Nullable String destFilePath) {
        if (context == null || srcFilePath == null || destFilePath == null || srcFilePath.isEmpty() || destFilePath.isEmpty()) {
            return false;
        }

        ArrayList<String> assetFileList = getAssetFilePathList(context, srcFilePath);
        boolean isFolder = !assetFileList.isEmpty();

        // Check whether target file exists
        File targetFile = new File(destFilePath);

        // If file already exists, return.
        // Only when target is a file and exists can return.
        if (targetFile.exists() && targetFile.isFile()) {
            return true;
        }

        if (!isFolder) {
            return copyAssetFileToSdCard(context, srcFilePath, destFilePath);
        } else {
            // If file exists but not expected file type, remove it.
            if (targetFile.isFile()) {
                targetFile.delete();
            }
            targetFile.mkdirs();

            boolean result = true;
            for (String file : assetFileList) {
                String src = srcFilePath + File.separator + file;
                String dest = destFilePath + File.separator + file;
                result = result && copyAssetToSdCard(context, src, dest);
            }
            return result;
        }
    }

    /**
     * Copy single asset file to sdcard
     *
     * @param context      android context
     * @param srcFilePath  src asset file path
     * @param destFilePath dest sdcard file path
     * @return true->success, false->failed.
     */
    public static boolean copyAssetFileToSdCard(@Nullable Context context, @Nullable String srcFilePath, @Nullable String destFilePath) {
        if (context == null || srcFilePath == null || destFilePath == null || srcFilePath.isEmpty() || destFilePath.isEmpty()) {
            return false;
        }

        File targetFile = new File(destFilePath);
        if (targetFile.exists()) return true;

        AssetManager am = context.getAssets();
        if (am == null) return false;

        InputStream inputStream = null;
        FileOutputStream outputStream = null;

        try {
            inputStream = am.open(srcFilePath);
            outputStream = new FileOutputStream(destFilePath);

            byte[] buffer = new byte[1024];
            int length = inputStream.read(buffer);
            while (length > 0) {
                outputStream.write(buffer, 0, length);
                length = inputStream.read(buffer);
            }

            outputStream.flush();
            inputStream.close();
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
            targetFile.delete();
            return false;
        } finally {
            try {
                if (inputStream != null) {
                    inputStream.close();
                }
                if (outputStream != null) {
                    outputStream.close();
                    outputStream.getChannel().close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return true;
    }

    /**
     * Get asset file by assets folder name
     *
     * @param context     android context
     * @param assetFolder assets folder name
     * @return asset file list with full path
     */
    @NonNull
    public static ArrayList<String> getAssetFilePathList(@Nullable Context context, @Nullable String assetFolder) {
        ArrayList<String> fileList = new ArrayList<>();

        if (context == null) return fileList;

        AssetManager am = context.getAssets();
        if (am == null) return fileList;

        try {
            String[] assetList = am.list(assetFolder);
            fileList.addAll(Arrays.asList(assetList));
        } catch (Exception e) {
            e.printStackTrace();
        }

        return fileList;
    }
}
