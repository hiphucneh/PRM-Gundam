import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapController extends GetxController {
  final _client = Supabase.instance.client;
  
  var isLoading = false.obs;
  var storeLocation = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStoreLocation();
  }

  Future<void> fetchStoreLocation() async {
    isLoading.value = true;
    storeLocation.value = await getStoreLocation();
    isLoading.value = false;
  }

  Future<Map<String, dynamic>> getStoreLocation() async {
    try {
      final location = await _client
          .from('store_location')
          .select()
          .maybeSingle();

      if (location != null) {
        return {
          'lat': location['latitude'],
          'lng': location['longitude'],
          'address': location['address'],
        };
      }
      
      throw Exception('Location data is null');
      
    } catch (e) {
      // Return fallback coordinates if an error occurs or no rows are returned
      return {
        'lat': 10.762622,
        'lng': 106.660172,
        'address': 'Quận 10, Hồ Chí Minh, Việt Nam',
      };
    }
  }
}