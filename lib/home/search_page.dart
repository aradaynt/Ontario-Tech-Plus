// OntarioTechPlus - search_page
import 'package:flutter/material.dart';
import 'package:ontario_tech_plus/home/webview_page.dart';

class SearchItem {
  final String title;
  final String url;

  const SearchItem(this.title, this.url);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<SearchItem> allItems = const [
    SearchItem(
      "Health and Wellness",
      "https://ontariotechu.ca/studentlife/health-and-wellness/",
    ),
    SearchItem("IT Services", "https://itsc.ontariotechu.ca/"),
    SearchItem("Library", "https://library.ontariotechu.ca/"),
    SearchItem("Registrar", "https://registrar.ontariotechu.ca/"),
    SearchItem("Student Union", "https://www.otsu.ca/"),
    SearchItem(
      "Academic Support",
      "https://studentlife.ontariotechu.ca/services/academic-support/index.php",
    ),
  ];

  List<SearchItem> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = allItems;
  }

  void updateSearch(String query) {
    setState(() {
      filtered = allItems
          .where(
            (item) => item.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                return ListTile(
                  title: Text(item.title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WebViewPage(url: item.url, title: item.title),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
