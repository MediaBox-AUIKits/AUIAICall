package com.alivc.auicommon.common.base.util;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;

import androidx.annotation.Nullable;
import androidx.annotation.WorkerThread;

import com.alivc.auicommon.common.base.log.Logger;

import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Created by KyleCe on 2021/8/26
 */
public class IOUtil {

    /**
     * @return null if fail, return name of copied temp file
     */
    @Nullable
    @WorkerThread
    public static String makeCopyOfFile(Context context, Uri uri) {
        if (context == null || uri == null) {
            return null;
        }
        try {
            File appCacheDir = context.getExternalCacheDir();
            File tmpCopy = new File(appCacheDir, getFileName(context, uri));
            long start = System.currentTimeMillis();
            copyToTempFile(context, uri, tmpCopy);
            Logger.e("PPPPP", "copy " + tmpCopy + " taking:" + (System.currentTimeMillis() - start));
            return tmpCopy.getPath();
        } catch (Exception ignore) {
        }
        return null;
    }

    public static String getFileName(Context context, Uri uri) {
        String result = null;
        if (uri.getScheme().equals("content")) {
            Cursor cursor = null;
            try {
                cursor = context.getContentResolver().query(uri, null, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    result = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } finally {
                close(cursor);
            }
        }
        if (result == null) {
            result = uri.getPath();
            int cut = result.lastIndexOf('/');
            if (cut != -1) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }

    private static File copyToTempFile(Context context, Uri uri, File tempFile) throws IOException {
        // Obtain an input stream from the uri
        InputStream inputStream = context.getContentResolver().openInputStream(uri);

        if (inputStream == null) {
            throw new IOException("Unable to obtain input stream from URI");
        }

        copy(inputStream, tempFile);

        return tempFile;
    }

    public static void copy(InputStream in, File dst) {
        OutputStream out = null;
        try {
            out = new FileOutputStream(dst);
            // Transfer bytes from in to out
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
        } catch (Exception ignore) {
        } finally {
            close(in, out);
        }
    }

    public static void close(Closeable... cls) {
        if (cls == null || cls.length == 0) {
            return;
        }

        for (Closeable c : cls) {
            if (c != null) {
                try {
                    c.close();
                } catch (IOException ignore) {
                }
            }
        }
    }
}
