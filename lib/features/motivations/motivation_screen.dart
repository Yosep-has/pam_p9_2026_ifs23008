import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/motivation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/theme_notifier.dart';

class MotivationScreen extends StatefulWidget {
  @override

  const MotivationScreen({super.key});
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MotivationProvider>();
    provider.fetchMotivations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.fetchMotivations();
      }
    });
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, HH:mm").format(parsed);
    } catch (e) {
      return date;
    }
  }

  final List<String> farmEmojis = ['🐄', '🐖', '🐔', '🐑', '🐐', '🦆', '🐇', '🐟'];

  void showGenerateDialog() {
    final themeController = TextEditingController();
    final totalController = TextEditingController();

    final List<String> suggestions = [
      'Sapi perah', 'Ayam broiler', 'Kambing etawa',
      'Babi ternak', 'Bebek petelur', 'Ikan lele',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<MotivationProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Text("🌾 "),
                  Text("Tanya Ahli Farm"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Topik Peternakan",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  SizedBox(height: 6),
                  TextField(
                    controller: themeController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Sapi perah, Ayam broiler...",
                      prefixIcon: Icon(Icons.agriculture),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: suggestions
                        .map((s) => ActionChip(
                      label: Text(s, style: TextStyle(fontSize: 11)),
                      onPressed: () => themeController.text = s,
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  Text("Jumlah Tips",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  SizedBox(height: 6),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Contoh: 3",
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                    await provider.generate(
                      themeController.text,
                      int.parse(totalController.text),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: provider.isGenerating
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text("Memproses..."),
                    ],
                  )
                      : Text("Dapatkan Tips"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotivationProvider>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final auth = context.watch<AuthProvider>();
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1B2A1B) : Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF2D4A2D) : Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text("🌾 "),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delcom Farm",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Halo, ${auth.username ?? 'User'}!",
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.dark_mode),
            onPressed: themeNotifier.toggleTheme,
          ),
          // Tombol logout
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Konfirmasi Logout"),
                  content: Text("Apakah Anda yakin ingin keluar?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text("Batal")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text("Logout",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await auth.logout();
                // Reset motivasi saat logout
                context.read<MotivationProvider>().reset();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showGenerateDialog,
        icon: Icon(Icons.agriculture),
        label: Text("Tanya Ahli"),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? Color(0xFF2D4A2D) : Color(0xFFDCEDC8),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates,
                        color: Color(0xFF4CAF50), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tap '🌾 Tanya Ahli' untuk mendapatkan tips peternakan dari AI",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.70)
                              : Color(0xFF33691E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.motivations.isEmpty && !provider.isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🐄", style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada tips peternakan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.70)
                              : Color(0xFF558B2F),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap tombol '🌾 Tanya Ahli' untuk mulai",
                        style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.54)
                                : Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 8, bottom: 120),
                  itemCount: provider.motivations.length + 1,
                  itemBuilder: (context, index) {
                    if (index < provider.motivations.length) {
                      final item = provider.motivations[index];
                      final number = index + 1;
                      final emoji =
                      farmEmojis[index % farmEmojis.length];

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? Color(0xFF2D4A2D) : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF4CAF50).withValues(alpha: 0.3)
                                : Color(0xFFA5D6A7),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    Text(emoji,
                                        style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Tips #$number",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  Text(
                                    formatDate(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white
                                          .withValues(alpha: 0.38)
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                item.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.white
                                      .withValues(alpha: 0.87)
                                      : Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return provider.isLoading
                          ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          CircularProgressIndicator(
                              color: Color(0xFF4CAF50)),
                          SizedBox(height: 8),
                          Text("Memuat tips..."),
                        ]),
                      )
                          : SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("🌾", style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      CircularProgressIndicator(color: Color(0xFF4CAF50)),
                      SizedBox(height: 12),
                      Text("Ahli farm sedang berpikir...",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}