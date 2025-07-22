import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';

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

      // أيقونة المستخدم في الجانب الأيمن (actions)
      actions: showUserIcon
          ? [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<UserProfileProvider>(
                  builder: (context, userProvider, child) {
                    return GestureDetector(
                      onTap: onUserPressed,
                      child: userProvider.buildUserAvatar(
                        radius: 20.0,
                        backgroundColor: Colors.amber,
                        iconColor: Colors.grey.shade600,
                      ),
                    );
                  },
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
