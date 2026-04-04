// OntarioTechPlus - menu_page
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ontario_tech_plus/home//webview_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: ListView(
        children: const [
          // ================= MY FINANCES =================
          MenuSection(
            title: "My finances",
            items: [
              MenuItemData(
                icon: Icons.attach_money,
                label: "Undergraduate\nfinances",
                url: "https://ontariotechu.ca/current-students/finances/",
              ),
              MenuItemData(
                icon: Icons.attach_money,
                label: "Graduate\nfinances",
                url: "https://gradstudies.ontariotechu.ca/",
              ),
              MenuItemData(
                icon: Icons.savings,
                label: "Awards and\nfinancial aid",
                url: "https://ontariotechu.ca/awards/",
              ),
            ],
          ),

          // ================= HELPING YOU SUCCEED =================
          MenuSection(
            title: "Helping you succeed",
            items: [
              MenuItemData(
                icon: Icons.menu_book,
                label: "Academic\nsupport",
                url:
                    "https://studentlife.ontariotechu.ca/services/academic-support/index.php",
              ),
              MenuItemData(
                icon: Icons.work_outline,
                label: "Career\nreadiness",
                url:
                    "https://studentlife.ontariotechu.ca/services/career-readiness/index.php",
              ),
              MenuItemData(
                icon: Icons.backpack,
                label: "Undergraduate\nresources",
                url: "https://ontariotechu.ca/current-students/",
              ),
              MenuItemData(
                icon: Icons.school,
                label: "Graduate\nresources",
                url: "https://gradstudies.ontariotechu.ca/current-students/",
              ),
              MenuItemData(
                icon: Icons.accessibility,
                label: "Orientation",
                url: "https://orientation.ontariotechu.ca/",
              ),
            ],
          ),

          // ================= STUDENT SERVICES =================
          MenuSection(
            title: "Student services",
            items: [
              MenuItemData(
                icon: Icons.favorite_border,
                label: "Health and\nwellness",
                url: "https://ontariotechu.ca/studentlife/health-and-wellness/",
              ),
              MenuItemData(
                icon: Icons.warning_amber,
                label: "Crisis Centre",
                url: "https://ontariotechu.ca/studentlife/crisis-support/",
              ),
              MenuItemData(
                icon: Icons.local_hospital,
                label: "Sexual\nviolence",
                url: "https://ontariotechu.ca/studentlife/sexual-violence/",
              ),
              MenuItemData(
                icon: Icons.computer,
                label: "IT Services",
                url: "https://itsc.ontariotechu.ca/",
              ),
              MenuItemData(
                svgPath: 'assets/icons/library.svg',
                label: "Library",
                url: "https://library.ontariotechu.ca/",
              ),
              MenuItemData(
                icon: Icons.assignment_ind,
                label: "Registrar",
                url: "https://registrar.ontariotechu.ca/",
              ),
              MenuItemData(
                icon: Icons.public,
                label: "Student\nUnion",
                url: "https://www.otsu.ca/",
              ),
              MenuItemData(
                icon: Icons.info_outline,
                label: "Campus info",
                url: "https://ontariotechu.ca/campus-services/",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= SECTION =================

class MenuSection extends StatefulWidget {
  final String title;
  final List<MenuItemData> items;

  const MenuSection({super.key, required this.title, required this.items});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF003C71),
            ),
          ),
          trailing: AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.expand_more),
          ),
          onTap: () => setState(() => expanded = !expanded),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (_, i) => MenuItem(item: widget.items[i]),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

// ================= DATA =================

class MenuItemData {
  final String? svgPath;
  final IconData? icon;
  final String label;
  final String url;

  const MenuItemData({
    this.svgPath,
    this.icon,
    required this.label,
    required this.url,
  });
}

// ================= ITEM =================

class MenuItem extends StatelessWidget {
  final MenuItemData item;

  const MenuItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewPage(
              url: item.url,
              title: item.label.replaceAll('\n', ' '),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.svgPath != null)
            SvgPicture.asset(
              item.svgPath!,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Color(0xFF003C71),
                BlendMode.srcIn,
              ),
            )
          else
            Icon(item.icon, size: 32, color: const Color(0xFF003C71)),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
