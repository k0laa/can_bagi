import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../services/request_service.dart';
import '../widgets/people_counter.dart';
import '../../home/services/sos_service.dart' show SosResponse;

class CategoryFormScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryFormScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestService = RequestService();

  int _peopleCount = 1;
  final _detailsCtr = TextEditingController();

  // Category specific controllers and state
  final _addressCtr = TextEditingController(); // RESCUE
  final _floorCtr = TextEditingController();   // RESCUE
  
  String _medicalUrgency = 'Normal';           // MEDICAL
  final _injuryTypeCtr = TextEditingController(); // MEDICAL
  
  bool _needsBabyFood = false;                 // FOOD
  
  bool _needsTent = false;                     // SHELTER
  bool _needsBlanket = false;                  // SHELTER
  
  String _ageGroup = 'Yetişkin';               // CLOTHES
  final _sizeCtr = TextEditingController();    // CLOTHES
  
  String _vulnerableType = 'Yaşlı';            // VULNERABLE
  final _specialNeedsCtr = TextEditingController(); // VULNERABLE

  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsCtr.dispose();
    _addressCtr.dispose();
    _floorCtr.dispose();
    _injuryTypeCtr.dispose();
    _sizeCtr.dispose();
    _specialNeedsCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final connProvider = context.read<ConnectionProvider>();
    final locProvider  = context.read<LocationProvider>();
    final authProvider = context.read<AuthProvider>();

    double? lat;
    double? lon;

    // Get location
    if (!locProvider.hasPermission) {
      await locProvider.requestPermission();
    }
    
    if (locProvider.hasPermission) {
      final pos = await locProvider.getCurrentPosition();
      lat = pos?.latitude;
      lon = pos?.longitude;
    }

    if (lat == null || lon == null) {
      if (mounted) {
        AppToast.show(context, 'Konum alınamadı. Talep konumsuz gönderiliyor.', type: AppToastType.warning);
      }
    }

    // Kategori-özel ek bilgileri details metnine ekle
    // (Backend /needs/ şeması ekstra alanları kabul etmiyor)
    final extras = <String>[];
    final baseDetails = _detailsCtr.text.trim();
    if (baseDetails.isNotEmpty) extras.add(baseDetails);

    switch (widget.categoryId) {
      case 'RESCUE':
        final addr = _addressCtr.text.trim();
        final floor = _floorCtr.text.trim();
        if (addr.isNotEmpty) extras.add('Adres: $addr');
        if (floor.isNotEmpty) extras.add('Kat: $floor');
        break;
      case 'MEDICAL':
        extras.add('Aciliyet: $_medicalUrgency');
        final inj = _injuryTypeCtr.text.trim();
        if (inj.isNotEmpty) extras.add('Yaralanma: $inj');
        break;
      case 'FOOD':
        if (_needsBabyFood) extras.add('Bebek maması gerekli');
        break;
      case 'SHELTER':
        if (_needsTent) extras.add('Çadır gerekli');
        if (_needsBlanket) extras.add('Battaniye gerekli');
        break;
      case 'CLOTHES':
        extras.add('Yaş grubu: $_ageGroup');
        final size = _sizeCtr.text.trim();
        if (size.isNotEmpty) extras.add('Beden: $size');
        break;
      case 'VULNERABLE':
        extras.add('Tür: $_vulnerableType');
        final sn = _specialNeedsCtr.text.trim();
        if (sn.isNotEmpty) extras.add('Özel ihtiyaç: $sn');
        break;
    }

    // Backend şeması: { node_id?, category, lat?, lon?, people_count?, details? }
    final payload = <String, dynamic>{
      'node_id': 'MOBILE',
      'category': widget.categoryId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      'people_count': _peopleCount,
      if (extras.isNotEmpty) 'details': extras.join(' | '),
    };

    try {
      final response = await _requestService.sendRequest(
        connectionType: connProvider.type,
        token: authProvider.token,
        payload: payload,
      );

      if (mounted) {
        // Reuse SosResponse structure for ConfirmationScreen compatibility
        // ConfirmationScreen takes a SosResponse, but we can pass a mock SosResponse 
        // to it or update ConfirmationScreen to be more generic. 
        // Given Phase 4 requirement: "Faz 2'deki ConfirmationScreen aynı şekilde kullanılır 
        // Sadece ikon rengi farklı" - we'll adapt ConfirmationScreen slightly later, 
        // but for now let's pass a compatible object or update AppRouter.
        
        final sosResp = SosResponse(
          status: response.status,
          id: response.id,
          message: response.message,
          receivedAt: response.receivedAt,
        );
        
        // Pass category as extra state for color differentiation
        context.go('/confirmation', extra: {'response': sosResp, 'category': widget.categoryId});
      }
    } catch (e) {
      if (mounted) {
        context.go('/sos-error', extra: Exception(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildCategorySpecificFields() {
    switch (widget.categoryId) {
      case 'RESCUE':
        return Column(
          children: [
            AppTextField(
              label: 'Enkaz Adresi',
              hint: 'Mahalle, Sokak, No',
              controller: _addressCtr,
              validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Yaklaşık Kat/Konum',
              hint: 'Örn: 2. kat, merdiven altı',
              controller: _floorCtr,
            ),
          ],
        );
      case 'MEDICAL':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aciliyet', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('🔴 Acil', style: AppTextStyles.body),
                    value: 'Acil',
                    groupValue: _medicalUrgency,
                    onChanged: (v) => setState(() => _medicalUrgency = v!),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.danger,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('🟡 Normal', style: AppTextStyles.body),
                    value: 'Normal',
                    groupValue: _medicalUrgency,
                    onChanged: (v) => setState(() => _medicalUrgency = v!),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Yaralanma Türü',
              hint: 'Kırık, kanama vb. (opsiyonel)',
              controller: _injuryTypeCtr,
            ),
          ],
        );
      case 'FOOD':
        return CheckboxListTile(
          title: Text('Bebek Maması Gerekiyor mu?', style: AppTextStyles.body),
          value: _needsBabyFood,
          onChanged: (v) => setState(() => _needsBabyFood = v ?? false),
          activeColor: AppColors.accent,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      case 'SHELTER':
        return Column(
          children: [
            CheckboxListTile(
              title: Text('Çadır Gerekiyor mu?', style: AppTextStyles.body),
              value: _needsTent,
              onChanged: (v) => setState(() => _needsTent = v ?? false),
              activeColor: AppColors.accent,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text('Battaniye Gerekiyor mu?', style: AppTextStyles.body),
              value: _needsBlanket,
              onChanged: (v) => setState(() => _needsBlanket = v ?? false),
              activeColor: AppColors.accent,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        );
      case 'CLOTHES':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yaş Grubu', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textDisabled),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _ageGroup,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.textPrimary),
                  items: ['Bebek', 'Çocuk', 'Yetişkin', 'Yaşlı']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _ageGroup = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Beden',
              hint: 'S, M, L, XL vb. (opsiyonel)',
              controller: _sizeCtr,
            ),
          ],
        );
      case 'VULNERABLE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tür', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textDisabled),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _vulnerableType,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.textPrimary),
                  items: ['Yaşlı', 'Engelli', 'Hamile', 'Bebek']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _vulnerableType = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Özel İhtiyaç',
              hint: 'Tekerlekli sandalye vb. (opsiyonel)',
              controller: _specialNeedsCtr,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('${widget.categoryTitle} TALEBİ', style: AppTextStyles.cardTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: AppColors.accent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Konumunuz talebinizle birlikte otomatik olarak gönderilecektir.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                PeopleCounter(
                  value: _peopleCount,
                  onChanged: (val) => setState(() => _peopleCount = val),
                  min: 1,
                  max: 50,
                ),
                const SizedBox(height: 16),
                
                _buildCategorySpecificFields(),
                const SizedBox(height: 16),
                
                // Textarea for details
                const Text('Detay (Opsiyonel)', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _detailsCtr,
                  maxLength: 200,
                  maxLines: 4,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Eklemek istediğiniz diğer detaylar...',
                    hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 15, color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.textDisabled, width: 1)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                AppButton(
                  label: 'TALEP GÖNDER',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
