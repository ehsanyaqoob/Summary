import 'package:trafficlly/app/life_cycle.dart';
import 'package:trafficlly/controllers/auth_controller.dart';
import 'package:trafficlly/controllers/home_animate.dart';
import 'package:trafficlly/controllers/home_cont.dart';
import 'package:trafficlly/utills/export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppLifecycleController());
  Get.put(ChallanController());
  Get.put(AnimationControllerX());
  Get.put(HomeController());
  Get.put(DrivingLicenceController());
  Get.put(LoginController());
  runApp(AppView());
}
