package com.benwixen.rnfilesystem;

import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class RNFileSystemUnitTests {

  @Test
  public void testWriteReadAndDelete() throws IOException {
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

  @Test
  public void testFileAndFolderExistence() throws IOException {
    RNFileSystem fileSystem = new RNFileSystem(new FakeApplicationContext());

    String folderName = "my-folder";
    String fileName = "my-file.txt";
    String filePath = folderName + "/" + fileName;

    boolean directoryExists =
        fileSystem.directoryExists(folderName, RNFileSystem.Storage.AUXILIARY);
    boolean fileExists = fileSystem.fileExists(filePath, RNFileSystem.Storage.AUXILIARY);
    assertFalse(directoryExists);
    assertFalse(fileExists);

    fileSystem.writeToFile(filePath, "My content.", RNFileSystem.Storage.AUXILIARY);
    directoryExists = fileSystem.directoryExists(folderName, RNFileSystem.Storage.AUXILIARY);
    fileExists = fileSystem.fileExists(filePath, RNFileSystem.Storage.AUXILIARY);
    assertTrue(directoryExists);
    assertTrue(fileExists);
    directoryExists = fileSystem.directoryExists(filePath, RNFileSystem.Storage.AUXILIARY);
    fileExists = fileSystem.fileExists(folderName, RNFileSystem.Storage.AUXILIARY);
    assertFalse(directoryExists);
    assertFalse(fileExists);

    fileSystem.deleteFileOrDirectory(folderName, RNFileSystem.Storage.AUXILIARY);
    directoryExists = fileSystem.directoryExists(folderName, RNFileSystem.Storage.AUXILIARY);
    fileExists = fileSystem.fileExists(filePath, RNFileSystem.Storage.AUXILIARY);
    assertFalse(directoryExists);
    assertFalse(fileExists);
  }

  @Test
  public void testAbsolutePathConstants() {
    RNFileSystem fileSystem = new RNFileSystem(new FakeApplicationContext());
    String backedUp =
        (String) fileSystem.getConstants().get(RNFileSystem.Storage.BACKED_UP.toString());
    assertFalse(backedUp.endsWith("/"));
  }
}