import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/book_service.dart';
import 'book_detail.dart';
import 'cart.dart';
import 'profile.dart';
import 'orders.dart';
import 'wishlist.dart';
import 'admin_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  final searchCtrl = TextEditingController();
  String filter = '';
  String selectedGenre = 'All';

  final List<String> genres = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Romance',
    'Thriller',
    'Fantasy',
    'Science'
  ];

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 233, 233, 247),

        // 🟣 Drawer
        drawer: Drawer(
          child: Container(
            color: const Color.fromARGB(255, 253, 253, 253),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
               ListTile(
                  leading: const Icon(Icons.home, color: Color.fromARGB(255, 79, 6, 92)),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Color.fromARGB(255, 93, 14, 107)),
                  title: const Text('Orders'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Color.fromARGB(255, 72, 6, 83)),
                  title: const Text('Wishlist'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  ),
                ),
                   const Divider(),

      ListTile(
        leading: const Icon(Icons.account_circle, color: Color(0xFF4B0857), size: 28,),
        title: const Text('Profile'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
              ],
            ),
          ),
        ),

        // 🟣 AppBar
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Book Hive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Bestsellers'),
              Tab(text: 'New Arrivals'),
            ],
          ),
        ),

        // 🟣 Body
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildTabContent(_bookService.getAllBooks()),
              _buildTabContent(_bookService.getBestsellers()),
              _buildTabContent(_bookService.getNewArrivals()),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Tab content
  Widget _buildTabContent(Stream<QuerySnapshot> stream) {
    return Column(
      children: [
        // 🔍 Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by title, author, or genre...',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) => setState(() => filter = value.trim()),
            ),
          ),
        ),

        // 🟣 Genre Chips
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final genre = genres[index];
              final isSelected = genre == selectedGenre;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedGenre = genre),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF6A1B9A),
                  elevation: isSelected ? 3 : 0,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                ),
              );
            },
          ),
        ),

        // 📚 Book Grid
        Expanded(child: _buildBookGrid(stream)),
      ],
    );
  }

  // ✅ Book Grid with Heart + Wishlist sync
  Widget _buildBookGrid(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toLowerCase() ?? '';
          final author = data['author']?.toLowerCase() ?? '';
          final genre = data['genre']?.toLowerCase() ?? '';

          final matchSearch = filter.isEmpty ||
              title.contains(filter.toLowerCase()) ||
              author.contains(filter.toLowerCase()) ||
              genre.contains(filter.toLowerCase());

          final matchGenre = selectedGenre == 'All' ||
              data['genre'] == selectedGenre;

          return matchSearch && matchGenre;
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('No books found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bookId = doc.id;

            return StreamBuilder<DocumentSnapshot>(
              stream: user != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('wishlist')
                      .doc(bookId)
                      .snapshots()
                  : const Stream.empty(),
              builder: (context, wishSnapshot) {
                final isWishlisted =
                    wishSnapshot.hasData && wishSnapshot.data!.exists;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(bookId: bookId),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(2, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 14,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(18)),
                            child: data['coverUrl'] != null
                                ? Image.network(
                                    data['coverUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported,
                                            color: Colors.grey, size: 60),
                                  )
                                : Container(
                                    color: Colors.deepPurple.shade50,
                                    child: const Icon(Icons.book,
                                        color: Colors.deepPurple, size: 60),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'No title',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['author'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    fontStyle: FontStyle.italic, // 👈 makes it tilted
                                  ),
                                ),

                                const SizedBox(height: 2),
                                Text(
                                  data['genre'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.green),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${data['price'] ?? 0}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isWishlisted
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isWishlisted
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        if (user == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Please log in to use wishlist')));
                                          return;
                                        }

                                        final wishlistRef = FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(user!.uid)
                                            .collection('wishlist')
                                            .doc(bookId);

                                        if (isWishlisted) {
                                          await wishlistRef.delete();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Removed from Wishlist 🤍')));
                                        } else {
                                          await wishlistRef.set({
                                            'title': data['title'],
                                            'author': data['author'],
                                            'genre': data['genre'],
                                            'price': data['price'],
                                            'coverUrl': data['coverUrl'],
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Added to Wishlist ❤️')));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
