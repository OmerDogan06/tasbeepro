import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../models/zikr.dart';
import '../l10n/app_localizations.dart';

class AddCustomZikrScreen extends StatefulWidget {
  const AddCustomZikrScreen({super.key});

  @override
  State<AddCustomZikrScreen> createState() => _AddCustomZikrScreenState();
}

class _AddCustomZikrScreenState extends State<AddCustomZikrScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _meaningController = TextEditingController();

  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void dispose() {
    _nameController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [lightGold, goldColor],
                center: Alignment(-0.2, -0.2),
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withAlpha(38),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              icon: const Icon(Icons.arrow_back, color: emeraldGreen, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          title: Text(
            AppLocalizations.of(context)?.addCustomZikirTitle ?? 'Özel Zikir Ekle',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFDF7), Color(0xFFF8F6F0)],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightGold, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: goldColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)?.addCustomZikirDescription ?? 'Kendi özel zikirlerinizi oluşturun ve listeye ekleyin',
                            style: const TextStyle(
                              fontSize: 14,
                              color: emeraldGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Zikir Adı
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.addCustomZikirNameLabel ?? 'Zikir Adı',
                        hintText: AppLocalizations.of(context)?.addCustomZikirNameHint ?? 'Örn: Allahu Akbar',
                        prefixIcon: const Icon(Icons.mosque, color: emeraldGreen),
                        labelStyle: const TextStyle(color: emeraldGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: goldColor.withAlpha(77)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: goldColor.withAlpha(77)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: emeraldGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)?.addCustomZikirNameRequired ?? 'Zikir adı gereklidir';
                        }
                        if (value.trim().length < 2) {
                          return AppLocalizations.of(context)?.addCustomZikirNameMinLength ?? 'Zikir adı en az 2 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Anlamı (Opsiyonel)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _meaningController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.addCustomZikirMeaningLabel ?? 'Anlamı (Opsiyonel)',
                        hintText: AppLocalizations.of(context)?.addCustomZikirMeaningHint ?? 'Zikrin anlamını yazabilirsiniz',
                        prefixIcon: const Icon(Icons.description, color: emeraldGreen),
                        labelStyle: const TextStyle(color: emeraldGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: goldColor.withAlpha(77)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: goldColor.withAlpha(77)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: emeraldGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Ekle Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _addCustomZikr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldGreen,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: darkGreen.withAlpha(77),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)?.addCustomZikirButton ?? 'Zikir Ekle',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addCustomZikr() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final meaning = _meaningController.text.trim();

    // Unique ID oluştur
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final customZikr = Zikr(
      id: id,
      name: name,
      meaning: meaning.isEmpty ? null : meaning,
      isCustom: true,
    );

    final controller = Get.find<CounterController>();
    await controller.addCustomZikr(customZikr);

    Get.back();
  }
}