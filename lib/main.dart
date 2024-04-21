import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Order Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LandingPage(),
    OrderPage(),
    CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Order Apps'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Landing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Future<List<dynamic>?> _fetchOrders() async {
    final response = await http.get(Uri.parse(
        'http://testdo.zonainformatika.com/public/api/deliveryorders'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void _updateStatus(int orderId, String status, {String? reason}) async {
    Map<String, String> body = {};
    if (reason != null) {
      body['reason_status'] = reason;
    }
    final response = await http.post(
      Uri.parse(
          'http://testdo.zonainformatika.com/api/deliveryorders/$orderId/$status'),
      body: body,
    );
    if (response.statusCode == 200) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Status updated successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status'),
      ));
    }
  }

  Future<void> _showRejectDialog(int orderId) async {
    String reason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reject Order'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: InputDecoration(labelText: 'Reason for rejection'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(orderId, 'reject', reason: reason);
                Navigator.of(context).pop();
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRevisiDialog(int orderId) async {
    String reason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Revisi Order'),
          content: TextField(
            onChanged: (value) {
              reason = value;
            },
            decoration: InputDecoration(labelText: 'Reason for revision'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(orderId, 'revisi', reason: reason);
                Navigator.of(context).pop();
              },
              child: Text('Revisi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: Failed to load orders'));
        } else {
          List<dynamic> orders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Order: ${order['nomerorder']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: \$${order['ordertotal']}'),
                          Text('Status: ${order['status']}'),
                          Text('Add Catatan: ${order['addcatatan'] ?? "-"}'),
                        ],
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _updateStatus(order['id'], 'approve');
                          },
                          child: Text('Approve'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showRejectDialog(order['id']);
                          },
                          child: Text('Reject'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showRevisiDialog(order['id']);
                          },
                          child: Text('Revisi'),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Cart Page'),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Landing Page'),
    );
  }
}
