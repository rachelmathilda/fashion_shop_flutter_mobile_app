import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/vaely_app_bar.dart';

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBg,
                      ),
                      child: const Icon(Icons.person_outline,
                          size: 50, color: AppColors.grey),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 16, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Lara',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('@lara_style',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              _menuItem(context, Icons.shopping_bag_outlined, 'Transactions',
                  () => context.push('/transactions')),
              _menuItem(context, Icons.person_outline, 'Edit Information',
                  () => context.push('/edit-profile')),
              _menuItem(context, Icons.language_outlined, 'Language',
                  () => context.push('/language')),
              _menuItem(context, Icons.notifications_outlined, 'Notification',
                  () {}),
              _menuItem(context, Icons.help_outline, 'Help & Support', () {}),
              _menuItem(context, Icons.logout, 'Log Out',
                  () => context.go('/login'),
                  color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }
}

// ─── Edit Profile Screen ──────────────────────────────────────────────────────

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            height: 180,
            color: AppColors.primary,
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  left: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cardBg,
                          ),
                          child: const Icon(Icons.person_outline,
                              size: 44, color: AppColors.grey),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                size: 14, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _inputField(Icons.alternate_email, 'Email'),
                const SizedBox(height: 14),
                _inputField(Icons.edit_outlined, 'Full Name'),
                const SizedBox(height: 14),
                _inputField(Icons.person_outline, 'Username'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(IconData icon, String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

// ─── Language Screen ──────────────────────────────────────────────────────────

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  final _languages = [
    'Bahasa Indonesia',
    'Brazilian Portuguese',
    'English',
    'French',
    'German',
    'Hangul',
    'Hindi',
    'Italian',
    'Japanese',
    'Spanish',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const PurpleHeader(title: 'Language'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _languages.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.divider, indent: 20, endIndent: 20),
                itemBuilder: (context, i) {
                  final lang = _languages[i];
                  return RadioListTile<String>(
                    value: lang,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v!),
                    activeColor: AppColors.primary,
                    title: Text(lang,
                        style: Theme.of(context).textTheme.bodyLarge),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Address Detail Screen ────────────────────────────────────────────────────

class AddressDetailScreen extends StatelessWidget {
  const AddressDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Address Detail',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Container(
        color: AppColors.greyLight,
        child: const Center(
          child: Icon(Icons.map_outlined, size: 80, color: AppColors.grey),
        ),
      ),
    );
  }
}
