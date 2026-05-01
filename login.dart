import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';

// ─── PREMIUM SAAS THEME COLORS (Subtle Pirate) ────────────────
class P {
  static const bg      = Color(0xFFFFFFFF); // White
  static const surface = Color(0xFFF7F7F7); // Light gray
  static const border  = Color(0xFFE5E5E5); // Duolingo border
  
  static const primary = Color(0xFF58CC02); // Duolingo Green
  static const yellow  = Color(0xFFFFC800); // Duolingo Yellow
  static const blue    = Color(0xFF1CB0F6); // Duolingo Blue
  static const orange  = Color(0xFFFF9600); // Duolingo Orange
  static const red     = Color(0xFFFF4B4B); // Duolingo Red
  
  static const text    = Color(0xFF4B4B4B); // Dark gray
  static const text2   = Color(0xFF777777); // Med gray
  static const text3   = Color(0xFFAFAFAF); // Light gray

  static const success = primary;
  static const warning = yellow;
  static const danger  = red;
  static const accent  = blue;

  static const bg2     = surface;
  static const border2 = border;
  static const rose    = red;
  static const accent2 = blue;
  static const emerald = primary;
  static const cyan    = blue;
  static const gold    = yellow;

  static const grad1 = [primary, blue];
  
  // Custom thick border decoration
  static BoxDecoration card({Color color = Colors.white, double br = 16}) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(br),
    border: Border.all(color: border, width: 2),
    boxShadow: [BoxShadow(color: border, offset: Offset(0, 4))],
  );
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  bool isLoading  = false;
  bool isLogin    = true;
  bool isHoveringBtn = false;

  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    emailCtrl.dispose(); passCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: P.text)),
      backgroundColor: P.bg2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.all(16),
    ));
  }

  bool validate() {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      showMsg('Please fill in all fields.'); return false;
    }
    if (!emailCtrl.text.contains('@')) {
      showMsg('Please enter a valid email address.'); return false;
    }
    if (passCtrl.text.trim().length < 6) {
      showMsg('Password must be at least 6 characters.'); return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!validate()) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard()));
    } catch (e) {
      if (!mounted) return;
      showMsg('Login failed. Check your credentials.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signup() async {
    if (!validate()) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      if (!mounted) return;
      showMsg('Account created successfully!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard()));
    } catch (e) {
      if (!mounted) return;
      showMsg('Signup failed. Email might be in use.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.bg,
      body: Stack(
        children: [
          // Animated Background Orbs
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (50 * _bgCtrl.value),
                    right: -100,
                    child: _blurOrb(300, P.gold.withOpacity(0.05)),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -100 + (50 * (1 - _bgCtrl.value)),
                    child: _blurOrb(400, Colors.blue.withOpacity(0.05)),
                  ),
                ],
              );
            },
          ),
          
          Row(
            children: [
              // LEFT: Branding
              Expanded(
                flex: 5,
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(seconds: 1),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  color: P.yellow,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: P.orange, width: 4),
                                ),
                                child: Icon(Icons.psychology_rounded, color: Colors.white, size: 60),
                              ),
                              SizedBox(height: 24),
                              Text("SkillQuest",
                                style: TextStyle(color: P.primary, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                              Text("LEARN. COMPETE. MASTER.",
                                style: TextStyle(color: P.text2, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // RIGHT: Login Form
              Expanded(
                flex: 6,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 480),
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: Offset(0, 20))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isLogin ? "Welcome Back" : "Get Started",
                          style: TextStyle(color: P.text, fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text(isLogin ? "Log in to your commander station." : "Create your credentials to join the fleet.",
                          style: TextStyle(color: P.text2, fontSize: 16)),
                        
                        SizedBox(height: 48),
                        
                        _label("Email Address"),
                        SizedBox(height: 12),
                        _field(ctrl: emailCtrl, hint: "commander@vessel.hq", type: TextInputType.emailAddress),
                        
                        SizedBox(height: 24),
                        
                        _label("Password"),
                        SizedBox(height: 12),
                        _field(ctrl: passCtrl, hint: "••••••••", obscure: true),
                        
                        SizedBox(height: 48),
                        
                        if (isLoading)
                          Center(child: CircularProgressIndicator(color: P.gold))
                        else
                          MouseRegion(
                            onEnter: (_) => setState(() => isHoveringBtn = true),
                            onExit: (_) => setState(() => isHoveringBtn = false),
                            child: GestureDetector(
                              onTap: isLogin ? login : signup,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: P.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Color(0xFF46A302), width: 0, style: BorderStyle.none),
                                  boxShadow: [BoxShadow(color: Color(0xFF46A302), offset: Offset(0, 5))],
                                ),
                                child: Text(isLogin ? "LOG IN" : "START LEARNING", 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ),
                          
                        SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLogin ? "Don't have an account? " : "Already have an account? ", style: TextStyle(color: P.text2, fontSize: 14)),
                              GestureDetector(
                                onTap: () => setState(() => isLogin = !isLogin),
                                child: Text(isLogin ? "Sign Up" : "Sign In", style: TextStyle(color: P.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _nexusLogo() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: P.border, width: 2),
      ),
      child: Center(
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: P.grad1),
            boxShadow: [BoxShadow(color: P.accent.withOpacity(0.5), blurRadius: 20)],
          ),
        ),
      ),
    );
  }

  Widget _blurOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.8, height: size * 0.8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: P.text2, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5));

  Widget _field({required TextEditingController ctrl, required String hint, bool obscure = false, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, obscureText: obscure, keyboardType: type,
      style: TextStyle(color: P.text, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: P.text3, fontSize: 16),
        filled: true, fillColor: Colors.white.withOpacity(0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: P.gold, width: 2)),
      ),
    );
  }
}

