package com.aliyun.auikits.aicall.util;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class AUIAIAssetFilePathHelper {
    private Context mContext;

    public AUIAIAssetFilePathHelper(Context context) {
        this.mContext = context;
    }

    private AssetManager getAssets() {
        return mContext.getAssets();
    }

    private File getFilesDir() {
        return mContext.getFilesDir();
    }

    public String getAssetFileFullPath(String assetFileName) {
        try {
            // 定义目标文件名
            String outputFileName = assetFileName;
            File outputFile = new File(getFilesDir(), outputFileName);

            Log.i("ExternalAudioCapture", "Target file path: " + outputFile.getAbsolutePath());

            // 如果文件已存在，检查文件大小
            if (outputFile.exists()) {
                long fileSize = outputFile.length();
                Log.i("ExternalAudioCapture", "File already exists, size: " + fileSize + " bytes");
                if (fileSize == 0) {
                    Log.w("ExternalAudioCapture", "Existing file is empty, will re-copy");
                    // 删除空文件重新复制
                    outputFile.delete();
                } else {
                    return outputFile.getAbsolutePath();
                }
            }

            // 将文件从 assets 复制到内部存储
            try (InputStream in = getAssets().open(assetFileName);
                 FileOutputStream out = new FileOutputStream(outputFile)) {

                Log.i("ExternalAudioCapture", "Copying asset file: " + assetFileName);

                byte[] buffer = new byte[1024];
                int totalBytes = 0;
                int read;
                while ((read = in.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                    totalBytes += read;
                }

                Log.i("ExternalAudioCapture", "File copied successfully, total bytes: " + totalBytes);
                // 返回文件的完整路径
                return outputFile.getAbsolutePath();
            }
        } catch (Exception e) {
            Log.e("ExternalAudioCapture", "Error getting asset file: " + assetFileName, e);
            return null;
        }
    }
}