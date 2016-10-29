# react-native-filesystem
Simple file system API for iOS &amp; Android, for dealing with text-files.

All interaction is promise-based, and all content is 
written and read as UTF-8.

This library is still under development, and only works on iOS at the current moment.

## Setup

    npm install react-native-filesystem --save
    react-native link react-native-filesystem

## Usage
### Write to files

```javascript
import FileSystem from 'react-native-filesystem';

async function writeFile() {
  const fileContents = 'This is a my content.';
  await FileSystem.writeToFile('my-directory/my-file.txt', fileContents);
  console.log('file is written');
}
```

Sub-directories are created automatically.

### Read from files

```javascript
async function readFile() {
  const fileContents = await FileSystem.readFile('my-directory/my-file.txt');
  console.log(`read from file: ${fileContents}`);
}
```

### Delete files or folders

```javascript
async function deleteFile() {
  await FileSystem.delete('my-directory/my-file.txt');
  console.log('file is deleted');
}
```

### Check if files or directories exist

```javascript
async function checkIfFileExists() {
  const fileExists = await FileSystem.fileExists('my-directory/my-file.txt');
  const directoryExists = await FileSystem.directoryExists('my-directory/my-file.txt');
  console.log(`file exists: ${fileExists}`);
  console.log(`directory exists: ${directoryExists}`);
}
```

### Selecting storage class

All commands also take an optional last argument specifying a storage class. 
These classes roughly correspond to the four points of the 
[iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html), 
and have similar behaviour on Android. Example usage:

```javascript
FileSystem.writeToFile('my-file.txt', 'My content', FileSystem.storage.important);
```

Files need to be read from the same storage class they're saved to, and two files can have the same 
name if they're located in different storages. The options are:

#### storage.backedUp

The default. Files stored in this location will automatically be backed up by iCloud on iOS and 
[Auto Backup for Apps](https://developer.android.com/guide/topics/data/autobackup.html) on Android
devices running Marshmallow or newer (6.0+). This is where you'd want to put user generated content.

Corresponds to `<Application_Home>/Documents` on iOS and 
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
on Android.

#### storage.important

This is for files that are possible to re-generate / re-download, but are still important to keep 
around during low storage situations. F.ex. offline maps. The system will almost always keep these 
files around.

Corresponds to `<Application_Home>/Library/Caches` with "do not backup" flag on iOS, and a 
subdirectory of
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
on Android.

#### storage.auxiliary

This storage class is for files that can be re-created, and that the app can live without. On 
Android this storage behaves the same as `storage.important`, but on iOS the system can delete
these files in low storage situations. To play it safe, you should gracefully handle the case where 
they are gone, by checking their existence.

Corresponds to `<Application_Home>/Library/Caches` on iOS, and a subdirectory of
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
explicitly excluded from backup on Android.


#### storage.temporary

Location for temporary caches and data. The system can get rid of these at any time, but you are 
still required to delete them manually to free up space when they are no longer in use.

Corresponds to `<Application_Home>/tmp` on iOS and 
[Context.getCacheDir()](https://developer.android.com/reference/android/content/Context.html#getCacheDir()) 
on Android.

## Questions?

*Why yet another file system library?*

I simply couldn't find one that satisfied my basic needs for simplicity.

*Why not use the built-in AsyncStorage?*

[AsyncStorage](https://facebook.github.io/react-native/docs/asyncstorage.html) is fine, but some 
times you want more control as to where the content is stored. This library lets you put it 
in backed-up folders, or play nice by marking content that can be deleted when the 
 phone runs low on space.
