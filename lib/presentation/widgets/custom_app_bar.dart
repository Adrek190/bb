import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showUserIcon;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onUserPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showUserIcon = true,
    this.showMenuButton = true,
    this.onMenuPressed,
    this.onUserPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,

      // زر القائمة في الجانب الأيسر (leading)
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed:
                  onMenuPressed ??
                  () {
                    // فتح القائمة الجانبية إذا كانت متوفرة
                    if (Scaffold.hasDrawer(context)) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
            )
          : null,

      // أيقونة المستخدم في الجانب الأيمن (actions) - مؤقتة
      actions: showUserIcon
          ? [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: onUserPressed,
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.amber,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ]
          : null,

      automaticallyImplyLeading: false, // إيقاف السهم التلقائي
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
