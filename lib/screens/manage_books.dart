import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/book_service.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageBooks extends StatefulWidget {
  const ManageBooks({super.key});

  @override
  State<ManageBooks> createState() => _ManageBooksState();
}

class _ManageBooksState extends State<ManageBooks> {
  final BookService bookService = BookService();
  final UserService userService = UserService();

  final titleCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  bool isAdmin = false;
  bool loading = true;
  bool isBestseller = false;
  bool isNewArrival = false;
  String? selectedGenre;

  final List<String> genres = [
    'Fiction',
    'Non-Fiction',
    'Romance',
    'Thriller',
    'Fantasy',
    'Science',
  ];

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final admin = await userService.isAdmin(uid);
    setState(() {
      isAdmin = admin;
      loading = false;
    });
  }

  Future<void> _addBook() async {
    final price = double.tryParse(priceCtrl.text) ?? 0.0;
    final stock = int.tryParse(stockCtrl.text) ?? 0;

    if (titleCtrl.text.isEmpty ||
        authorCtrl.text.isEmpty ||
        selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please fill all required fields!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await bookService.addBook({
      'title': titleCtrl.text.trim(),
      'author': authorCtrl.text.trim(),
      'genre': selectedGenre!,
      'description': descCtrl.text.trim(),
      'price': price,
      'stock': stock,
      'coverUrl': imageCtrl.text.trim(),
      'isBestseller': isBestseller,
      'isNewArrival': isNewArrival,
    });

    titleCtrl.clear();
    authorCtrl.clear();
    descCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
    imageCtrl.clear();

    setState(() {
      selectedGenre = null;
      isBestseller = false;
      isNewArrival = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📚 Book added successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (!isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            '🚫 Access Denied\n(Admin Only)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddBookCard(),
            const SizedBox(height: 24),
            const Text(
              '📚 All Books',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildAllBooksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBookCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFEDE7F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Book',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(titleCtrl, 'Title'),
          _buildTextField(authorCtrl, 'Author'),
          _buildTextField(imageCtrl, 'Image URL (required)'),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGenre,
                hint: const Text('Select Genre'),
                isExpanded: true,
                items: genres.map((genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedGenre = value),
              ),
            ),
          ),
          _buildTextField(descCtrl, 'Description', maxLines: 2),
          _buildTextField(priceCtrl, 'Price'),
          _buildTextField(stockCtrl, 'Stock'),

          Row(
            children: [
              Checkbox(
                value: isBestseller,
                activeColor: Colors.deepPurple,
                onChanged: (val) => setState(() => isBestseller = val ?? false),
              ),
              const Text('Bestseller'),
              const SizedBox(width: 20),
              Checkbox(
                value: isNewArrival,
                activeColor: Colors.deepPurple,
                onChanged: (val) => setState(() => isNewArrival = val ?? false),
              ),
              const Text('New Arrival'),
            ],
          ),

          const SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Book',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _addBook,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.deepPurple, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.deepPurple.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAllBooksSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: bookService.getAllBooks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No books added yet.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: data['coverUrl'] != null &&
                        data['coverUrl'].toString().isNotEmpty
                    ? Image.network(data['coverUrl'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.book, color: Colors.deepPurple),
                title: Text(
                  data['title'] ?? 'Untitled',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                subtitle: Text(
                  '${data['author'] ?? 'Unknown Author'}  |  ${data['genre'] ?? ''}\n'
                  '⭐ Bestseller: ${data['isBestseller'] ? 'Yes' : 'No'}  |  🆕 New: ${data['isNewArrival'] ? 'Yes' : 'No'}',
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => _openEditDialog(context, d.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await bookService.deleteBook(d.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('🗑️ Book deleted successfully!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final tempTitleCtrl = TextEditingController(text: data['title'] ?? '');
    final tempAuthorCtrl = TextEditingController(text: data['author'] ?? '');
    final tempDescCtrl = TextEditingController(text: data['description'] ?? '');
    final tempPriceCtrl = TextEditingController(text: (data['price'] ?? '').toString());
    final tempStockCtrl = TextEditingController(text: (data['stock'] ?? '').toString());
    final tempImageCtrl = TextEditingController(text: data['coverUrl'] ?? '');
    String? tempGenre = data['genre'];
    bool tempBest = data['isBestseller'] ?? false;
    bool tempNew = data['isNewArrival'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Edit Book', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(tempTitleCtrl, 'Title'),
                  _buildTextField(tempAuthorCtrl, 'Author'),
                  _buildTextField(tempImageCtrl, 'Image URL'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempGenre,
                        hint: const Text('Select Genre'),
                        isExpanded: true,
                        items: genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) => setStateDialog(() => tempGenre = val),
                      ),
                    ),
                  ),
                  _buildTextField(tempDescCtrl, 'Description', maxLines: 2),
                  _buildTextField(tempPriceCtrl, 'Price'),
                  _buildTextField(tempStockCtrl, 'Stock'),
                  Row(
                    children: [
                      Checkbox(
                        value: tempBest,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => setStateDialog(() => tempBest = v ?? false),
                      ),
                      const Text('Bestseller'),
                      const SizedBox(width: 20),
                      Checkbox(
                        value: tempNew,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => setStateDialog(() => tempNew = v ?? false),
                      ),
                      const Text('New Arrival'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await bookService.updateBook(docId, {
                    'title': tempTitleCtrl.text.trim(),
                    'author': tempAuthorCtrl.text.trim(),
                    'genre': tempGenre,
                    'description': tempDescCtrl.text.trim(),
                    'price': double.tryParse(tempPriceCtrl.text) ?? 0.0,
                    'stock': int.tryParse(tempStockCtrl.text) ?? 0,
                    'coverUrl': tempImageCtrl.text.trim(),
                    'isBestseller': tempBest,
                    'isNewArrival': tempNew,
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ Book updated successfully!'),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                },
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
