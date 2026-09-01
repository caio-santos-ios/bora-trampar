import 'category_model.dart';
import 'service_item_model.dart';
import 'professional_model.dart';

class OrderRequestModel {
  CategoryModel? selectedCategory;
  List<ServiceItemModel> selectedServices;
  String description;
  List<String> photoPaths;
  bool useCurrentLocation;
  String address;
  DateTime? scheduledDate;
  String scheduledTimeSlot;
  String notes;
  ProfessionalModel? selectedProfessional;
  double appFee;

  OrderRequestModel({
    this.selectedCategory,
    List<ServiceItemModel>? selectedServices,
    this.description = '',
    List<String>? photoPaths,
    this.useCurrentLocation = true,
    this.address = 'Alameda dos Nhambiquaras, 111 - Moema, São Paulo - SP',
    this.scheduledDate,
    this.scheduledTimeSlot = 'A partir das 14:00',
    this.notes = '',
    this.selectedProfessional,
    this.appFee = 9.90,
  })  : selectedServices = selectedServices ?? [],
        photoPaths = photoPaths ?? [];

  double get servicePrice => selectedProfessional?.basePrice ?? 150.0;
  double get totalPrice => servicePrice + appFee;

  String get serviceNamesDisplay {
    if (selectedServices.isEmpty) return 'Pedreiro';
    return selectedServices.map((s) => s.name).join(', ');
  }
}
