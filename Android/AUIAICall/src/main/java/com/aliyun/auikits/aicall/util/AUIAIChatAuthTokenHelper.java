package com.aliyun.auikits.aicall.util;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class AUIAIChatAuthTokenHelper {

    private static String appID = "";
    private static String appKey = "";
    private static String appSign = "";
    private static long tokenDuration = 24 * 60 * 60;

    public static ARTCAIChatEngine.ARTCAIChatAuthToken generateAuthToken(String userId) {
        String role = "";
        String nonce = "AK_4";
        long timestamp = System.currentTimeMillis() / 1000 + tokenDuration;
        String pendingShaStr = appID + appKey + userId + nonce + timestamp + role;
        String appToken = AUIAIChatAuthTokenHelper.shaEncrypt(pendingShaStr);
        return new ARTCAIChatEngine.ARTCAIChatAuthToken(appID, appSign, appToken, timestamp, role, nonce);
    }

    private static String shaEncrypt(String strSrc) {
        MessageDigest md = null;
        String strDes = null;
        byte[] bt = strSrc.getBytes();
        try {
            md = MessageDigest.getInstance("SHA-256");// 将此换成SHA-1、SHA-512、SHA-384等参数
            md.update(bt);
            strDes = bytes2Hex(md.digest()); // to HexString
        } catch (NoSuchAlgorithmException e) {
            return null;
        }
        return strDes;
    }

    private static String bytes2Hex(byte[] bts) {
        String des = "";
        String tmp = null;
        for (int i = 0; i < bts.length; i++) {
            tmp = (Integer.toHexString(bts[i] & 0xFF));
            if (tmp.length() == 1) {
                des += "0";
            }
            des += tmp;
        }
        return des;
    }


}
