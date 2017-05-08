using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ReactNative.Bridge;
using Windows.Storage;
using System.Text.RegularExpressions;

namespace RNFileSystem
{
    public class RNFileSystemModule : ReactContextNativeModuleBase
    {
        public enum Storage
        {
            BACKED_UP,
            IMPORTANT,
            AUXILIARY,
            TEMPORARY
        }

        public RNFileSystemModule(ReactContext reactContext)
            : base(reactContext)
        {
        }

        public override string Name
        {
            get
            {
                return "RNFileSystem";
            }
        }

        private string baseDirForStorage(Storage storage)
        {
            switch (storage)
            {
                case Storage.BACKED_UP:
                    return "RNFS-BackedUp";
                case Storage.IMPORTANT:
                    return "RNFS-Important";
                case Storage.AUXILIARY:
                    return "RNFS-Auxiliary";
                case Storage.TEMPORARY:
                    return "RNFS-Temporary";
                default:
                    throw new Exception("Unrecognized storage: " + storage.ToString());
            }
        }

        private async Task<StorageFolder> createDirectories(string folders)
        {
            string absolutePath = absulutePath(folders);
            System.IO.Directory.CreateDirectory(absolutePath);
            var folder = await StorageFolder.GetFolderFromPathAsync(absolutePath);
            return folder;
        }

        private async Task<bool> checkFileExist(StorageFolder folder, string path)
        {

            if (await folder.TryGetItemAsync(path) != null)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        private Dictionary<string, string> getPathAndFilename(string path)
        {
            Dictionary<string, string> result = new Dictionary<string, string>(2);
            int lastSlash = path.LastIndexOf("/");

            if (lastSlash != -1)
            {
                result["fileName"] = path.Substring(lastSlash + 1);
                result["folder"] = path.Substring(0, path.Length - result["fileName"].Length);
            }
            else
            {
                result["fileName"] = path;
                result["folder"] = "";
            }

            return result;
        }

        private async Task writeFile(string relativePath, string content, Storage storage)
        {
            string baseDir = baseDirForStorage(storage);

            try
            {
                var path = getPathAndFilename(relativePath);
                var folders = baseDir;
                StorageFile file = null;
                StorageFolder folder = null;
                if (path["folder"] != "")
                {
                    folders += "/" + path["folder"];
                    folder = await createDirectories(folders);
                } else
                {
                    folders += "/";
                    folder = await createDirectories(folders);
                }
                file = await folder.CreateFileAsync(path["fileName"], CreationCollisionOption.ReplaceExisting);
                await FileIO.WriteTextAsync(file, content);
            }
            catch (Exception e)
            {
                throw new Exception("write file error " + relativePath + ". Error: " + e.Message );
            }
        }

        private string absulutePath(string relativePath)
        {
            string rootFolder = ApplicationData.Current.LocalFolder.Path;
            return rootFolder + "\\" + Regex.Replace(relativePath, "/", "\\");
        }

        private async Task<string> readFile(string relativePath, Storage storage)
        {
            string baseDir = baseDirForStorage(storage);

            try
            {
                relativePath = baseDir + "/" + relativePath;
                var path = getPathAndFilename(relativePath);

                StorageFolder folder = await StorageFolder.GetFolderFromPathAsync(absulutePath(path["folder"]));
                if (await folder.TryGetItemAsync(path["fileName"]) != null)
                {
                    StorageFile file = await folder.GetFileAsync(path["fileName"]);
                    string content = await FileIO.ReadTextAsync(file);
                    return content;
                }
                else
                {
                    throw new Exception("write file not found " + baseDir + "/" + relativePath);
                }
            }
            catch (Exception e)
            {
                throw new Exception("write file error " + baseDir + "/" + relativePath);
            }
        }

        private async Task<bool> deleteFileOrDirectory(string relativePath, Storage storage)
        {
            string baseDir = baseDirForStorage(storage);
            try
            {
                relativePath = baseDir + "/" + relativePath;

                var fullPath = ApplicationData.Current.LocalFolder.Path;
                System.IO.FileAttributes attr = System.IO.File.GetAttributes(absulutePath(relativePath));

                if ((attr & System.IO.FileAttributes.Directory) == System.IO.FileAttributes.Directory)
                {
                    StorageFolder folder = await StorageFolder.GetFolderFromPathAsync(absulutePath(relativePath));
                    await folder.DeleteAsync();
                    return true;
                }
                else
                {
                    var path = getPathAndFilename(relativePath);
                    StorageFolder folder = await StorageFolder.GetFolderFromPathAsync(absulutePath(path["folder"]));
                    var file = await folder.GetFileAsync(path["fileName"]);
                    await file.DeleteAsync(StorageDeleteOption.PermanentDelete);
                    return true;
                }
            }
            catch (Exception e)
            {
                throw new Exception("delete file error " + e.Message);
            }
        }

        [ReactMethod]
        public async void writeToFile(string relativePath, string content, string storage, IPromise promise)
        {
            if (relativePath == null)
            {
                promise.Reject(new ArgumentNullException(nameof(relativePath)));
                return;
            }

            try
            {
                await writeFile(relativePath, content, (Storage)Enum.Parse(typeof(Storage), storage));
                promise.Resolve(true);
            }
            catch (Exception ex)
            {
                promise.Reject("Write file error ' " + relativePath + "'. Message: " + ex.Message);
            }
        }

        [ReactMethod]
        public async void readToFile(string relativePath, string storage, IPromise promise)
        {
            if (relativePath == null)
            {
                promise.Reject(new ArgumentNullException(nameof(relativePath)));
                return;
            }

            try
            {
                string content = await readFile(relativePath, (Storage)Enum.Parse(typeof(Storage), storage));
                promise.Resolve(content);
            }
            catch (Exception ex)
            {
                promise.Reject(ex.Message);
            }
        }

        [ReactMethod]
        public async void fileExists(string relativePath, string storage, IPromise promise)
        {
            try
            {
                string baseDir = baseDirForStorage((Storage)Enum.Parse(typeof(Storage), storage));
                relativePath = baseDir + "/" + relativePath;
                var path = getPathAndFilename(relativePath);

                StorageFolder folder = await StorageFolder.GetFolderFromPathAsync(absulutePath(path["folder"]));

                if (await folder.TryGetItemAsync(path["fileName"]) != null)
                {
                    promise.Resolve(true);
                }
                else
                {
                    promise.Resolve(false);
                }
            }
            catch (Exception e)
            {
                promise.Reject("check file exist error " + e.Message);
            }
        }

        [ReactMethod]
        public void directoryExists(string relativePath, string storage, IPromise promise)
        {
            try
            {
                string baseDir = baseDirForStorage((Storage)Enum.Parse(typeof(Storage), storage));
                relativePath = baseDir + "/" + relativePath;

                promise.Resolve(System.IO.Directory.Exists(absulutePath(relativePath)));
            }
            catch (Exception e)
            {
                promise.Reject("check file exist error " + e.Message);
            }
        }

        [ReactMethod]
        public async void delete(string relativePath, string storage, IPromise promise)
        {
            try
            {
                promise.Resolve(await deleteFileOrDirectory(relativePath, (Storage)Enum.Parse(typeof(Storage), storage)));
            }
            catch (Exception e)
            {
                promise.Reject("delete file error " + e.Message);
            }
        }
    }
}
