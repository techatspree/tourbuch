import 'package:boh_tourbuch/screens/comments/comments_screen.dart';
import 'package:boh_tourbuch/screens/faq/faq_screen.dart';
import 'package:boh_tourbuch/screens/orders/orders_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search),
                        SizedBox(width: 10),
                        Text('Bestellungen')
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list_alt_sharp),
                      SizedBox(width: 10),
                      Text('Kommentare')
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.question_answer),
                      SizedBox(width: 10),
                      Text('FAQ')
                    ],
                  )
                ],
              ),
            ),
            body: const TabBarView(
                children: [OrdersScreen(), CommentsScreen(), FaqScreen()])),
      ),
    );
  }
}
