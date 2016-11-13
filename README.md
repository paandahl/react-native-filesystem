# react-native-filesystem [![npm version](https://img.shields.io/npm/v/react-native-filesystem.svg?style=flat)](https://www.npmjs.com/package/react-native-filesystem)
Simple file system access on iOS &amp; Android.

All interaction is promise-based, and all content is 
written and read as UTF-8.

## Setup

    npm install react-native-filesystem --save
    react-native link react-native-filesystem
    
This project is based on the [9-project-layout](https://github.com/benwixen/9-project-layout).

## Usage

For a full list of available methods, see the [API Reference](docs/reference.md).

### Write to files

```javascript
import FileSystem from 'react-native-filesystem';

async function writeToFile() {
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

### Selecting a storage class

All commands also take an optional last argument specifying a storage class. 
These classes roughly correspond to the four points of the 
[iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html), 
and have similar behaviour on Android. Example usage:

```javascript
FileSystem.writeToFile('my-file.txt', 'My content', FileSystem.storage.important);
```

Files need to be read from the same storage class they're saved to, and two files can have the same 
name if they're located in different storages. The options are:

| Storage class | Description |
|---------------|-------------|
| `storage.backedUp` | These files are automatically backed up on supported devices
| `storage.important` | Excluded from backup, but still kept around in low-storage situations
| `storage.auxiliary` | Files that the app can function without. Can be deleted by the system in low-storage situations.
| `storage.temporary` | For temporary files and caches. Can be deleted by the system any time.

For full details, see the [API Reference](docs/reference.md).

## Questions?

*Why yet another file system library?*

I simply couldn't find one that satisfied my basic needs for simplicity.

*Why not use the built-in AsyncStorage?*

[AsyncStorage](https://facebook.github.io/react-native/docs/asyncstorage.html) is fine, but some 
times you want more control as to where the content is stored. This library lets you put it 
in backed-up folders, or play nice by marking content that can be deleted when the 
 phone runs low on space.
