class GeneralSettings {
  final int id;
  final int? useCamera;
  final String? darkMode;
  final String? layout;
  final String? languageMode;

  GeneralSettings({
    required this.id,
    this.useCamera,
    this.darkMode,
    this.layout,
    this.languageMode,
  });

  factory GeneralSettings.fromMap(Map<String, dynamic> map) => GeneralSettings(
    id: map['id'],
    useCamera: map['use_camera'],
    darkMode: map['dark_mode'],
    layout: map['layout'],
    languageMode: map['language_mode'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'use_camera': useCamera,
    'dark_mode': darkMode,
    'layout': layout,
    'language_mode': languageMode,
  };
}
