import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const RNFileSystem = ReactNative.NativeModules.RNFileSystem;

export default class FileSystem {

  static storage = {
    backedUp: 'BACKED_UP',
    important: 'IMPORTANT',
    auxiliary: 'AUXILIARY',
    temporary: 'TEMPORARY',
  };

  static async writeToFile(path, contents, storage = FileSystem.storage.backedUp) {
    return await RNFileSystem.writeToFile(path, contents, storage);
  }

  static async readFile(path, storage = FileSystem.storage.backedUp) {
    return await RNFileSystem.readFile(path, storage);
  }

  static async delete(path, storage = FileSystem.storage.backedUp) {
    return await RNFileSystem.delete(path, storage);
  }

  static async fileExists(path, storage = FileSystem.storage.backedUp) {
    return await RNFileSystem.fileExists(path, storage);
  }

  static async directoryExists(path, storage = FileSystem.storage.backedUp) {
    return await RNFileSystem.directoryExists(path, storage);
  }

  static absolutePath(path, storage = FileSystem.storage.backedUp) {
    return RNFileSystem[storage] + '/' + path;
  }
}
