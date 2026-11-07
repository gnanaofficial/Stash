import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedSegment = 0; // 0 = Sign In, 1 = Sign Up
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _canCheckBiometrics = false;

  bool get _isSignUp => _selectedSegment == 1;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await BiometricService.instance.canCheckBiometrics();
    if (mounted) setState(() => _canCheckBiometrics = canCheck);
  }

  Future<void> _unlockWithBiometrics() async {
    final authenticated = await BiometricService.instance.authenticate(
      reason: 'Scan fingerprint to unlock STASH Vault',
    );
    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: _buildGradientBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // ── App Icon ────────────────────────────────────────
              GlassContainer.card(
                quality: GlassQuality.standard,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appleLime, AppColors.appleEmerald],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.appleLime.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.square_stack_3d_up_fill,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Branding ─────────────────────────────────────────
              const Text(
                'STASH',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isSignUp
                      ? 'Create your private cloud vault'
                      : 'Welcome back to your smart vault',
                  key: ValueKey(_isSignUp),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Sign In / Sign Up Segmented Control ───────────────
              GlassSegmentedControl(
                segments: const [
                  GlassSegment(label: 'Sign In'),
                  GlassSegment(label: 'Sign Up'),
                ],
                selectedIndex: _selectedSegment,
                onSegmentSelected: (i) => setState(() {
                  _selectedSegment = i;
                  _errorMessage = null;
                }),
                quality: GlassQuality.standard,
              ),
              const SizedBox(height: 22),

              // ── Error banner ──────────────────────────────────────
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.applePink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.applePink.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_circle,
                          color: AppColors.applePink, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.applePink,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Username field (Sign Up only) ─────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: _isSignUp
                    ? Column(
                        children: [
                          GlassTextField(
                            controller: _usernameController,
                            placeholder: 'Username',
                            prefixIcon: const Icon(CupertinoIcons.person,
                                size: 17, color: AppColors.textTertiary),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              // ── Email field ───────────────────────────────────────
              GlassTextField(
                controller: _emailController,
                placeholder: 'Email address',
                prefixIcon: const Icon(CupertinoIcons.mail,
                    size: 17, color: AppColors.textTertiary),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),

              // ── Password field ────────────────────────────────────
              GlassPasswordField(
                controller: _passwordController,
                placeholder: 'Password',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : _authenticate(),
              ),
              const SizedBox(height: 20),

              // ── Submit Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GlassButton.custom(
                  width: double.infinity,
                  height: 50,
                  shape: const LiquidRoundedRectangle(borderRadius: 16),
                  onTap: _isLoading ? () {} : _authenticate,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(radius: 10, color: Colors.white)
                      : Text(
                          _isSignUp ? 'Create Vault Account' : 'Sign In to STASH',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                ),
              ),

              // ── Fingerprint Button (Sign In only) ─────────────────
              if (_canCheckBiometrics && !_isSignUp) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: GlassButton.custom(
                    width: double.infinity,
                    height: 48,
                    shape: const LiquidRoundedRectangle(borderRadius: 16),
                    glowColor: AppColors.appleLime,
                    onTap: _unlockWithBiometrics,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint,
                            color: AppColors.appleLime, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Unlock with Fingerprint',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Offline / Guest Link ───────────────────────────────
              const SizedBox(height: 14),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (_) => const HomeScreen()),
                ),
                child: const Text(
                  'Continue with Local Offline Vault →',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.bg),
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.appleLime.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.appleIndigo.withValues(alpha: 0.26),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 240,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.appleEmerald.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!SupabaseService.instance.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        return;
      }

      if (_isSignUp) {
        final res = await SupabaseService.instance.signUp(
          email: email,
          password: password,
          username: _usernameController.text.trim(),
        );
        if (res?.user != null && mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        final res = await SupabaseService.instance.signIn(
          email: email,
          password: password,
        );
        if (res?.user != null && mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
