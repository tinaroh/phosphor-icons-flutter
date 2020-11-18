import 'dart:convert';
import 'dart:io';

/// Phosphor Icons generator
/// reads the phosphor json and generates a dart class
/// with all the phosphor icons constants
void main(List<String> arguments) {
  final jsonFile = File(arguments.first);
  assert(!jsonFile.existsSync());

  final icons = json.decode(jsonFile.readAsStringSync())['icons'];

  final fileLines = [
    """import 'package:phosphor_flutter/phosphor_flutter.dart';

// Auto Generated File


/// Class mean to be used inside a [Icon] widget
/// 
/// ```dart
/// Icon(
///   PhosphorIcons.pencilLine,
/// ),
/// ```
/// 
class PhosphorIcons {
  // Prevents instantiation and extend
  PhosphorIcons._();""",
  ];
  final constantsLines = <String>[];
  final mapGetterContent = <String>[
    '''
  static Map<String, PhosphorIconData> get allIconsAsMap => {
      ...boldIcons,
      ...regularIcons,
      ...thinIcons,
      ...lightIcons,
      ...fillIcons,
    };''',
  ];

  final mapBoldGetterContent = <String>[
    '\n  static Map<String, PhosphorIconDataBold> get boldIcons => {',
    '};'
  ];

  final mapRegularGetterContent = <String>[
    '\n  static Map<String, PhosphorIconDataRegular> get regularIcons => {',
    '};'
  ];

  final mapThinGetterContent = <String>[
    '\n  static Map<String, PhosphorIconDataThin> get thinIcons => {',
    '};'
  ];

  final mapLightGetterContent = <String>[
    '\n  static Map<String, PhosphorIconDataLight> get lightIcons => {',
    '};'
  ];

  final mapFillGetterContent = <String>[
    '\n  static Map<String, PhosphorIconDataFill> get fillIcons => {',
    '};'
  ];

  final mapShadowsGetter = '''
  static Map<PhosphorIconDataRegular, String> get shadows =>
      regularIcons.map<PhosphorIconDataRegular, String>(
          (key, value) => MapEntry(value, key + '-fill'));''';

  final iconsGetterContent =
      '\n  static List<PhosphorIconData> get icons => allIconsAsMap.values.toList();';
  final namesGetterContent =
      '\n  static List<String> get names => allIconsAsMap.keys.toList();';

  icons.forEach((icon) {
    dynamic properties = icon['properties'];
    String fullName = properties['name'];
    String name = formatName(fullName);
    int code = properties['code'];
    String hexCode = '0x' + code.toRadixString(16);
    String style = fullName.split('-').last;

    if (!fullName.contains(RegExp(r'(fill|bold|thin|light)'))) {
      style = 'regular';
    }

    var iconConstLine = '';

    switch (style) {
      case 'bold':
        mapBoldGetterContent.insert(
            mapBoldGetterContent.length - 1, "  '$fullName': $name,");
        iconConstLine =
            'static const $name = PhosphorIconDataBold($hexCode);\n';
        break;
      case 'fill':
        mapFillGetterContent.insert(
            mapFillGetterContent.length - 1, "  '$fullName': $name,");
        iconConstLine =
            'static const $name = PhosphorIconDataFill($hexCode);\n';
        break;
      case 'light':
        mapLightGetterContent.insert(
            mapLightGetterContent.length - 1, "  '$fullName': $name,");
        iconConstLine =
            'static const $name = PhosphorIconDataLight($hexCode);\n';
        break;
      case 'thin':
        mapThinGetterContent.insert(
            mapThinGetterContent.length - 1, "  '$fullName': $name,");
        iconConstLine =
            'static const $name = PhosphorIconDataThin($hexCode);\n';
        break;
      case 'regular':
      default:
        mapRegularGetterContent.insert(
            mapRegularGetterContent.length - 1, "  '$fullName': $name,");
        iconConstLine =
            'static const $name = PhosphorIconDataRegular($hexCode);\n';
        break;
    }

    constantsLines.add(
      '/// ![$fullName](https://raw.githubusercontent.com/phosphor-icons/phosphor-icons/master/assets/$style/$fullName.svg)',
    );
    constantsLines.add(iconConstLine);
  });

  fileLines.addAll(constantsLines);
  fileLines.add(iconsGetterContent);
  fileLines.add(namesGetterContent);
  fileLines.addAll(mapGetterContent);
  fileLines.addAll(mapRegularGetterContent);
  fileLines.addAll(mapBoldGetterContent);
  fileLines.addAll(mapFillGetterContent);
  fileLines.addAll(mapLightGetterContent);
  fileLines.addAll(mapThinGetterContent);
  fileLines.add(mapShadowsGetter);

  final finalString = fileLines.join('\n  ') + '\n}';

  final resultFile = File('./lib/src/phosphor_icons.dart');
  resultFile.writeAsStringSync(finalString);
}

String formatName(String name) {
  final splitName = name.toLowerCase().split('-');
  return splitName
      .map((word) {
        if (splitName.indexOf(word) == 0) return word;
        return word.replaceFirst(word[0], word[0].toUpperCase());
      })
      .toList()
      .join();
}
