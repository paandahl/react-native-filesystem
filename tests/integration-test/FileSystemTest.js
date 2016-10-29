import React from 'react';
import ReactNative from 'react-native';
import LoggingTestModule from './LoggingTestModule';
import FileSystem from '../modules_copy/FileSystem'

const View = ReactNative.View;
const Text = ReactNative.Text;
const TestModule = ReactNative.NativeModules.TestModule;
const invariant = require('fbjs/lib/invariant');

async function testWriteAndReadAndDelete() {
  const filename = 'my-file.txt';
  let fileExists = await FileSystem.fileExists(filename);
  LoggingTestModule.assertFalse(fileExists, 'File should not exist at this point.');

  const myContent = 'This is my content.';
  await FileSystem.writeToFile(filename, myContent);
  fileExists = await FileSystem.fileExists(filename);
  LoggingTestModule.assertTrue(fileExists, 'File should exist at this point.');
  fileExists = await FileSystem.fileExists(filename, FileSystem.storage.important);
  LoggingTestModule.assertFalse(fileExists, 'File should only exist in backedUp storage.');

  const readBackContent = await FileSystem.readFile(filename);
  LoggingTestModule.assertEqual(readBackContent, myContent);

  await FileSystem.delete(filename);
  fileExists = await FileSystem.fileExists(filename);
  LoggingTestModule.assertFalse(fileExists, 'File should be deleted at this point.');
}

async function testFileAndFolderExistence() {
  const directoryName = 'my-folder';
  const fileName = 'my-file.txt';
  const filePath = `${directoryName}/${fileName}`;

  let directoryExists =
    await FileSystem.directoryExists(directoryName, FileSystem.storage.auxiliary);
  let fileExists = await FileSystem.fileExists(filePath, FileSystem.storage.auxiliary);
  LoggingTestModule.assertFalse(directoryExists, 'Directory should not exist at this point.');
  LoggingTestModule.assertFalse(fileExists, 'File should not exist at this point.');

  await FileSystem.writeToFile(filePath, 'My content', FileSystem.storage.auxiliary);
  directoryExists = await FileSystem.directoryExists(directoryName, FileSystem.storage.auxiliary);
  fileExists = await FileSystem.fileExists(filePath, FileSystem.storage.auxiliary);
  LoggingTestModule.assertTrue(directoryExists, 'Directory should exist at this point.');
  LoggingTestModule.assertTrue(fileExists, 'File should exist at this point.');
  directoryExists = await FileSystem.directoryExists(filePath, FileSystem.storage.auxiliary);
  fileExists = await FileSystem.fileExists(directoryName, FileSystem.storage.auxiliary);
  LoggingTestModule.assertFalse(directoryExists, 'Files should not be recognized as directories.');
  LoggingTestModule.assertFalse(fileExists, 'Directories should not be recognized as files.');

  await FileSystem.delete(directoryName, FileSystem.storage.auxiliary);
  directoryExists = await FileSystem.directoryExists(directoryName, FileSystem.storage.auxiliary);
  fileExists = await FileSystem.fileExists(filePath, FileSystem.storage.auxiliary);
  LoggingTestModule.assertFalse(directoryExists, 'Directory should be deleted at this point.');
  LoggingTestModule.assertFalse(fileExists, 'File should be deleted at this point.');
}

class FileSystemTest extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      status: 'running',
    }
  }

  componentDidMount() {
    this.runTests();
  }

  async runTests() {
    try {
      await testWriteAndReadAndDelete();
      await testFileAndFolderExistence();
    } catch (error) {
      LoggingTestModule.logErrorToConsole(error);
      if (TestModule) {
        TestModule.markTestPassed(false);
      }
      this.setState({ status: 'failed' });
      return;
    }
    if (TestModule) {
      TestModule.markTestPassed(true);
    }
    this.setState({ status: 'successful' });
  }

  render() {
    return <View><Text>{this.state.status}</Text></View>;
  }
}

FileSystemTest.displayName = 'FileSystemTest';

module.exports = FileSystemTest;
