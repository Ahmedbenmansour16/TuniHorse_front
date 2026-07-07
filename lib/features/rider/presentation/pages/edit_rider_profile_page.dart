import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_api_client.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class EditRiderProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const EditRiderProfilePage({super.key, this.user});

  @override
  State<EditRiderProfilePage> createState() => _EditRiderProfilePageState();
}

class _EditRiderProfilePageState extends State<EditRiderProfilePage> {
  final _authApiClient = AuthApiClient();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? const <String, dynamic>{};
    _nameController = TextEditingController(
      text: _userValue(user, 'nomComplet', ''),
    );
    _phoneController = TextEditingController(
      text: _userValue(user, 'telephone', ''),
    );
    _cityController = TextEditingController(text: _userValue(user, 'ville', ''));
  }

  @override
  void dispose() {
    _authApiClient.close();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      _showError('Session expiree. Reconnectez-vous.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError('Le nom complet est obligatoire.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _authApiClient.updateMe(
        accessToken: token,
        body: {
          'nomComplet': _nameController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'ville': _cityController.text.trim(),
        },
      );

      AuthSessionStore.updateUser(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis a jour.')),
      );
      Navigator.of(context).pop(updated);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _userValue(widget.user, 'email', '-');

    return AppPage(
      title: 'Modifier profil',
      showBack: true,
      children: [
        Center(child: _UserAvatar(name: _nameController.text)),
        const SizedBox(height: 18),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nom complet'),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: false,
          decoration: InputDecoration(labelText: 'Email', hintText: email),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Telephone'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(labelText: 'Ville'),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: _isSaving ? 'Enregistrement...' : 'Enregistrer',
          icon: Icons.save_outlined,
          onPressed: _isSaving ? null : _save,
        ),
        const SizedBox(height: 12),
        const Text(
          'Profil visible par votre equipe',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;

  const _UserAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0])
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.greenSoft,
      child: initials.isEmpty
          ? const Icon(Icons.person, color: AppColors.green, size: 40)
          : Text(
              initials,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

String _userValue(Map<String, dynamic>? user, String key, String fallback) {
  final value = user?[key]?.toString().trim();
  return value == null || value.isEmpty ? fallback : value;
}
