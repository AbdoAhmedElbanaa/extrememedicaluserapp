import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('🚀 Flutter Feature Folder Generator\n');

  stdout.write('✨ Enter feature name: ');
  final featureName = stdin.readLineSync()?.trim();

  if (featureName == null || featureName.isEmpty) {
    print('❌ Feature name cannot be empty.');
    exit(1);
  }

  FolderGenerator.generate(featureName);
  print('\n🎉 Done! "$featureName" is ready.');
}

class FolderGenerator {
  static void generate(String featureName) {
    final baseDir = 'lib/features/$featureName';

    for (final folder in ['controllers', 'screens', 'widgets', 'models']) {
      final dir = Directory(path.join(baseDir, folder));
      dir.createSync(recursive: true);
      print('   ✔ Created: ${dir.path}');
    }
  }
}