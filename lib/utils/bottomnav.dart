import 'package:document_assistant/utils/utils.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 393;
    double ffem = MediaQuery.of(context).size.width / baseWidth;
    double fem = ffem * 15;

    return SafeArea(
      child: Material(
        elevation: 30,
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(1.5 * fem)),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 0.0,
            color: AppColors.scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(Icons.home, 'Home', 0, fem),
                SizedBox(width: 1.5 * fem), // Space for FAB
                _buildNavItem(Icons.file_copy, 'Documents', 1, fem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds a navigation item with an icon and label
  Widget _buildNavItem(IconData icon, String label, int index, double fem) {
    return GestureDetector(
      onTap: () => onItemTapped(index), // Trigger the callback when tapped
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: selectedIndex == index
                ? AppColors.primaryColor
                : AppColors.darkColor.withOpacity(0.4),
            size: 20, // Set icon size
          ),
          const SizedBox(height: 5), // Spacing between icon and label
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selectedIndex == index
                  ? AppColors.primaryColor
                  : AppColors.darkColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
