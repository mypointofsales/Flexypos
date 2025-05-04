import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import '../widgets/theme_notifier.dart';

enum DarkModeOption { system, off, on }

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  bool _useCamera = false;
  String _layout = 'list';
  DarkModeOption _darkModeOption = DarkModeOption.system;
  String _languageMode = 'system'; // 'system', 'en', or 'id'

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('general_settings', limit: 1);
    if (result.isNotEmpty) {
      final settings = result.first;
      setState(() {
        _useCamera = settings['use_camera'] == 1;
        _layout = settings['layout']?.toString() ?? 'list';

        final darkModeValue = settings['dark_mode']?.toString() ?? 'system';
        _darkModeOption = DarkModeOption.values.firstWhere(
          (e) => e.name == darkModeValue,
          orElse: () => DarkModeOption.system,
        );

        final langVal = settings['language_mode']?.toString() ?? 'system';
        _languageMode = ['en', 'id'].contains(langVal) ? langVal : 'system';
      });

      // Apply locale
      if (_languageMode == 'system') {
        await context.resetLocale();
      } else {
        await context.setLocale(Locale(_languageMode));
      }
    }
  }

  Future<void> _saveSettings() async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('general_settings', {
      'id': 1,
      'use_camera': _useCamera ? 1 : 0,
      'layout': _layout,
      'dark_mode': _darkModeOption.name,
      'language_mode': _languageMode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _saveDarkModeSetting(DarkModeOption option) async {
    setState(() {
      _darkModeOption = option;
    });
    await _saveSettings();
    Provider.of<ThemeNotifier>(context, listen: false).update(option.name);
  }

  void _showDarkModeDialog() async {
    final selected = await showDialog<DarkModeOption>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('dark_mode'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                DarkModeOption.values.map((mode) {
                  return RadioListTile<DarkModeOption>(
                    value: mode,
                    groupValue: _darkModeOption,
                    onChanged: (val) => Navigator.pop(context, val),
                    title: Text(
                      mode == DarkModeOption.system
                          ? 'use_device_settings'.tr()
                          : mode == DarkModeOption.off
                          ? 'off'.tr()
                          : 'on'.tr(),
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      await _saveDarkModeSetting(selected);
    }
  }

  void _showLanguageDialog() async {
    final locales = {
      'use_device_settings'.tr(): null,
      'English': const Locale('en'),
      'Bahasa Indonesia': const Locale('id'),
    };

    String selectedKey =
        _languageMode == 'en'
            ? 'English'
            : _languageMode == 'id'
            ? 'Bahasa Indonesia'
            : 'use_device_settings'.tr();

    final selected = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                locales.entries.map((entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    groupValue: selectedKey,
                    onChanged: (val) => Navigator.pop(context, val),
                    title: Text(entry.key),
                  );
                }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      // Save key and apply
      if (selected == 'use_device_settings'.tr()) {
        _languageMode = 'system';
        await context.resetLocale();
      } else if (selected == 'English') {
        _languageMode = 'en';
        await context.setLocale(const Locale('en'));
      } else if (selected == 'Bahasa Indonesia') {
        _languageMode = 'id';
        await context.setLocale(const Locale('id'));
      }

      await _saveSettings();
      setState(() {});
    }
  }

  Widget buildDivider() => const Divider(
    height: 1,
    thickness: 0.6,
    indent: 16,
    endIndent: 16,
    color: Color(0xFFB0BEC5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'general_settings'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              SwitchListTile(
                value: _useCamera,
                title: Text('use_camera_to_scan'.tr()),
                onChanged: (v) {
                  setState(() => _useCamera = v);
                  _saveSettings();
                },
              ),
              buildDivider(),
              ListTile(
                title: Text(
                  'dark_mode'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _darkModeOption == DarkModeOption.system
                      ? 'use_device_settings'.tr()
                      : _darkModeOption == DarkModeOption.on
                      ? 'on'.tr()
                      : 'off'.tr(),
                ),
                onTap: _showDarkModeDialog,
              ),
              buildDivider(),
              ListTile(
                title: Text(
                  'home_screen_item_layout'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_layout == 'grid' ? 'grid'.tr() : 'list'.tr()),
                trailing: DropdownButton<String>(
                  value: _layout,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(value: 'list', child: Text('list'.tr())),
                    DropdownMenuItem(value: 'grid', child: Text('grid'.tr())),
                  ],
                  onChanged: (val) {
                    setState(() => _layout = val!);
                    _saveSettings();
                  },
                ),
              ),
              buildDivider(),
              ListTile(
                title: Text(
                  'language'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _languageMode == 'en'
                      ? 'English'
                      : _languageMode == 'id'
                      ? 'Bahasa Indonesia'
                      : 'use_device_settings'.tr(),
                ),
                onTap: _showLanguageDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
