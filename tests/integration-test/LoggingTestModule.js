/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 * @providesModule LoggingTestModule
 */
'use strict';

var BatchedBridge = require('BatchedBridge');

var warning = require('fbjs/lib/warning');
var invariant = require('fbjs/lib/invariant');

export default class LoggingTestModule {
  static logToConsole(str) {
    console.log(str);
  }
  static warning(str) {
    warning(false, str);
  }
  static assertTrue(condition, str) {
    if (!condition) {
      this.logErrorToConsole(str);
    }
  }

  static assertFalse(condition, str) {
    if (condition) {
      this.logErrorToConsole(str);
    }
  }

  static assertEqual(obj1, obj2) {
    if (obj1 !== obj2) {
      this.logErrorToConsole(`Objects not equal: '${obj1}' and '${obj2}'`);
    }
  }

  static assertIncludes(obj, subelemnt) {
    if (subelemnt instanceof Array) {
      for (const subel of subelemnt) {
        if (obj.includes(subel)) {
          return;
        }
      }
      this.logErrorToConsole(`Object '${obj}' does not include any of ${subelemnt}`);
    } else {
      if (!obj.includes(subelemnt)) {
        this.logErrorToConsole(`Object '${obj}' does not include '${subelemnt}'`);
      }
    }
  }

  static logErrorToConsole(str) {
    console.error(str);
  }
  static throwError(str) {
    throw new Error(str);
  }
};

BatchedBridge.registerCallableModule(
  'LoggingTestModule',
  LoggingTestModule
);
