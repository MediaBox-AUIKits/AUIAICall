package com.aliyun.auikits.aicall.controller;

import android.content.Context;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.ARTCAICallEngineImpl;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * ARTCAICallEngineImpl的线程安全单例类
 * 确保整个应用中只能创建一个ARTCAICallEngineImpl实例
 */
public class ARTCAICallEngineSingleton {
    // 使用volatile确保多线程环境下的可见性
    private static volatile ARTCAICallEngineSingleton instance;
    
    // 使用锁来保证线程安全
    private static final Lock lock = new ReentrantLock();
    
    // ARTCAICallEngineImpl实例
    private ARTCAICallEngineImpl engineInstance;
    
    // 私有构造函数，防止外部直接实例化
    private ARTCAICallEngineSingleton() {
    }
    
    /**
     * 获取单例实例（双检锁实现单例模式）
     * 
     * @return ARTCAICallEngineSingleton实例
     */
    public static ARTCAICallEngineSingleton getInstance() {
        // 第一次检查，避免不必要的同步
        if (instance == null) {
            synchronized (ARTCAICallEngineSingleton.class) {
                // 第二次检查，确保只创建一个实例
                if (instance == null) {
                    instance = new ARTCAICallEngineSingleton();
                }
            }
        }
        return instance;
    }
    
    /**
     * 初始化并获取ARTCAICallEngineImpl实例
     * 
     * @param context 上下文
     * @param userId 用户ID
     * @return ARTCAICallEngineImpl实例
     */
    public ARTCAICallEngine getEngineInstance(Context context, String userId) {
        // 双检锁确保engineInstance只被初始化一次
        if (engineInstance == null) {
            lock.lock();
            try {
                if (engineInstance == null) {
                    engineInstance = new ARTCAICallEngineImpl(context, userId);
                }
            } finally {
                lock.unlock();
            }
        }
        return engineInstance;
    }
    
    /**
     * 释放ARTCAICallEngineImpl实例
     */
    public void releaseEngineInstance() {
        lock.lock();
        try {
            if (engineInstance != null) {
                // 销毁引擎实例
                engineInstance.destroy();
                engineInstance = null;
            }
        } finally {
            lock.unlock();
        }
    }
}