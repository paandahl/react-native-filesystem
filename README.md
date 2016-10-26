# react-native-simple-fs
Simple file system API for iOS &amp; Android, for dealing with text-files.

This is still under development, but a release will come soon.

## Setup

    npm install react-native-simple-fs --save
    react-native link realm

## Write files

```javascript
import FileSystem from 'react-native-simple-fs';

async function writeFile() {
  const fileContents = 'This is a file.';
  await FileSystem.writeToFile('my-folder/my-file.txt', fileContents);
  console.log('wrote file');
}   
```

All interaction is promise-based, and compatible with async/await-syntax. Subfolders are created automatically.
   
## Read from files

```javascript
async function readFile() {
  const fileContents = await FileSystem.readFile('my-folder/my-file.txt');
  console.log(`read file: ${fileContents}`);
}   
```
    
## Delete files

```javascript
async function deleteFile() {
  await FileSystem.deleteFile('my-folder/my-file.txt');
  console.log('deleted file');
}
```
    
## Check if files exist

```javascript
async function checkIfFileExists() {
  const fileExists = await FileSystem.fileExists('my-folder/my-file.txt');
  console.log(`file exists: ${fileExists}`);
}
```
    
## Select storage class

All commands also takes an optional last argument specifying storage. These locations roughly corresponds to the four points of the [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html), and have similar behaviour on Android. 

```javascript
FileSystem.writeFile('my-file.txt', 'My content', storage.important);
```
   
Files need to be read from the same storage they're saved to, and two files can have the same name if they're located in different storages. The options are:

### storage.backedUp

The default. Files stored in this location will automatically be backed up by iCloud on iOS and [Auto Backup for Apps](https://developer.android.com/guide/topics/data/autobackup.html) on Android. This is generally for user-generated content that cannot be re-generated / re-downloaded.

### storage.important

This is for files that are possible to re-generate / re-download, but are still important to keep around. F.ex. offline maps.

### storage.auxiliary

This storage class is for files that can be re-created, and are not crucial to the proper functioning of your app.

### sotrage.temporary

Location for temporary caches and data. You should still clean up / delete the files when they are no longer in use.
