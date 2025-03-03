import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/agency/agency_service.dart';

class AgencyController {
  final AgencyService _agencyService = AgencyService();
  Future<Agency> getAgencyById(String agencyId) async {
    return await _agencyService.fetchAgencyById(agencyId);
  }
}