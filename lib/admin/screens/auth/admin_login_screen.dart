import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_theme.dart';
import '../../data/repositories/admin_auth_repository.dart';
import '../../../admin_widgets/admin_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminLoginScreen — responsive: single-column on mobile, two-panel on tablet+
// ─────────────────────────────────────────────────────────────────────────────

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;
  bool  _remember  = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AdminAuthRepository>();
    final ok = await auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 700;

    return Theme(
      data: AdminTheme.theme,
      child: Scaffold(
        backgroundColor: isMobile ? AdminColors.navyBlue : AdminColors.contentBg,
        body: isMobile
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  // ── Mobile: single scrollable column ──────────────────────────────────────

  Widget _buildMobileLayout() {
    final auth = context.watch<AdminAuthRepository>();
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Compact branding header ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [AdminColors.navyBlue, Color(0xFF0D3A8A)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo row
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AdminColors.royalBlue, AdminColors.teal],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.route_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BiliRoute', style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                          Text('Admin Portal', style: GoogleFonts.inter(
                            color: AdminColors.teal, fontSize: 11,
                            fontWeight: FontWeight.w600, letterSpacing: 0.8,
                          )),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tourism Office\nManagement System',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20, fontWeight: FontWeight.w700, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authorized personnel only.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ── Login form panel ─────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AdminColors.contentBg,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              // Overlap slightly on the gradient
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: _LoginForm(
                  formKey:          _formKey,
                  emailCtrl:        _emailCtrl,
                  passCtrl:         _passCtrl,
                  obscure:          _obscure,
                  remember:         _remember,
                  auth:             auth,
                  onToggleObscure:  () => setState(() => _obscure = !_obscure),
                  onToggleRemember: (v) => setState(() => _remember = v ?? false),
                  onLogin:          _login,
                  compact:          true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop/Tablet: side-by-side panels ────────────────────────────────────

  Widget _buildDesktopLayout() {
    final auth = context.watch<AdminAuthRepository>();
    return Row(
      children: [
        // Left branding panel — fixed 420px only on screens wide enough
        _DesktopBrandPanel(),

        // Right form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _LoginForm(
                  formKey:          _formKey,
                  emailCtrl:        _emailCtrl,
                  passCtrl:         _passCtrl,
                  obscure:          _obscure,
                  remember:         _remember,
                  auth:             auth,
                  onToggleObscure:  () => setState(() => _obscure = !_obscure),
                  onToggleRemember: (v) => setState(() => _remember = v ?? false),
                  onLogin:          _login,
                  compact:          false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop-only left branding panel
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopBrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [AdminColors.navyBlue, Color(0xFF0D3A8A)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AdminColors.royalBlue, AdminColors.teal],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),
              Text('BiliRoute', style: GoogleFonts.inter(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
              )),
              Text('Admin Portal', style: GoogleFonts.inter(
                color: AdminColors.teal, fontSize: 14, fontWeight: FontWeight.w600,
                letterSpacing: 1,
              )),
              const SizedBox(height: 40),
              Text(
                'Tourism Office\nManagement System',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage destinations, routes, transport providers, '
                'travel advisories, and field survey records for '
                'Biliran Province tourism mobility.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13, height: 1.6,
                ),
              ),
              const Spacer(),
              ...const [
                ('🏝', 'Destination CRUD & Verification'),
                ('🛣', 'Multi-step Route Builder'),
                ('🔬', 'Field Survey GPS Records'),
                ('⚙', 'Recommendation Weight Settings'),
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Text(item.$2, style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13, fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              Text(
                'BiliRoute v1.0 · Biliran Tourism Office',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.30), fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared login form — works on both mobile and desktop
// ─────────────────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.remember,
    required this.auth,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onLogin,
    required this.compact,
  });

  final GlobalKey<FormState>    formKey;
  final TextEditingController   emailCtrl;
  final TextEditingController   passCtrl;
  final bool                    obscure;
  final bool                    remember;
  final AdminAuthRepository     auth;
  final VoidCallback            onToggleObscure;
  final ValueChanged<bool?>     onToggleRemember;
  final VoidCallback            onLogin;
  final bool                    compact;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text('Welcome back,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AdminColors.textSecondary,
              )),
            const SizedBox(height: 4),
          ],
          Text(
            compact ? 'Sign in to Admin Portal' : 'Sign in to your account',
            style: compact
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium,
          ),

          SizedBox(height: compact ? 24 : 36),

          // Email
          _label('Email Address'),
          const SizedBox(height: 6),
          TextFormField(
            controller:   emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration:   const InputDecoration(
              hintText:   'admin@biliroute.ph',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@'))       return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          _label('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller:  passCtrl,
            obscureText: obscure,
            decoration:  InputDecoration(
              hintText:   '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6)           return 'Password too short';
              return null;
            },
          ),

          const SizedBox(height: 10),

          // Remember me
          Row(
            children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value:     remember,
                  onChanged: onToggleRemember,
                  activeColor: AdminColors.royalBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text('Remember me',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),

          const SizedBox(height: 14),

          // Error message
          if (auth.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:  AdminColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminColors.danger.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AdminColors.danger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(auth.error!,
                        style: const TextStyle(
                            color: AdminColors.danger, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Login button
          SizedBox(
            width:  double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : onLogin,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Sign In to Admin Portal'),
            ),
          ),

          SizedBox(height: compact ? 20 : 32),

          // Demo credentials box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminColors.tableHeader,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AdminColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Demo Credentials',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textSecondary,
                      )),
                  ],
                ),
                const SizedBox(height: 10),
                _credRow(context, 'Super Admin',
                    'admin@biliroute.ph', 'biliroute2025'),
                const SizedBox(height: 4),
                _credRow(context, 'Officer',
                    'officer@biliroute.ph', 'officer2025'),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'BiliRoute Admin Portal · For authorized personnel only.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: AdminColors.textPrimary,
    ),
  );

  Widget _credRow(BuildContext context, String role, String email, String pass) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(role, style: GoogleFonts.inter(
            fontSize: 11, color: AdminColors.textMuted,
            fontWeight: FontWeight.w500,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$email / $pass',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11, color: AdminColors.textSecondary,
              fontWeight: FontWeight.w500,
            )),
        ),
      ],
    );
  }
}
