import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';
import '../data/verses_data.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class VerseSearchDelegate extends SearchDelegate<Verse?> {
  final Function(int) onVerseSelected;
  static const String _searchHistoryKey = 'verse_search_history';
  static const int _maxHistoryItems = 5;

  VerseSearchDelegate({
    required this.onVerseSelected, required SettingsProvider settingsProvider,
  });

  Future<List<String>> _getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];
    
    // Remove if exists and add to front
    history.remove(query);
    history.insert(0, query);
    
    // Keep only last N items
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }
    
    await prefs.setStringList(_searchHistoryKey, history);
  }

  @override
  String get searchFieldLabel => 'Search verses... / ጥቅሶችን ፈልግ...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _addToSearchHistory(query);
    return _buildSearchResults(context);  // Pass context here
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getSearchHistory(),
      builder: (context, snapshot) {
        if (query.isEmpty && snapshot.hasData && snapshot.data!.isNotEmpty) {
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final historyItem = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(historyItem),
                onTap: () {
                  query = historyItem;
                  showResults(context);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.north_west),
                  onPressed: () {
                    query = historyItem;
                  },
                ),
              );
            },
          );
        }
        return _buildSearchResults(context);  // Pass context here
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          Provider.of<SettingsProvider>(context, listen: false).language == 'en'
              ? 'Type to search verses'
              : 'ጥቅሶችን ለመፈለግ ይጻፉ',
        ),
      );
    }

    final results = versesData.entries.where((entry) {
      final verse = entry.value;
      final searchQuery = query.toLowerCase();
      
      if (Provider.of<SettingsProvider>(context, listen: false).language == 'en') {
        return verse.translation.toLowerCase().contains(searchQuery) ||
            verse.referenceTranslation.toLowerCase().contains(searchQuery);
      } else {
        return verse.verseText.toLowerCase().contains(searchQuery) ||
            verse.reference.toLowerCase().contains(searchQuery);
      }
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          Provider.of<SettingsProvider>(context, listen: false).language == 'en'
              ? 'No verses found'
              : 'ምንም ጥቅስ አልተገኘም',
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final verse = results[index].value;
        return ListTile(
          title: Text(
            Provider.of<SettingsProvider>(context, listen: false).language == 'en'
                ? verse.referenceTranslation
                : verse.reference,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            Provider.of<SettingsProvider>(context, listen: false).language == 'en'
                ? verse.translation
                : verse.verseText,
          ),
          onTap: () {
            onVerseSelected(results[index].key);
            _addToSearchHistory(query);
            close(context, verse);
          },
        );
      },
    );
  }
}
