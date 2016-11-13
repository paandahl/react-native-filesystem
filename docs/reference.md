# API Reference

There is only one module, FileSystem, that can be imported like this:

```javascript
import FileSystem from 'react-native-filesystem';
```

This module works on iOS 8.0+ and Android Ice Cream Sandwich and newer (4.1.x / API-level 16).

## FileSystem

static **writeToFile** (path: `string`, content: `string`, storage: `string?`): `Promise`

Asynchronously writes the content to a file, and resolves the promise upon completion.
Intermediary directories in the path are created automatically.

If no storage is specified, FileSystem.storage.backedUp is the default.

---
static **readFile** (path: `string`, storage: `string?`): `Promise`

Asynchronously reads the file, and resolves the promise with the `string` content.

If no storage is specified, FileSystem.storage.backedUp is the default.

---
static **deleteFile** (path: `string`, storage: `string?`): `Promise`

Asynchronously deletes the file, and resolves the promise upon completion.

If no storage is specified, FileSystem.storage.backedUp is the default.

---
static **fileExists** (path: `string`, storage: `string?`): `Promise`

Asynchronously checks if the file exists, and resolves the promise with a `bool`. Will return
`false` if a directory exists at the path.

If no storage is specified, FileSystem.storage.backedUp is the default.

---
static **directoryExists** (path: `string`, storage: `string?`): `Promise`

Asynchronously checks if the directory exists, and resolves the promise with a `bool`. Will return
`false` if a file exists at the path.

If no storage is specified, FileSystem.storage.backedUp is the default.

---
static **absolutePath** (path: `string`, storage: `string?`): `string`

Returns the absolute path given a relative path and a storage class. Useful if you need to interact
with native code that is unaware of the storage class system of this module.

If no storage is specified, FileSystem.storage.backedUp is the default.

## FileSystem.storage

There are four different storage classes available. 

#### storage.backedUp

The default. Files stored in this location will automatically be backed up by iCloud on all 
supported iOS versions (8.0+) and 
[Auto Backup for Apps](https://developer.android.com/guide/topics/data/autobackup.html) on Android
devices running Marshmallow or newer (6.0+). This is where you'd want to put user generated content.

Corresponds to a subdirectory of `<Application_Home>/Documents` on iOS and
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
on Android.

#### storage.important

For files that are possible to re-generate / re-download, but are still important to keep 
around during low storage situations. F.ex. offline maps. The system will almost always keep these 
files around.

Corresponds to a subdirectory of `<Application_Home>/Library/Caches` with "do not backup" flags on 
iOS, and a subdirectory of
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
excluded from backup on Android.

#### storage.auxiliary

On Android this storage behaves the same as `storage.important`.

This is for files that can be re-created, and that the app can live without. On iOS the system can 
delete these files in low storage situations. To play it safe, you should gracefully handle the 
case where they are gone, by checking for their existence on application startup.

Corresponds to a subdirectory of `<Application_Home>/Library/Caches` on iOS, and a subdirectory of
[Context.getFilesDir()](https://developer.android.com/reference/android/content/Context.html#getFilesDir()) 
excluded from backup on Android.

*Under which circumstances can these files be deleted?*

To quote Apple's 
[File System Programming Guide](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html):

> In iOS 5.0 and later, the system may delete the Caches directory on rare occasions when the system 
> is very low on disk space. This will never occur while an app is running. However, be aware that 
> restoring from backup is not necessarily the only condition under which the Caches directory can 
> be erased.


#### storage.temporary

For temporary caches and data. The system can get rid of these at any time, but you are 
still required to delete them manually to free up space when they are no longer in use.

Corresponds to a subdirectory of `<Application_Home>/tmp` on iOS and 
[Context.getCacheDir()](https://developer.android.com/reference/android/content/Context.html#getCacheDir()) 
on Android.
