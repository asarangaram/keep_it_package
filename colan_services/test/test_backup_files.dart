import 'dart:io';

import 'package:colan_services/services/backup_service/backup_files.dart';

const outputName = 'self.tar.gz';

Future<void> main() async {
  print('Enter the path of the folder to compress:');
  final inputPath = stdin.readLineSync()?.trim();

  if (inputPath == null || inputPath.isEmpty) {
    print('Invalid folder path.');
    return;
  }

  final directory = Directory(inputPath);
  if (!directory.existsSync()) {
    print('The folder does not exist.');
    return;
  }
  const previousLength = 0;

  final backup = await BackupManager(
    directories: [directory],
    baseDir: directory.parent,
    backupFolder: Directory.current,
  ).backup(
    onProgress: (message) {
      updateStatus(message, previousLength);
    },
  );

  updateStatus('backup: $backup', previousLength);
}

int updateStatus(String statusMessage, int previousLength) {
  final clearLine = '\r${' ' * previousLength}\r';
  stdout.write(clearLine);
  final output = statusMessage;
  stdout.write(output);
  return output.length;
}
