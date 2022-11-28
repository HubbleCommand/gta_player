import 'dart:io';
import 'package:flutter/cupertino.dart';

class FileUtils {
  //Should be 8 bit by default as converted all files to by playable from https://github.com/TMRh20/TMRpcm/wiki
  static num getFileDuration(String path, {int sampleRate = 32000, int channels = 1, num bitsPerSample = 8 / 8}) {
    https://social.msdn.microsoft.com/Forums/windows/en-US/5a92be69-3b4e-4d92-b1d2-141ef0a50c91/how-to-calculate-duration-of-wave-file-from-its-size?forum=winforms
    debugPrint("File length ${File(path).lengthSync() / (sampleRate * channels * bitsPerSample)}");
    return File(path).lengthSync() / (sampleRate * channels * bitsPerSample);
  }
}
