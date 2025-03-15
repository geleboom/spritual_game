import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/verse_category.dart';
import '../models/verse.dart';
import '../services/custom_verse_service.dart';

class AddVerseScreen extends StatefulWidget {
  const AddVerseScreen({super.key});

  @override
  State<AddVerseScreen> createState() => _AddVerseScreenState();
}

class _AddVerseScreenState extends State<AddVerseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTopic = '';
  final _referenceController = TextEditingController();
  final _referenceTranslationController = TextEditingController();
  final _verseTextController = TextEditingController();
  final _translationController = TextEditingController();
  bool _isSaving = false;
  final bool _hasTranslation = false;

  @override
  void dispose() {
    _referenceController.dispose();
    _referenceTranslationController.dispose();
    _verseTextController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _pasteText(TextEditingController controller) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      controller.text = clipboardData!.text!;
    }
  }

  Future<void> _saveVerse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final verseId = await CustomVerseService.getNextVerseId();
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final isAmharic = settings.language == 'am';

      final verse = Verse(
        id: verseId,
        reference: _referenceController.text,
        referenceTranslation: _referenceTranslationController.text,
        verseText:
            isAmharic ? _verseTextController.text : _translationController.text,
        translation:
            isAmharic ? _translationController.text : _verseTextController.text,
      );

      await CustomVerseService.addCustomVerse(verse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAmharic ? 'ጥቅሱ ተጨምሯል' : 'Verse added successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<SettingsProvider>(context, listen: false).language ==
                      'am'
                  ? 'ጥቅሱ ሲጨምር ስህተት ተከሰተ'
                  : 'Error adding verse',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isAmharic = settings.language == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAmharic ? 'ጥቅስ አክል' : 'Add Verse',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Selection
              Text(
                isAmharic ? 'ርዕሰ ጉዳይ' : 'Topic',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTopic.isEmpty ? null : _selectedTopic,
                decoration: InputDecoration(
                  hintText: isAmharic ? 'ርዕሰ ጉዳይ ይምረጡ' : 'Select a topic',
                  border: const OutlineInputBorder(),
                ),
                items: VerseCategory.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(isAmharic ? category.nameAm : category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTopic = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic ? 'ርዕሰ ጉዳይ ይምረጡ' : 'Please select a topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reference Field (Primary Language)
              Text(
                isAmharic ? 'ጥቅስ መዛግብት (አማርኛ)' : 'Verse Reference (English)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  hintText: isAmharic ? 'ምሳሌ፡ ዮሐንስ 3:16' : 'Example: John 3:16',
                  border: const OutlineInputBorder(),
                  helperText: isAmharic
                      ? 'ከብዙ መጽሐፍ ቅዱስ የጥቅሱን መዛግብት ይግባቡ'
                      : 'Copy the verse reference from your Bible',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () => _pasteText(_referenceController),
                    tooltip: isAmharic ? 'ግባ' : 'Paste',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'ጥቅስ መዛግብት ይግባቡ'
                        : 'Please enter the verse reference';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reference Translation Field (Secondary Language)
              Text(
                isAmharic ? 'ጥቅስ መዛግብት (English)' : 'Verse Reference (Amharic)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _referenceTranslationController,
                decoration: InputDecoration(
                  hintText: isAmharic ? 'ምሳሌ፡ John 3:16' : 'ምሳሌ፡ ዮሐንስ 3:16',
                  border: const OutlineInputBorder(),
                  helperText: isAmharic
                      ? 'የጥቅሱን መዛግብት በተለያየ ቋንቋ ይግባቡ'
                      : 'Enter the verse reference in the other language',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () =>
                        _pasteText(_referenceTranslationController),
                    tooltip: isAmharic ? 'ግባ' : 'Paste',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'የጥቅሱ መዛግብት ትርጉም ይግባቡ'
                        : 'Please enter the reference translation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Verse Text Field (Primary Language)
              Text(
                isAmharic ? 'ጥቅስ ጽሑፍ (አማርኛ)' : 'Verse Text (English)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:
                    isAmharic ? _verseTextController : _translationController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAmharic
                      ? 'ከብዙ መጽሐፍ ቅዱስ የጥቅሱን ጽሑፍ ይግባቡ'
                      : 'Copy the verse text from your Bible',
                  border: const OutlineInputBorder(),
                  helperText: isAmharic
                      ? 'ከብዙ መጽሐፍ ቅዱስ የጥቅሱን ጽሑፍ በትክክል ይግባቡ'
                      : 'Copy the exact verse text from your Bible',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () => _pasteText(
                      isAmharic ? _verseTextController : _translationController,
                    ),
                    tooltip: isAmharic ? 'ግባ' : 'Paste',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'ጥቅስ ጽሑፍ ይግባቡ'
                        : 'Please enter the verse text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Translation Field (Secondary Language)
              Text(
                isAmharic ? 'ጥቅስ ጽሑፍ (English)' : 'Verse Text (Amharic)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:
                    isAmharic ? _translationController : _verseTextController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAmharic
                      ? 'የጥቅሱን ትርጉም ይግባቡ'
                      : 'Enter the verse text in Amharic',
                  border: const OutlineInputBorder(),
                  helperText: isAmharic
                      ? 'የጥቅሱን ትርጉም በትክክል ይግባቡ'
                      : 'Enter the exact verse text in Amharic',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () => _pasteText(
                      isAmharic ? _translationController : _verseTextController,
                    ),
                    tooltip: isAmharic ? 'ግባ' : 'Paste',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'የጥቅሱ ትርጉም ይግባቡ'
                        : 'Please enter the verse text in Amharic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveVerse,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isAmharic ? 'ጥቅስ አክል' : 'Add Verse',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
