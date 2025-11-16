import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryPurple = Color(0xFF8E24AA);
const Color kLightPurple = Color(0xFFE1BEE7);
const Color kLighterPurple = Color(0xFFF3E5F5);

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  // --- ADD OR UPDATE USER ---
  Future<void> _showUserDialog({DocumentSnapshot? userDoc}) async {
    final nameController =
        TextEditingController(text: userDoc?['name'] ?? '');
    final emailController =
        TextEditingController(text: userDoc?['email'] ?? '');
    final addressController =
        TextEditingController(text: userDoc?['address'] ?? '');
    final paymentController =
        TextEditingController(text: userDoc?['payment'] ?? '');

    final isEditing = userDoc != null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'Update User' : 'Add User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: kPrimaryPurple,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTextField(nameController, 'Name', Icons.person),
              const SizedBox(height: 10),
              _buildTextField(emailController, 'Email', Icons.email),
              const SizedBox(height: 10),
              _buildTextField(addressController, 'Address', Icons.location_on),
              const SizedBox(height: 10),
              _buildTextField(paymentController, 'Payment Method', Icons.payment),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  paymentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required!')),
                );
                return;
              }

              final data = {
                'name': nameController.text,
                'email': emailController.text,
                'address': addressController.text,
                'payment': paymentController.text,
                'isAdmin': false,
                'updatedAt': FieldValue.serverTimestamp(),
                if (!isEditing) 'createdAt': FieldValue.serverTimestamp(),
              };

              if (isEditing) {
                await usersRef.doc(userDoc!.id).update(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully!'),
                    backgroundColor: Colors.green, // ✅ green snackbar
                  ),
                );
              } else {
                await usersRef.add(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User added successfully!'),
                    backgroundColor: kPrimaryPurple,
                  ),
                );
              }

              Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Update' : 'Add',
              style: const TextStyle(
                color: Colors.white, // ✅ white button text
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DELETE USER CONFIRMATION ---
  Future<void> _confirmDelete(String userId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kLighterPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await usersRef.doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully!'),
          backgroundColor: Colors.red, // ✅ red snackbar
        ),
      );
    }
  }

  // --- REUSABLE INPUT FIELD ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kPrimaryPurple),
        labelText: label,
        filled: true,
        fillColor: kLightPurple.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryPurple, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLighterPurple,
      appBar: AppBar(
        backgroundColor: kPrimaryPurple,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ white back button
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 3,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.supervised_user_circle, color: Colors.white), // ✅ user icon
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // ✅ white label
        ),
        onPressed: () => _showUserDialog(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef
            .where('isAdmin', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found.',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>? ?? {};

              final name = data['name'] ?? 'No name';
              final email = data['email'] ?? 'No email';
              final address = data['address'] ?? 'Not provided';
              final payment = data['payment'] ?? 'Not provided';

              String createdAt = 'N/A';
              String updatedAt = 'N/A';

              if (data['createdAt'] != null) {
                try {
                  final ts = data['createdAt'];
                  final date = ts is Timestamp
                      ? ts.toDate()
                      : DateTime.tryParse(ts.toString());
                  if (date != null) {
                    createdAt =
                        '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  }
                } catch (_) {}
              }

              if (data['updatedAt'] != null) {
                try {
                  final ts = data['updatedAt'];
                  final date = ts is Timestamp
                      ? ts.toDate()
                      : DateTime.tryParse(ts.toString());
                  if (date != null) {
                    updatedAt =
                        '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  }
                } catch (_) {}
              }

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                  title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    const SizedBox(height: 4),
    const Divider(
      color: Colors.deepPurple, // you can change color if needed
      thickness: 1.2,
      endIndent: 30, // slight right margin for better alignment
    ),
  ],
),
subtitle: Padding(
  padding: const EdgeInsets.only(top: 6),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Email: $email'),
      Text('Address: $address'),
      Text('Payment: $payment'),
      const SizedBox(height: 4),
      Text('Created: $createdAt',
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text('Updated: $updatedAt',
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  ),
),

                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green), // ✅ green edit
                          onPressed: () => _showUserDialog(userDoc: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(user.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
