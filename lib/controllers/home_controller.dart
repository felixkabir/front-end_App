import 'package:get/get.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/api_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var agencies = <AgencyModel>[].obs;

  @override
  void onInit() {
    fetchAgencies();
    super.onInit();
  }

  Future<void> fetchAgencies() async {
    try {
      isLoading(true);
      final response = await ApiService.fetchAgencies();
      agencies.assignAll(response);
    } finally {
      isLoading(false);
    }
  }
}