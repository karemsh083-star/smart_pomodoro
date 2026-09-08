import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(const SmartPomodoroApp());
}

Map<String, String> registeredAccounts = {
  "karemshawki083@gmail.com": "Karem123456789"
};
Map<String, String> userNamesMap = {
  "karemshawki083@gmail.com": "Karem Shawki"
};

String globalUsername = "Guest User";
String globalEmail = "guest@example.com";
bool isLoggedWithGoogle = false;
class SmartPomodoroApp extends StatelessWidget {
  const SmartPomodoroApp({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pomodoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0A0E17),
        primaryColor: const Color(0xff38BDF8),
      ),
      home: const LoginRegisterScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; 
  final List<Widget> _screens = [
    const PomodoroTimerScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xff111827),
        selectedItemColor: const Color(0xff38BDF8),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);
  @override State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}
class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLoginView = true; 
  final TextEditingController _loginEmailOrUserCont = TextEditingController();
  final TextEditingController _loginPassCont = TextEditingController();
  final TextEditingController _regUserCont = TextEditingController();
  final TextEditingController _regEmailCont = TextEditingController();
  final TextEditingController _regPassCont = TextEditingController();

  bool _isValidEmail(String email) { return email.contains('@') && email.contains('.'); }

  void _triggerGoogleSignIn() {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xff111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: const [Icon(Icons.g_mobiledata, color: Colors.blue, size: 30), SizedBox(width: 12), Text('Sign in with Google', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const Divider(color: Colors.white10, height: 24),
              const Text('Choose an account to continue to Smart Pomodoro', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xff38BDF8), child: Icon(Icons.account_circle, color: Colors.black)),
                title: const Text('Click to choose your active account'), subtitle: const Text('Google Identity Secure Sync'),
                onTap: () {
                  globalEmail = _loginEmailOrUserCont.text.isNotEmpty && _isValidEmail(_loginEmailOrUserCont.text) ? _loginEmailOrUserCont.text.trim().toLowerCase() : "karemshawki083@gmail.com"; 
                  globalUsername = "Active Google User"; isLoggedWithGoogle = true;
                  Navigator.pop(context); Navigator.pushReplacement(this.context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _handleAuthSubmit() {
    if (_isLoginView) {
      String inputAuth = _loginEmailOrUserCont.text.trim().toLowerCase();
      String inputPass = _loginPassCont.text;
      if (inputAuth.isEmpty || inputPass.isEmpty) { _showSnackBar('Please fill in all fields!', Colors.orange); return; }
      String targetEmail = "";
      if (registeredAccounts.containsKey(inputAuth)) { targetEmail = inputAuth; } else {
        userNamesMap.forEach((email, uName) { if (uName.toLowerCase() == inputAuth) targetEmail = email; });
      }
      if (targetEmail.isNotEmpty && registeredAccounts[targetEmail] == inputPass) {
        globalEmail = targetEmail; globalUsername = userNamesMap[targetEmail] ?? "User"; isLoggedWithGoogle = false;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      } else { _showSnackBar('Wrong email or password! Access Denied.', Colors.redAccent); }
    } else {
      String regUser = _regUserCont.text.trim(); String regEmail = _regEmailCont.text.trim().toLowerCase(); String regPass = _regPassCont.text;
      if (regUser.isEmpty || regEmail.isEmpty || regPass.isEmpty) { _showSnackBar('Please fill in all fields!', Colors.orange); return; }
      if (!_isValidEmail(regEmail)) { _showSnackBar('Invalid email format! Requires @ and .com', Colors.redAccent); return; }
      if (registeredAccounts.containsKey(regEmail)) { _showSnackBar('This email is already registered!', Colors.amber.shade700); return; }
      if (regPass.length < 10) { _showSnackBar('Password must be 10+ characters!', Colors.redAccent); return; }
      registeredAccounts[regEmail] = regPass; userNamesMap[regEmail] = regUser; globalEmail = regEmail; globalUsername = regUser; isLoggedWithGoogle = false;
      _showSnackBar('Account verified! Logging in...', Colors.green); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
    }
  }
  void _showSnackBar(String text, Color color) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color, duration: const Duration(seconds: 3))); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff111827), Color(0xff0A0E17)])),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('SMART POMODORO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xff38BDF8), letterSpacing: 2)), SizedBox(height: 12), Text('Secure encrypt sync dashboard.', style: TextStyle(color: Colors.grey, fontSize: 13))])),
                  const SizedBox(width: 30), const VerticalDivider(color: Colors.white10, width: 1), const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isLoginView ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        if (_isLoginView) ...[_buildInputField('Username or Email', _loginEmailOrUserCont, false), const SizedBox(height: 10), _buildInputField('Password', _loginPassCont, true)]
                        else ...[_buildInputField('Full Username', _regUserCont, false), const SizedBox(height: 10), _buildInputField('Email Address', _regEmailCont, false), const SizedBox(height: 10), _buildInputField('Password (Min 10 chars)', _regPassCont, true)],
                        const SizedBox(height: 15),
                        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff38BDF8), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: _handleAuthSubmit, child: Text(_isLoginView ? 'Log In' : 'Register Now', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _triggerGoogleSignIn, icon: const Icon(Icons.g_mobiledata, color: Colors.amber, size: 22), label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 13)))),
                        const SizedBox(height: 10),
                        TextButton(onPressed: () { setState(() { _isLoginView = !_isLoginView; _loginEmailOrUserCont.clear(); _loginPassCont.clear(); _regUserCont.clear(); _regEmailCont.clear(); _regPassCont.clear(); }); }, child: Text(_isLoginView ? "Create account" : "Log In", style: const TextStyle(color: Color(0xff38BDF8), fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInputField(String label, TextEditingController controller, bool obscure) { return SizedBox(height: 45, child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xff1F2937), contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))); }
}
class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({Key? key}) : super(key: key);
  @override State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  int _maxSeconds = 25 * 60; int _totalSeconds = 25 * 60; Timer? _timer; bool _isRunning = false; bool _isFlipClockMode = false; 
  String _currentMode = "pomodoro"; int _longBreakMinutes = 15; int _sessionsBeforeLongBreak = 4;
  String _selectedIntervalType = "25/5"; int _currentStudyMins = 25; int _currentBreakMins = 5;

  void _playAlarmSound() { int count = 0; Timer.periodic(const Duration(milliseconds: 150), (soundTimer) { if (count < 8) { SystemSound.play(SystemSoundType.click); count++; } else { soundTimer.cancel(); } }); }

  void _showBreakDialog() {
    _playAlarmSound();
    showDialog(
      context: context, barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff111827), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [Icon(Icons.alarm, color: Color(0xff38BDF8)), SizedBox(width: 10), Text('Time is Up!', style: TextStyle(fontWeight: FontWeight.bold))]),
          content: const Text('Focus session completed successfully! Ready for your break?', style: TextStyle(color: Colors.grey, height: 1.4)),
          actions: [
            TextButton(onPressed: () { Navigator.of(context).pop(); _resetTimer(); }, child: const Text('Skip', style: TextStyle(color: Colors.grey))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff38BDF8)), onPressed: () { Navigator.of(context).pop(); setState(() { _maxSeconds = _currentBreakMins * 60; _totalSeconds = _maxSeconds; _currentMode = "short"; _startTimer(); }); }, child: const Text('Start Break', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
  }
  void _openTimerSettingsSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xff111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24.0), height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Timer Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff38BDF8))), IconButton(icon: const Icon(Icons.close, color: Colors.white30), onPressed: () => Navigator.pop(context))]),
                  const Divider(color: Colors.white10, height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Pomodoro Mode', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButton<String>(
                                value: _selectedIntervalType, dropdownColor: const Color(0xff1F2937), isExpanded: true, underline: Container(),
                                items: <String>["25/5", "50/10", "75/15", "100/20"].map((String val) { return DropdownMenuItem<String>(value: val, child: Text('Mode $val', style: const TextStyle(fontSize: 13))); }).toList(),
                                onChanged: (val) { if (val != null) { int study = 25; int brk = 5; if (val == "50/10") { study = 50; brk = 10; } if (val == "75/15") { study = 75; brk = 15; } if (val == "100/20") { study = 100; brk = 20; } setState(() { _selectedIntervalType = val; _currentStudyMins = study; _currentBreakMins = brk; _currentMode = "pomodoro"; _maxSeconds = study * 60; _totalSeconds = _maxSeconds; _isRunning = false; _timer?.cancel(); }); setSheetState(() { _selectedIntervalType = val; }); } },
                              ),
                              const SizedBox(height: 15),
                              const Text('Interval Target', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButton<int>(
                                value: _sessionsBeforeLongBreak, dropdownColor: const Color(0xff1F2937), isExpanded: true, underline: Container(),
                                items: const [DropdownMenuItem<int>(value: 2, child: Text('After 2 Sessions', style: TextStyle(fontSize: 13))), DropdownMenuItem<int>(value: 3, child: Text('After 3 Sessions', style: TextStyle(fontSize: 13))), DropdownMenuItem<int>(value: 4, child: Text('After 4 Sessions', style: TextStyle(fontSize: 13))), DropdownMenuItem<int>(value: 5, child: Text('After 5 Sessions', style: TextStyle(fontSize: 13)))],
                                onChanged: (val) { if (val != null) { setState(() => _sessionsBeforeLongBreak = val); setSheetState(() => _sessionsBeforeLongBreak = val); } },
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(color: Colors.white10, width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Long Break Duration', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Expanded(child: ListWheelScrollView.useDelegate(itemExtent: 35, perspective: 0.005, diameterRatio: 1.2, physics: const FixedExtentScrollPhysics(), onSelectedItemChanged: (index) { int newMins = index + 5; setState(() => _longBreakMinutes = newMins); setSheetState(() => _longBreakMinutes = newMins); }, childDelegate: ListWheelChildBuilderDelegate(childCount: 26, builder: (context, index) { int currentMinuteItem = index + 5; bool isSelected = currentMinuteItem == _longBreakMinutes; return Center(child: Text('$currentMinuteItem mins', style: TextStyle(fontSize: isSelected ? 16 : 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xff38BDF8) : Colors.white30))); }))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _startTimer() { if (_isRunning) return; setState(() { _isRunning = true; }); _timer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() { if (_totalSeconds > 0) { _totalSeconds--; } else { _timer?.cancel(); _isRunning = false; _showBreakDialog(); } }); }); }
  void _pauseTimer() { if (!_isRunning) return; _timer?.cancel(); setState(() { _isRunning = false; }); }
  void _resetTimer() { _timer?.cancel(); setState(() { _isRunning = false; if (_currentMode == "pomodoro") _maxSeconds = _currentStudyMins * 60; if (_currentMode == "short") _maxSeconds = _currentBreakMins * 60; if (_currentMode == "long") _maxSeconds = _longBreakMinutes * 60; _totalSeconds = _maxSeconds; }); }
  void _switchMode(String mode, int minutes) { _timer?.cancel(); setState(() { _isRunning = false; _currentMode = mode; _maxSeconds = minutes * 60; _totalSeconds = _maxSeconds; }); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    int minutes = _totalSeconds ~/ 60; int seconds = _totalSeconds % 60; String minStr = minutes.toString().padLeft(2, '0'); String secStr = seconds.toString().padLeft(2, '0'); double progressPercentage = _totalSeconds / _maxSeconds; Color circleColor = _currentMode == "pomodoro" ? const Color(0xff38BDF8) : Colors.orangeAccent;
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/bg_study.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.topRight, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.black38), onPressed: () => setState(() => _isFlipClockMode = !_isFlipClockMode), icon: Icon(_isFlipClockMode ? Icons.circle_outlined : Icons.view_carousel_rounded, size: 16, color: circleColor), label: Text(_isFlipClockMode ? "Progress Circle" : "Full Flip Clock", style: const TextStyle(fontSize: 12)))),
                const SizedBox(height: 10), Container(height: 235, alignment: Alignment.center, child: _isFlipClockMode ? _buildFullFlipClockStyle(minStr, secStr) : _buildProgressCircleStyle("$minStr:$secStr", progressPercentage, circleColor)),
                const SizedBox(height: 10), if (!_isFlipClockMode) ...[Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: _isRunning ? _pauseTimer : _startTimer, child: Text(_isRunning ? 'pause' : 'start', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), const SizedBox(width: 14), IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 26), onPressed: _resetTimer), const SizedBox(width: 4), IconButton(icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 24), onPressed: _openTimerSettingsSheet)])]
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProgressCircleStyle(String timeText, double percentage, Color activeCircleColor) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildModeCapsule("pomodoro", _currentStudyMins, _currentMode == "pomodoro"), const SizedBox(width: 8), _buildModeCapsule("short break", _currentBreakMins, _currentMode == "short")]), const SizedBox(height: 15), Container(width: 170, height: 170, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), shape: BoxShape.circle), child: Stack(alignment: Alignment.center, children: [Positioned.fill(child: CustomPaint(painter: TimerCirclePainter(progress: percentage, color: activeCircleColor, baseColor: Colors.white10))), Text(timeText, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1))]))]); }
  Widget _buildModeCapsule(String text, int mins, bool isActive) { return GestureDetector(onTap: () => _switchMode(text.contains('short') ? "short" : "pomodoro", mins), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: isActive ? Colors.white : Colors.black45, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)))); }
  Widget _buildFullFlipClockStyle(String min, String sec) { return GestureDetector(onTap: _isRunning ? _pauseTimer : _startTimer, child: Container(width: double.infinity, height: 200, padding: const EdgeInsets.symmetric(horizontal: 5), child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: _buildFlipCardWidget(min)), Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text(':', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white70))), Expanded(child: _buildFlipCardWidget(sec))]))); }
  Widget _buildFlipCardWidget(String value) { return Container(decoration: BoxDecoration(color: const Color(0xff181622).withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12, width: 1.2), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))]), child: Stack(alignment: Alignment.center, children: [Text(value, style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w900, fontFamily: 'Courier', color: Colors.white)), Column(children: [const Spacer(), Container(height: 3.0, color: Colors.black87), const Spacer()])])); }
}
class TimerCirclePainter extends CustomPainter {
  final double progress; final Color color; final Color baseColor; TimerCirclePainter({required this.progress, required this.color, required this.baseColor});
  @override void paint(Canvas canvas, Size size) { Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 4.5; Paint progressPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4.5..strokeCap = StrokeCap.round; Offset center = Offset(size.width / 2, size.height / 2); double radius = size.width / 2; canvas.drawCircle(center, radius, basePaint); double sweepAngle = 2 * 3.1415926535 * progress; canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926535 / 2, sweepAngle, false, progressPaint); }
  @override bool shouldRepaint(covariant TimerCirclePainter oldDelegate) { return oldDelegate.progress != progress; }
}
void showSystemPermissionDialog(BuildContext context, String assetName) {
  showDialog(context: context, builder: (BuildContext context) { return AlertDialog(backgroundColor: const Color(0xff1F2937), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: const [Icon(Icons.perm_media_rounded, color: Color(0xff38BDF8), size: 22), SizedBox(width: 10), Text('Allow Access?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]), content: Text('Smart Pomodoro requires permission to access device media to upload "$assetName".', style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Deny', style: TextStyle(color: Colors.redAccent))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff38BDF8)), onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Granted for "$assetName"!'), backgroundColor: Colors.green)); }, child: const Text('Allow', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))]); });
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 40, backgroundColor: isLoggedWithGoogle ? const Color(0xff1E3A8A) : const Color(0xff1E293B), child: Icon(isLoggedWithGoogle ? Icons.account_circle : Icons.person, size: 40, color: const Color(0xff38BDF8))), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: [TextButton(onPressed: () { showSystemPermissionDialog(context, "Profile Picture"); }, child: const Text('Upload', style: TextStyle(color: Color(0xff38BDF8)))), const Text('|', style: TextStyle(color: Colors.grey)), TextButton(onPressed: () {}, child: const Text('Reset', style: TextStyle(color: Colors.red)))])])), const VerticalDivider(color: Colors.white24, width: 1), Expanded(flex: 3, child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ListTile(dense: true, leading: const Icon(Icons.person, color: Color(0xff38BDF8), size: 20), title: const Text('Active Username', style: TextStyle(color: Colors.grey, fontSize: 11)), subtitle: Row(children: [Text(globalUsername, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), if (isLoggedWithGoogle) ...[const SizedBox(width: 6), const Icon(Icons.verified, color: Colors.blue, size: 16)]])), ListTile(dense: true, leading: const Icon(Icons.email, color: Color(0xff38BDF8), size: 20), title: const Text('Email Address', style: TextStyle(color: Colors.grey, fontSize: 11)), subtitle: Text(globalEmail, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))), ListTile(dense: true, leading: const Icon(Icons.lock, color: Color(0xff38BDF8), size: 20), title: const Text('Password', style: TextStyle(color: Colors.grey, fontSize: 11)), subtitle: Text(isLoggedWithGoogle ? 'Connected via Google' : '••••••••••••', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))])))]))));
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _muted = false;
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: const [Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(height: 10), Text('Customize settings seamlessly.', style: TextStyle(color: Colors.grey, fontSize: 12))])), const VerticalDivider(color: Colors.white24, width: 1), Expanded(flex: 2, child: SingleChildScrollView(child: Column(children: [_buildSetTile(context, Icons.wallpaper, 'Upload Study Wallpaper'), _buildSetTile(context, Icons.shutter_speed, 'Upload Break Wallpaper'), _buildSetTile(context, Icons.music_note, 'Upload Custom Music'), const Divider(color: Colors.white10), SwitchListTile(dense: true, secondary: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: const Color(0xff38BDF8)), title: const Text('Mute Music', style: TextStyle(fontSize: 14)), value: _muted, activeThumbColor: const Color(0xff38BDF8), onChanged: (val) => setState(() => _muted = val))])))]))));
  }
  Widget _buildSetTile(BuildContext context, IconData icon, String title) { return ListTile(dense: true, leading: Icon(icon, color: const Color(0xff38BDF8), size: 20), title: Text(title, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey), onTap: () { showSystemPermissionDialog(context, title); }); }
}
