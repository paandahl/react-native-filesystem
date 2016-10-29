package com.benwixen.rnfilesystem;

import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class RNFileSystemUnitTests {

  @Test
  public void testy() throws IOException {
    RNFileSystem fileSystem = new RNFileSystem(new FakeApplicationContext());

    String fileName = "my-file.txt";
    boolean fileExists = fileSystem.fileExists(fileName, RNFileSystem.Storage.BACKED_UP);
    assertFalse(fileExists);

    String myContent = "This is my content.";
    fileSystem.writeToFile(fileName, myContent, RNFileSystem.Storage.BACKED_UP);
    fileExists = fileSystem.fileExists(fileName, RNFileSystem.Storage.BACKED_UP);
    assertTrue(fileExists);
    boolean fileExistsInDifferentStorage =
        fileSystem.fileExists(fileName, RNFileSystem.Storage.AUXILIARY);
    assertFalse(fileExistsInDifferentStorage);

    String readBackContent = fileSystem.readFile(fileName, RNFileSystem.Storage.BACKED_UP);
    assertEquals(myContent, readBackContent);

    fileSystem.deleteFileOrDirectory(fileName, RNFileSystem.Storage.BACKED_UP);
    fileExists = fileSystem.fileExists(fileName, RNFileSystem.Storage.BACKED_UP);
    assertFalse(fileExists);
  }
}