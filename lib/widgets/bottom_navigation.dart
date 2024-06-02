import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // backgroundColor: Color(0xFF588100),
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: '크루',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),

        // BottomNavigationBarItem(
        //   icon: Icon(Icons.route),
        //   label: '루트',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'MY',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemSelected,
    );
  }
}
