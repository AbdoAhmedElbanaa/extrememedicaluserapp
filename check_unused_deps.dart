import 'dart:io';

void main() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final dependenciesSection = pubspecContent.split('dependencies:')[1].split('dev_dependencies:')[0];
  
  final packageRegex = RegExp(r'^\s+([a-zA-Z0-9_]+):', multiLine: true);
  final packages = packageRegex.allMatches(dependenciesSection).map((m) => m.group(1)!).toList();

  // Exclude core flutter packages
  packages.remove('flutter');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Error: lib directory not found.');
    exit(1);
  }

  final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  print('Scanning ${dartFiles.length} Dart files for ${packages.length} dependencies...\n');

  final unusedPackages = <String>[];
  
  for (final pkg in packages) {
    bool isUsed = false;
    final importPattern = "package:$pkg/";
    
    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      if (content.contains(importPattern)) {
        isUsed = true;
        break;
      }
    }

    if (!isUsed) {
      unusedPackages.add(pkg);
    }
  }

  if (unusedPackages.isEmpty) {
    print('🎉 All packages in pubspec.yaml are used in the codebase!');
  } else {
    print('🚫 Unused packages in pubspec.yaml:');
    for (final pkg in unusedPackages) {
      print('  - $pkg');
    }
  }
}
