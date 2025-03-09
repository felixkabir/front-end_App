import 'package:get/get.dart';
import 'package:stivy/models/interest/interests_model.dart';
import 'package:stivy/services/interests/interests_service.dart';

class InterestController extends GetxController {
  final InterestService _interestService = InterestService();
  var interests = <Interest>[].obs;
  var selectedInterest = Rxn<Interest>();

  @override
  void onInit() {
    fetchInterests();
    super.onInit();
  }

  Future<void> fetchInterests() async {
    try {
      var fetchedInterests = await _interestService.fetchInterests();
      interests.assignAll(fetchedInterests);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar interesses');
    }
  }

  void selectInterest(Interest interest) {
    selectedInterest.value = interest;
  }
}