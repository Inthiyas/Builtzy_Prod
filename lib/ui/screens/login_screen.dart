import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/error_handler.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    await ref.read(authProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(next.error),
        );
      }
    });

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout(authState) : _buildMobileLayout(authState),
    );
  }

  Widget _buildDesktopLayout(AsyncValue<User?> authState) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildHeroSection(),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildLoginForm(authState),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AsyncValue<User?> authState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: _buildHeroSection(),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildLoginForm(authState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1541888086925-0cabd6f86b16?auto=format&fit=crop&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Stack(
        children: [
          // A gradient overlay to ensure text is readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.precision_manufacturing, size: 64, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  'Buildzy',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Manage your workforce and equipment with precision.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AsyncValue<User?> authState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 40),
        FilledButton(
          onPressed: authState.isLoading ? null : _login,
          child: authState.isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
            : const Text('Sign In'),
        ),
      ],
    );
  }
}
