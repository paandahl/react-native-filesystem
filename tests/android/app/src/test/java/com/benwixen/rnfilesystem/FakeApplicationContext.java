package com.benwixen.rnfilesystem;

import com.facebook.react.bridge.ReactApplicationContext;

import java.io.File;

public class FakeApplicationContext extends ReactApplicationContext {

  public FakeApplicationContext() {
    super(new FakeAndroidContext());
  }

  @Override
  public File getFilesDir() {
    File cacheDir = new File("test-fs/files/");
    if (!cacheDir.exists()) {
      cacheDir.mkdirs();
    }
    return cacheDir;
  }

  @Override
  public File getCacheDir() {
    File cacheDir = new File("test-fs/cache/");
    if (!cacheDir.exists()) {
      cacheDir.mkdir();
    }
    return cacheDir;
  }
}

