import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: userAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.displayName),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text('Rol: ${user.role}'),
                ),
                const Spacer(),
                CustomButton(
                  label: 'Cerrar sesión',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await ref.read(authServiceProvider).signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
