import 'package:acslg/pekerjaan/masuk/tab_1.dart';
import 'package:acslg/pekerjaan/masuk/tab_2.dart';
import 'package:acslg/pekerjaan/masuk/tab_3.dart';
import 'package:acslg/pekerjaan/selesai/tab_1.dart';
import 'package:acslg/pekerjaan/selesai/tab_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'dart:convert';



class NavBar extends StatelessWidget {
  const NavBar({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Interphases'),
      home: const OpsiNavigasi(opsi: 0, index: 0),
    );
  }
}

int jobdesk = 0;
int scrollWheelPos = 0;

class OpsiNavigasi extends StatefulWidget {
  const OpsiNavigasi({super.key, required this.opsi, required this.index});
  final int opsi;
  final int index;

  @override
  State<StatefulWidget> createState() => _OpsiNavigasiState();
}

class _OpsiNavigasiState extends State<OpsiNavigasi> with SingleTickerProviderStateMixin {
  late int halIndex = widget.opsi;
  late int tabIndex = widget.index;
  late TabController tabController;
  final scrollController = ScrollController();


  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tabController.index = tabIndex;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VENDOR AC SLG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halIndex,
        onTap: (index) => setState(() => halIndex = index),
        iconSize: 15,
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 134, 25, 17),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service), 
            label: 'Pekerjaan',
            backgroundColor: const Color.fromARGB(255, 183, 187, 192)
          ),
          BottomNavigationBarItem(
            icon: Badge(
            child: Icon(Icons.library_books)
            ), 
            label: 'Hasil Kerja',
            backgroundColor: const Color.fromARGB(255, 183, 187, 192)
          ),
        ],
        
      ),

      body: <Widget>[
        //LIST PEKERJAAN (TAB 1)--------------------------------------------
        Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const SizedBox(height: 0),
                Container(
                  //height: 50,
                  width: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.zero
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: tabController,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: const [
                        Tab(
                          text: 'Masuk',
                        ),
                        Tab(
                          text: 'Proses',
                        ),
                        Tab(
                          text: 'Observasi',
                        ),
                        ]
                      ,)
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: const [
                      Tab1masuk(),
                      Tab2masuk(),
                      Tab3masuk(),
                    ]
                  )
                )
              ],
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const SizedBox(height: 0),
                Container(
                  //height: 50,
                  width: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.zero
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: tabController,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: const [
                        Tab(
                          text: 'Garansi',
                        ),
                        Tab(
                          text: 'Tagihan',
                        ),
                        ]
                      ,)
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: const [
                      Tab1selesai(),
                      Tab2selesai(),
                    ]
                  )
                )
              ],
            ),
          ),
        ),
      ][halIndex]
    );
  }
}