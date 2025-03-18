import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/faculty_dashboard.dart';

class FacultyLoginScreen extends StatefulWidget {
  @override
  _FacultyLoginScreenState createState() => _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hardcoded list of faculty email IDs
  final List<String> facultyEmails = [
    "debasishmishra@giet.edu",
    "anotherfaculty@giet.edu",
    "debasishmishra9876@gmail.com"
        "abhishekpradhan@giet.edu",
    "ajitpatro@giet.edu",
    "ajits@giet.edu",
    "aksamal@giet.edu",
    "akshyasahoo@giet.edu",
    "amiparida@giet.edu",
    "amlanasutosh@giet.edu",
    "anmolgiri@giet.edu",
    "anmolpanda@giet.edu",
    "aparnababoo@giet.edu",
    "aparnayerra@giet.edu",
    "archanapatnaik@giet.edu",
    "arpansingh@giet.edu",
    "ashimasindhumohanty@giet.edu",
    "ashishtiwary@giet.edu",
    "asishkumarpatnaik@giet.edu",
    "asreelakshmi@giet.edu",
    "aurobindopanda@giet.edu",
    "avspavankumar@giet.edu",
    "balakirshnasriram@giet.edu",
    "balaramdas@giet.edu",
    "bandanamallick@giet.edu",
    "banilkumar@giet.edu",
    "baninayak@giet.edu",
    "barshadas@giet.edu",
    "barunakumarturuk@giet.edu",
    "basantapalai@giet.edu",
    "bhavanipanda@giet.edu",
    "bibhuprasad@giet.edu",
    "bidisharath@giet.edu",
    "bidushsahoo@giet.edu",
    "bighneshpattnaik@giet.edu",
    "bilasiniajmera@giet.edu",
    "binodinikar@giet.edu",
    "biplabkr@giet.edu",
    "biswajit@giet.edu",
    "biswamohanpanda@giet.edu",
    "brabiprasad@giet.edu",
    "bvikram@giet.edu",
    "chandramohanrakoti@giet.edu",
    "chinmayaranjanswain@giet.edu",
    "chiranjibi@giet.edu",
    "coe@giet.edu",
    "danil@giet.edu",
    "deanacademics@giet.edu",
    "debasishpradhan@giet.edu",
    "debasishsahoo@giet.edu",
    "debasishmishra@giet.edu",
    "debasmitadas@giet.edu",
    "debottombose@giet.edu",
    "deepakkumar@giet.edu",
    "deeptimayeechoudhury@giet.edu",
    "devmohapatro@giet.edu",
    "dkacharya@giet.edu",
    "dr.neelamadhab@giet.edu",
    "drkailashmohapatraag@giet.edu",
    "dumeshmeher@giet.edu",
    "furtifiza@giet.edu",
    "gayatriranipanda@giet.edu",
    "gdeepika@giet.edu",
    "geetanjalipanda@giet.edu",
    "geetanjalipatra@giet.edu",
    "girijasankarpradhan@giet.edu",
    "gitanjali@giet.edu",
    "gk@giet.edu",
    "gmohanty@giet.edu",
    "golmei@giet.edu",
    "grkdsp@giet.edu",
    "gvsnarayana@giet.edu",
    "harekrushnabehera@giet.edu",
    "harisankar@giet.edu",
    "himansubarik@giet.edu",
    "ijraghavendra@giet.edu",
    "jagadishsahoo@giet.edu",
    "jaganathapatro@giet.edu",
    "jayantidang@giet.edu",
    "jemarani253@giet.edu",
    "jharanamaharana@giet.edu",
    "jitendrakumar@giet.edu",
    "jksahoo@giet.edu",
    "juhirath@giet.edu",
    "jyoshana@giet.edu",
    "jyoti@giet.edu",
    "jyotimayeebagarti@giet.edu",
    "jyotirekhapanda@giet.edu",
    "kalyanipraharaj@giet.edu",
    "kedarnathpanda@giet.edu",
    "kheyalighosh@giet.edu",
    "kiransahu@giet.edu",
    "kjayashree@giet.edu",
    "kmgopal@giet.edu",
    "kratankumar@giet.edu",
    "krath@giet.edu",
    "ksivakrishna@giet.edu",
    "kyjyothi@giet.edu",
    "laxmipriya@giet.edu",
    "lipsamishra@giet.edu",
    "lokeswar@giet.edu",
    "madhurimishra@giet.edu",
    "madhusudan@giet.edu",
    "maheshdakua@giet.edu",
    "mamatabehera@giet.edu",
    "manaspanda@giet.edu",
    "manasranjan@giet.edu",
    "manaswininagabansa@giet.edu",
    "manjushreenayak@giet.edu",
    "manojadas@giet.edu",
    "manojkumarpanda@giet.edu",
    "manojnagarampalli@giet.edu",
    "mitameher@giet.edu",
    "mkarteek@giet.edu",
    "muralisenapaty@giet.edu",
    "nalinikanta@giet.edu",
    "narendrapanda@giet.edu",
    "nbhatra@giet.edu",
    "niharikadream@giet.edu",
    "nilambar@giet.edu",
    "nirmalapatel@giet.edu",
    "nirupamadora@giet.edu",
    "nishithdas@giet.edu",
    "njagannadham@giet.edu",
    "padminimishra@giet.edu",
    "pallabimahapatra@giet.edu",
    "pkpanigrahi@giet.edu",
    "pnmurty@giet.edu",
    "prahalladsahu@giet.edu",
    "pramesh@giet.edu",
    "pramodranjanpanda@giet.edu",
    "pranatisahu@giet.edu",
    "prateek@giet.edu",
    "pratikshyapadhi@giet.edu",
    "prativakar@giet.edu",
    "premansusekhararath@giet.edu",
    "priyadarsanparida@giet.edu",
    "priyankapanja@giet.edu",
    "priyankapatro@giet.edu",
    "profvmrao@giet.edu",
    "prustyghanishta@giet.edu",
    "rabindramishra@giet.edu",
    "radhakrushnapadhi@giet.edu",
    "radhanathpatra@giet.edu",
    "raghvendra@giet.edu",
    "raghvendrasahu@giet.edu",
    "rajababu@giet.edu",
    "rajendramahanta@giet.edu",
    "rajeswaridas@giet.edu",
    "rakeshsahu@giet.edu",
    "ranjeetpanigrahi@giet.edu",
    "ranjitarout@giet.edu",
    "ranjitpatnaik@giet.edu",
    "rasmita@giet.edu",
    "rasmitagantayet@giet.edu",
    "ravigupta@giet.edu",
    "ribhuabhusanpanda@giet.edu",
    "rinnyswain@giet.edu",
    "sachikanta@giet.edu",
    "sahupriyanka@giet.edu",
    "saikrishnaar@giet.edu",
    "saisharanpurohit@giet.edu",
    "samirpanigrahi@giet.edu",
    "samrat@giet.edu",
    "sandeepjena@giet.edu",
    "sandhyaranibiswal@giet.edu",
    "sandhyaranidash@giet.edu",
    "sandhyaraniswain@giet.edu",
    "sanjanatripathy@giet.edu",
    "sankarpatra@giet.edu",
    "santoshpanda@giet.edu",
    "saranpanda@giet.edu",
    "sarmisthasahoo@giet.edu",
    "sarojbehera@giet.edu",
    "sasankpanda@giet.edu",
    "sathyat@giet.edu",
    "saumendra@giet.edu",
    "shantilaxmi@giet.edu",
    "shibani.tripathy@giet.edu",
    "shibanisubhadarshini@giet.edu",
    "shrutikolur@giet.edu",
    "sibofromgiet@giet.edu",
    "siddharthsahu@giet.edu",
    "sidhantkumarsahu@giet.edu",
    "sitanshukar@giet.edu",
    "skbindhani@giet.edu",
    "sktripathy@giet.edu",
    "smrutirekhasahoo@giet.edu",
    "sndas@giet.edu",
    "soumyaranjan@giet.edu",
    "spkhadanga@giet.edu",
    "sreekeshavgojja@giet.edu",
    "sridharpalo@giet.edu",
    "srikantm@giet.edu",
    "srutiprangya@giet.edu",
    "ssatapathy@giet.edu",
    "subhasish@giet.edu",
    "sucharitapanda@giet.edu",
    "suchetakrupalini@giet.edu",
    "sudheerpunuri@giet.edu",
    "sujit@giet.edu",
    "sukantanayak@giet.edu",
    "sumanabalo@giet.edu",
    "sumanmishra@giet.edu",
    "sumansahu@giet.edu",
    "supriyasatapathy@giet.edu",
    "surabhikapanda@giet.edu",
    "suryakalaadhikari@giet.edu",
    "susantakumarmohanty@giet.edu",
    "susantapadhy@giet.edu",
    "swapnamayee@giet.edu",
    "swarnapravarout@giet.edu",
    "swastikbehera@giet.edu",
    "swatigoudo@giet.edu",
    "tadipriyanka@giet.edu",
    "tanmayabehera@giet.edu"
  ];

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && facultyEmails.contains(user.email)) {
        String facultyName = user.email!.split('@')[0];
        String profileImageUrl = user.photoURL ?? "";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email!);
        await prefs.setString('role', 'faculty');
        await prefs.setString('facultyName', facultyName);
        await prefs.setString('profileImage', profileImageUrl);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FacultyDashboard()),
        );
      } else {
        await GoogleSignIn().signOut();
        _showError("Access denied. You are not a registered faculty.");
      }
    } catch (e) {
      _showError("Login failed: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/back3.jpeg', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          // Login Form
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 350,
              child: ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text("Do Faculty Log IN"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
