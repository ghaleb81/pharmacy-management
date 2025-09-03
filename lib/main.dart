import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// نموذج بيانات الدواء
class Medicine {
  final String name;
  final double price;

  Medicine({required this.name, required this.price});
}

// نموذج بيانات المستخدم
class User {
  final String username;
  User({required this.username});
}

// نموذج بيانات السلة
class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صيدلية إلكترونية',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

// صفحة تسجيل الدخول
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  HomePage(user: User(username: usernameController.text)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المستخدم وكلمة المرور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: login, child: const Text('تسجيل الدخول')),
          ],
        ),
      ),
    );
  }
}

// الصفحة الرئيسية - قائمة الأدوية
class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Medicine> medicines = [
    Medicine(name: 'فيتامين سي', price: 5.0),
    Medicine(name: 'باراسيتامول', price: 2.5),
    Medicine(name: 'أموكسيسيلين', price: 10.0),
  ];

  final List<CartItem> cart = [];

  void addToCart(Medicine medicine) {
    setState(() {
      final existing = cart.where(
        (item) => item.medicine.name == medicine.name,
      );
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        cart.add(CartItem(medicine: medicine));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medicine.name} تمت إضافته إلى السلة')),
    );
  }

  void goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحبًا ${widget.user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: goToCart,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          return Card(
            child: ListTile(
              title: Text(medicine.name),
              subtitle: Text('السعر: \$${medicine.price}'),
              trailing: ElevatedButton(
                onPressed: () => addToCart(medicine),
                child: const Text('أضف للسلة'),
              ),
            ),
          );
        },
      ),
    );
  }
}

// صفحة السلة
class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice => widget.cart.fold(
    0,
    (sum, item) => sum + item.medicine.price * item.quantity,
  );

  void removeItem(CartItem item) {
    setState(() {
      widget.cart.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body:
          widget.cart.isEmpty
              ? const Center(child: Text('السلة فارغة'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final item = widget.cart[index];
                        return ListTile(
                          title: Text(item.medicine.name),
                          subtitle: Text(
                            'الكمية: ${item.quantity} - السعر: \$${(item.medicine.price * item.quantity).toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeItem(item),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'المجموع: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
