import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/request_model.dart';
import '../logic/requests_cubit.dart';
import '../../chat/data/chat_client.dart';
import '../../chat/presentation/chat_details_view.dart';
import '../logic/requests_state.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../core/utils/app_text_styles.dart';
import 'package:lottie/lottie.dart';

class RequestDetailsPage extends StatelessWidget {
  /// Firestore document ID — guaranteed unique, used for exact lookup.
  final String docId;
  /// Firestore collection name — needed together with docId for uniqueness.
  final String collection;
  final String name;

  const RequestDetailsPage({
    super.key,
    required this.docId,
    required this.collection,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تفاصيل الطلب',
            style: AppTextStyles.readexSemiBold20.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: const SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<RequestsCubit, RequestsState>(
          builder: (context, state) {
            if (state is RequestsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A4499)),
              );
            }

            if (state is RequestsError) {
              return Center(
                child: Text(
                  'حدث خطأ: ${state.message}',
                  style: AppTextStyles.readexMedium14.copyWith(color: Colors.red),
                ),
              );
            }

            if (state is RequestsLoaded) {
              // Exact lookup by Firestore docId + collection — unambiguous across all collections.
              final model = state.allRequests.cast<RequestModel?>().firstWhere(
                (r) => r!.id == docId && r.collection == collection,
                orElse: () => null,
              );

              if (model == null) {
                return Center(
                  child: Text(
                    'لم يتم العثور على بيانات الطلب',
                    style: AppTextStyles.readexMedium14.copyWith(color: Colors.grey),
                  ),
                );
              }

              // Single call — all normalization already done in RequestModel
              final view = model.toViewMap();

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          RequestDetailsStepper(model: model),
                          const SizedBox(height: 24),
                          _buildClientCard(view),
                          const SizedBox(height: 16),
                          _buildPersonalDataTile(context, view),
                          const SizedBox(height: 16),
                          _buildFinancingInfoTile(context, view),
                          const SizedBox(height: 16),
                          _buildFinancialDataTile(context, view),
                          const SizedBox(height: 16),
                          _buildEmploymentInfoTile(context, view),
                          const SizedBox(height: 16),
                          _buildCurrentObligationsTile(context, view),
                          const SizedBox(height: 16),
                          _buildOtherDataTile(context, view),
                          const SizedBox(height: 16),
                          _buildAttachmentsTile(context, view),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActionBar(context, model, docId),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // _buildStepper and helper methods have been moved to RequestDetailsStepper below

  Widget _buildClientCard(Map<String, dynamic> data) {
    Color statusBgColor = const Color(0xFFFFF4E5);
    Color statusTextColor = const Color(0xFFFFB03A);
    final status = data['status'] ?? '';
    String statusArabic = status;
    
    if (status == 'approved' || status == 'eligibility_approved' || status == 'request_approved' || status == 'transfer_approved' || status == 'مقبول' || status == 'موافق عليه' || status == 'مكتملة' || status == 'مكتمل') {
      statusBgColor = const Color(0xFFE8FAF0);
      statusTextColor = const Color(0xFF2ECA7D);
      statusArabic = 'مقبول';
    } else if (status == 'not approved' || status == 'مرفوض') {
      statusBgColor = const Color(0xFFFEECEB);
      statusTextColor = const Color(0xFFF44336);
      statusArabic = 'مرفوض';
    } else if (status == 'تقديم طلب' || status == 'تقديم الطلب' || status == 'request_pending' || status == 'request_pendding') {
      statusBgColor = const Color(0xFFE8EAF6);
      statusTextColor = const Color(0xFF3F51B5);
      statusArabic = 'تقديم الطلب';
    } else if (status == 'انتظار تسليم المبلغ' || status == 'transfer_pending') {
      statusBgColor = const Color(0xFFE0F7FA);
      statusTextColor = const Color(0xFF00838F);
      statusArabic = 'انتظار تسليم المبلغ';
    } else {
      statusBgColor = const Color(0xFFFFF4E5);
      statusTextColor = const Color(0xFFFFB03A);
      statusArabic = 'جاري المراجعة';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'غير معروف',
                      style: AppTextStyles.readexSemiBold16.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['job'] ?? '',
                      style: AppTextStyles.readexRegular14.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusArabic,
                        style: AppTextStyles.readexMedium12.copyWith(
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ التقديم',
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['date'] ?? '',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مبلغ القرض المطلوب',
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['amount'] ?? '',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: const Color(0xFF2A2375),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Financing Information ExpansionTile
  Widget _buildFinancingInfoTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'معلومات التمويل',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'مبلغ المطلوب',
                      value: data['amount'] ?? '',
                      valueColor: const Color(0xFF2A2375),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'مدة القرض',
                      value: data['duration'] ?? '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Financial Data ExpansionTile
  Widget _buildFinancialDataTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'البيانات المالية',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'الدخل الشهري',
                          value: data['monthlyIncome'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'مصدر الدخل',
                          value: data['incomeSource'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'الالتزامات البنكية',
                          value: data['bankObligations'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'رقم حساب بنكي',
                          value: data['iban'] ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Employment Information ExpansionTile
  Widget _buildEmploymentInfoTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.work, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'معلومات التوظيف',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'نوع الوظيفة',
                          value: data['jobType'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'المرتب الصافي',
                          value: data['netSalary'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'تاريخ اخر راتب اخذته',
                          value: data['lastSalaryDate'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'تاريخ الانضمام الي جهة العمل الحالية',
                          value: data['joiningDate'] ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Current Obligations ExpansionTile
  Widget _buildCurrentObligationsTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.assignment, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'الالتزامات الحالية',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'الالتزامات البنكية',
                          value: data['hasBankObligations'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'قيمة قسط القرض الحالي',
                          value: data['currentLoanInstallment'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'الاشهر المتبقية',
                          value: data['remainingMonths'] ?? '',
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Other Data ExpansionTile
  Widget _buildOtherDataTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'بيانات اخرى',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'العنوان الوظيفي',
                          value: data['jobTitle'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'السلعة',
                          value: data['commodity'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'إيقاف الخدمات',
                          value: data['serviceStop'] ?? '',
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Attachments & Documents ExpansionTile
  Widget _buildAttachmentsTile(BuildContext context, Map<String, dynamic> data) {
    // Support both legacy `attachments` list and new `images` map from FinancingRequests
    // Firestore may return nested maps as Map<dynamic,dynamic> so cast carefully
    Map<String, dynamic> images = {};
    final rawImages = data['images'];
    if (rawImages is Map) {
      images = rawImages.map((k, v) => MapEntry(k.toString(), v));
    }

    final attachmentsList = data['attachments'] as List<dynamic>? ?? [];

    // Build a unified list from images map
    final imageLabels = <String, String>{
      'idFront':       'صورة بطاقة الهوية (أمامية)',
      'idBack':        'صورة بطاقة الهوية (خلفية)',
      'bankAccount':   'كشف الحساب البنكي',
      'proofOfIncome': 'إثبات الدخل / مفردات المرتب',
      'salarySlip':    'قسيمة الراتب',
    };
    final imageItems = images.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => MapEntry(imageLabels[e.key] ?? e.key, e.value.toString()))
        .toList();

    final hasContent = imageItems.isNotEmpty || attachmentsList.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.folder, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'المرفقات والمستندات',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              if (hasContent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4499),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${imageItems.length + attachmentsList.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'ReadexPro'),
                  ),
                ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!hasContent)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'لا توجد مرفقات مرفوعة',
                        style: AppTextStyles.readexRegular12.copyWith(color: Colors.grey),
                      ),
                    ),
                  // Image URL attachments from FinancingRequests
                  ...imageItems.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildImageAttachmentItem(context: context, title: e.key, url: e.value),
                  )),
                  // Legacy list-style attachments
                  ...attachmentsList.map((item) {
                    final att = item as Map<dynamic, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildAttachmentItem(
                        title: att['title'] ?? '',
                        meta:  att['meta']  ?? '',
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem({required String title, required String meta}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFF2ECA7D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.readexMedium14.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: AppTextStyles.readexRegular12.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A4499),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              'فتح',
              style: AppTextStyles.readexMedium12.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders an image URL attachment (from the `images` map in FinancingRequests)
  Widget _buildImageAttachmentItem({
    required BuildContext context,
    required String title,
    required String url,
  }) {
    void openFullscreen() {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black,
          pageBuilder: (_, __, ___) => _FullscreenImagePage(url: url, title: title),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }

    return GestureDetector(
      onTap: openFullscreen,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Hero(
                    tag: url,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8FAF0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF2ECA7D), size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: openFullscreen,
              icon: const Icon(Icons.open_in_full, size: 14),
              label: Text('فتح', style: AppTextStyles.readexMedium12.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4499),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Personal Data ExpansionTile Implementation
  Widget _buildPersonalDataTile(BuildContext context, Map<String, dynamic> data) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f0fa),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Row(
            children: [
              const Icon(Icons.person, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Text(
                'البيانات الشخصية',
                style: AppTextStyles.readexSemiBold14.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'اسم العميل',
                          value: data['name'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'البريد الالكتروني',
                          value: data['email'] ?? '',
                          canCopy: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'رقم الهاتف',
                          value: data['phone'] ?? '',
                          canCopy: true,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'رقم الهوية',
                          value: data['identityNumber'] ?? data['nationalId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'الجنسية',
                          value: data['nationality'] ?? '',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'تاريخ الميلاد',
                          value: data['birthdate'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          label: 'عدد المعالين',
                          value: data['dependents'] ?? '',
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String label,
    required String value,
    bool canCopy = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.readexRegular12.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (canCopy) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تم نسخ: $value',
                              style: const TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF2A2375),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Icon(Icons.copy, size: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 2),
            ],
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.readexMedium14.copyWith(
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool?> _showCreativeConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Color primaryColor,
    required IconData icon,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.readexSemiBold20.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.readexRegular14.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.readexMedium14.copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: AppTextStyles.readexMedium14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessLottieOverlay(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/Success tick.json',
                height: 180,
                repeat: false,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'تم قبول الطلب بنجاح!',
                style: AppTextStyles.readexSemiBold20.copyWith(
                  color: const Color(0xFF2ECA7D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'انتقل الطلب إلى مرحلة: $newStatus',
                textAlign: TextAlign.center,
                style: AppTextStyles.readexRegular14.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    RequestModel model,
    String normalizedId,
  ) {
    final status = model.status.trim();
    final isApproved = status == 'approved' || status == 'eligibility_approved' || status == 'request_approved' || status == 'transfer_approved' || status == 'مقبول' || status == 'موافق عليه' || status == 'مكتملة' || status == 'مكتمل';
    final isRejected = status == 'not approved' || status == 'مرفوض';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat Button
            GestureDetector(
              onTap: () {
                final clientId = model.raw['userId'] ?? 'CUSTOMER-001';
                final clientName = model.name;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsView(
                      client: ChatClient(id: clientId, name: clientName),
                    ),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF2A2375),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (isApproved)
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAF0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFEFDB)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تم قبول الطلب',
                        style: AppTextStyles.readexMedium16.copyWith(
                          color: const Color(0xFF2ECA7D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Color(0xFF2ECA7D), size: 20),
                    ],
                  ),
                ),
              )
            else if (isRejected)
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEECEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD5D2)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تم رفض الطلب',
                        style: AppTextStyles.readexMedium16.copyWith(
                          color: const Color(0xFFF44336),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.cancel, color: Color(0xFFF44336), size: 20),
                    ],
                  ),
                ),
              )
            else ...[
              // Reject Button
              GestureDetector(
                onTap: () async {
                  final cubit = context.read<RequestsCubit>();
                  final confirm = await _showCreativeConfirmDialog(
                    context: context,
                    title: 'رفض وإلغاء الطلب',
                    message: 'هل أنت متأكد من رفض وحذف هذا الطلب نهائياً؟ سيتم إخطار العميل فوراً بالقرار.',
                    primaryColor: const Color(0xFFFF4B4B),
                    icon: Icons.delete_forever,
                    confirmText: 'نعم، رفض وحذف',
                  );

                  if (confirm == true) {
                    await cubit.rejectRequest(model);

                    final service = FirebaseMessagingService();
                    await service.sendRefuseNotification(
                      clientId: model.raw['clientId'] ?? 'default_client',
                      requestId: model.requestId,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم رفض وحذف الطلب بنجاح وإرسال إشعار للعميل'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFFF4B4B)),
                ),
              ),
              const SizedBox(width: 12),
              // Accept Button
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final cubit = context.read<RequestsCubit>();
                    final nextStep = model.currentStep < 4 ? model.currentStep + 1 : 4;
                    final newStatus = {2: 'تقديم طلب', 3: 'انتظار تسليم المبلغ', 4: 'مكتملة'}[nextStep] ?? '';

                    final confirm = await _showCreativeConfirmDialog(
                      context: context,
                      title: 'قبول وتمرير الطلب',
                      message: 'هل أنت متأكد من الموافقة على الطلب وتمريره إلى خطوة "$newStatus"؟',
                      primaryColor: const Color(0xFF4A4499),
                      icon: Icons.verified_user,
                      confirmText: 'نعم، قبول الطلب',
                    );

                    if (confirm == true) {
                      await cubit.acceptRequest(model);

                      final service = FirebaseMessagingService();
                      await service.sendAcceptNotification(
                        clientId: model.raw['clientId'] ?? 'default_client',
                        requestId: model.requestId,
                        currentStep: model.currentStep,
                      );

                      if (context.mounted) {
                        _showSuccessLottieOverlay(context, newStatus);
                      }
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4499),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'قبول الطلب',
                          style: AppTextStyles.readexMedium16.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class RequestDetailsStepper extends StatefulWidget {
  final RequestModel model;

  const RequestDetailsStepper({super.key, required this.model});

  @override
  State<RequestDetailsStepper> createState() => _RequestDetailsStepperState();
}

class _RequestDetailsStepperState extends State<RequestDetailsStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<String> _stepTitles = [
    'جاري المراجعة',
    'تقديم طلب',
    'انتظار تسليم المبلغ',
    'مكتملة',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns true if [stepNumber] has already been approved (request moved past it).
  bool _isApproved(int stepNumber) {
    final status = widget.model.status;
    final cs = widget.model.currentStep;
    if (stepNumber < cs) return true;
    switch (stepNumber) {
      case 1:
        return status == 'eligibility_approved' ||
            status == 'request_pending' ||
            status == 'request_pendding' ||
            status == 'request_approved' ||
            status == 'transfer_pending' ||
            status == 'transfer_approved' ||
            status == 'approved';
      case 2:
        return status == 'request_approved' ||
            status == 'transfer_pending' ||
            status == 'transfer_approved' ||
            status == 'approved';
      case 3:
        return status == 'transfer_approved' || status == 'approved';
      default:
        return status == 'approved';
    }
  }

  void _openStepSheet(BuildContext ctx, int index) {
    final stepNumber = index + 1;
    final model = widget.model;
    final isCompleted = model.currentStep >= stepNumber;
    final isApproved = _isApproved(stepNumber);
    final cubit = ctx.read<RequestsCubit>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StepDetailSheet(
        stepNumber: stepNumber,
        model: model,
        isCompleted: isCompleted,
        isApproved: isApproved,
        cubit: cubit,
        parentContext: ctx,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.model.currentStep;
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _stepTitles.length; i++) ...[
              _buildStepItem(
                context: ctx,
                index: i,
                title: _stepTitles[i],
                number: '${i + 1}',
                isActive: currentStep >= (i + 1),
              ),
              if (i < _stepTitles.length - 1)
                _buildConnector(isActive: currentStep >= (i + 2)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required int index,
    required String title,
    required String number,
    required bool isActive,
  }) {
    final phaseOffset = index / 4.0;
    final angle = 2 * 3.14159 * (_controller.value - phaseOffset);
    final yOffset = -8.0 * math.sin(angle);
    final bgColor = isActive ? const Color(0xFF2A2375) : const Color(0xFFF4F5F7);
    final numCol = isActive ? Colors.white : const Color(0xFF2A2375);

    return Expanded(
      child: GestureDetector(
        onTap: () => _openStepSheet(context, index),
        child: Column(
          children: [
            Transform.translate(
              offset: Offset(0, yOffset),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color(0x332A2375)
                          : const Color(0x12000000),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: AppTextStyles.readexSemiBold16.copyWith(color: numCol),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: AppTextStyles.readexMedium12.copyWith(
                  color: isActive ? const Color(0xFF2A2375) : Colors.grey.shade500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Container(
      width: 20,
      height: 3,
      margin: const EdgeInsets.only(bottom: 28),
      color: isActive ? const Color(0xFF2A2375) : const Color(0xFFE0E2EC),
    );
  }
}

// ── Step Detail Bottom Sheet ───────────────────────────────────────────────────

class _StepDetailSheet extends StatelessWidget {
  final int stepNumber;
  final RequestModel model;
  final bool isCompleted;
  final bool isApproved;
  final RequestsCubit cubit;
  final BuildContext parentContext;

  const _StepDetailSheet({
    required this.stepNumber,
    required this.model,
    required this.isCompleted,
    required this.isApproved,
    required this.cubit,
    required this.parentContext,
  });

  static const _stepColors = [
    Color(0xFF7C6DFA),
    Color(0xFF3F51B5),
    Color(0xFF00838F),
    Color(0xFF2ECA7D),
  ];
  static const _stepTitles = [
    'جاري المراجعة',
    'تقديم الطلب',
    'انتظار تسليم المبلغ',
    'مكتملة',
  ];
  static const _stepIcons = [
    Icons.search,
    Icons.receipt_long,
    Icons.account_balance_wallet,
    Icons.check_circle_outline,
  ];

  Color get _color => _stepColors[stepNumber - 1];
  String get _title => _stepTitles[stepNumber - 1];
  IconData get _icon => _stepIcons[stepNumber - 1];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: stepNumber == 3 ? 0.92 : 0.76,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: _buildHeader(),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: _buildContent(context),
                ),
              ),
              // Step-3 action buttons
              if (stepNumber == 3 && isCompleted && !isApproved)
                _buildStep3Actions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final label = isApproved ? 'تمت الموافقة' : (isCompleted ? 'قيد المراجعة' : 'لم تبدأ');
    final badge = isApproved
        ? Icons.check_circle
        : (isCompleted ? Icons.schedule : Icons.lock_outline);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color, _color.withOpacity(0.7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الخطوة $stepNumber',
                    style: const TextStyle(
                        fontFamily: 'ReadexPro', fontSize: 12, color: Colors.white70)),
                Text(_title,
                    style: const TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Content dispatcher ──────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context) {
    if (!isCompleted) return _buildLockedState();
    switch (stepNumber) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildDoneState();
    }
  }

  // ─── Locked / done states ─────────────────────────────────────────────────────

  Widget _buildLockedState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: _cardDecor(),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.lock_outline, size: 36, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text('هذه الخطوة لم تبدأ بعد',
              style: TextStyle(
                  fontFamily: 'ReadexPro', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('ستُفتح بعد إكمال الخطوات السابقة والموافقة عليها',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'ReadexPro', fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildDoneState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAF0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFEFDB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2ECA7D), size: 64),
          SizedBox(height: 16),
          Text('تم إكمال الطلب بنجاح! 🎉',
              style: TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2ECA7D))),
          SizedBox(height: 8),
          Text('تمت معالجة جميع خطوات الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'ReadexPro', fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  // ─── Step 1 ───────────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    final data = model.step1DisplayData;
    final personalKeys  = {'الاسم الكامل','البريد الإلكتروني','رقم الجوال','رقم الهوية','الجنسية','تاريخ الميلاد','عدد المعالين'};
    final jobKeys       = {'نوع الوظيفة','الراتب الصافي','تاريخ آخر راتب','تاريخ الانضمام للعمل'};
    final loanKeys      = {'مبلغ القرض المطلوب','مدة القرض','يوجد قروض حالية','قسط القرض الحالي','الأشهر المتبقية'};

    List<MapEntry<String,String>> pick(Set<String> keys) =>
        data.entries.where((e) => keys.contains(e.key)).toList();

    return Column(
      children: [
        _sectionCard('البيانات الشخصية',   Icons.person_outline,     const Color(0xFF7C6DFA), pick(personalKeys)),
        const SizedBox(height: 14),
        _sectionCard('بيانات التوظيف',      Icons.work_outline,       const Color(0xFF4A4499), pick(jobKeys)),
        const SizedBox(height: 14),
        _sectionCard('بيانات القرض',        Icons.account_balance,    const Color(0xFF2A2375), pick(loanKeys)),
        if (model.images.isNotEmpty) ...[
          const SizedBox(height: 14),
          _attachmentsCard(model.images),
        ],
      ],
    );
  }

  // ─── Step 2 ───────────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    final step2Data = model.step2DisplayData;
    final step2Images = model.step2Images;

    if (step2Data.isEmpty && step2Images.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: _cardDecor(),
        child: Column(
          children: [
            Icon(Icons.hourglass_empty, size: 52, color: Colors.amber.shade300),
            const SizedBox(height: 16),
            const Text('لم يقدّم العميل بيانات الخطوة الثانية بعد',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'ReadexPro', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Text('سيتمكن من التقديم بعد الموافقة على الخطوة الأولى',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'ReadexPro', fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    // Group 1: Loan & Financial Data
    final financialKeys = {
      'الاسم الأول',
      'الاسم الأخير',
      'المدينة',
      'السلعة المختارة',
      'مبلغ التمويل',
      'مصدر الدخل',
      'الجنسية',
      'الدخل الشهري',
      'الالتزامات البنكية',
    };

    // Group 2: Account & Address Data
    final addressKeys = {
      'رقم الحساب البنكي (IBAN)',
      'إيقاف خدمات',
      'العنوان الوطني (الرئيسي)',
      'العنوان الوطني (الإضافي)',
      'المدينة (العنوان)',
      'المحافظة / المنطقة',
    };

    List<MapEntry<String, String>> pick(Set<String> keys) =>
        step2Data.entries.where((e) => keys.contains(e.key)).toList();

    return Column(
      children: [
        _sectionCard('معلومات التمويل والطلب', Icons.monetization_on_outlined, const Color(0xFF3F51B5), pick(financialKeys)),
        const SizedBox(height: 14),
        _sectionCard('الحساب البنكي والعنوان الوطني', Icons.map_outlined, const Color(0xFF00838F), pick(addressKeys)),
        if (step2Images.isNotEmpty) ...[
          const SizedBox(height: 14),
          _attachmentsCard(step2Images),
        ],
      ],
    );
  }



  // ─── Step 3 — shows steps 1 & 2 summary ──────────────────────────────────────

  Widget _buildStep3() {
    final s1 = model.step1DisplayData;
    final s2 = model.step2DisplayData;
    final s2Images = model.step2Images;
    final receiptUrl = model.paymentReceiptUrl;

    final step1Entries = ['الاسم الكامل','رقم الجوال','رقم الهوية','نوع الوظيفة',
                           'الراتب الصافي','مبلغ القرض المطلوب','مدة القرض']
        .where((k) => s1.containsKey(k))
        .map((k) => MapEntry(k, s1[k]!))
        .toList();

    final step2Entries = s2.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary banner ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1460), Color(0xFF4A4499)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: const Icon(Icons.summarize, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ملخص الطلب الكامل',
                        style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(height: 3),
                    Text('بيانات الخطوتين الأولى والثانية',
                        style: TextStyle(
                            fontFamily: 'ReadexPro', fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── PAYMENT RECEIPT CARD ───────────────────────────────────────────────
        _buildReceiptCard(receiptUrl),
        const SizedBox(height: 20),

        // ── STEP 1 section ────────────────────────────────────────────────────
        _stepSectionHeader(num: 1, title: 'جاري المراجعة', color: const Color(0xFF7C6DFA)),
        const SizedBox(height: 12),
        _sectionCard('البيانات الشخصية والوظيفية', Icons.person_outline,
            const Color(0xFF7C6DFA), step1Entries),
        if (model.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _attachmentsCard(model.images),
        ],
        const SizedBox(height: 20),

        // ── STEP 2 section ────────────────────────────────────────────────────
        _stepSectionHeader(num: 2, title: 'تقديم الطلب', color: const Color(0xFF3F51B5)),
        const SizedBox(height: 12),
        step2Entries.isEmpty && s2Images.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecor(),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text('لا توجد بيانات إضافية للخطوة الثانية',
                        style: TextStyle(
                            fontFamily: 'ReadexPro', fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              )
            : Column(
                children: [
                  if (step2Entries.isNotEmpty)
                    _sectionCard('بيانات الخطوة الثانية', Icons.receipt_long,
                        const Color(0xFF3F51B5), step2Entries),
                  if (s2Images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _attachmentsCard(s2Images),
                  ],
                ],
              ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Card showing the payment receipt the user uploaded.
  Widget _buildReceiptCard(String? receiptUrl) {
    final hasReceipt = receiptUrl != null && receiptUrl.isNotEmpty;

    return GestureDetector(
      onTap: hasReceipt
          ? () => Navigator.push(
                // use rootNavigator to escape the bottom sheet
                parentContext,
                MaterialPageRoute(
                  builder: (_) => _FullscreenImagePage(
                    url: receiptUrl,
                    title: 'إيصال التحويل',
                  ),
                ),
              )
          : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasReceipt
                ? const Color(0xFF00838F).withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: hasReceipt ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: hasReceipt
                          ? const Color(0xFF00838F).withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasReceipt ? Icons.receipt_long : Icons.hourglass_empty_rounded,
                      size: 18,
                      color: hasReceipt
                          ? const Color(0xFF00838F)
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إيصال تحويل المبلغ',
                          style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasReceipt
                              ? 'اضغط لعرض الإيصال كاملاً'
                              : 'في انتظار رفع الإيصال من المستخدم',
                          style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 11,
                            color: hasReceipt
                                ? const Color(0xFF00838F)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasReceipt)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: Color(0xFF00838F)),
                          SizedBox(width: 4),
                          Text('عرض',
                              style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00838F),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────────────────────
            const Divider(height: 1, color: Color(0xFFF0F0F5)),

            // ── Receipt thumbnail ──────────────────────────────────────────
            if (hasReceipt)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      receiptUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey.shade50,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF00838F), strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: Colors.grey.shade50,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_outlined,
                                  size: 32, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text('تعذّر تحميل الصورة',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                      fontFamily: 'ReadexPro')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tap-to-expand overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_full,
                                    size: 13, color: Colors.white),
                                SizedBox(width: 5),
                                Text('اضغط لعرض الإيصال كاملاً',
                                    style: TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // Waiting placeholder
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade200,
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file_outlined,
                          size: 36, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'لم يتم رفع الإيصال بعد',
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  // ─── Shared builders ─────────────────────────────────────────────────────────

  Widget _stepSectionHeader({required int num, required String title, required Color color}) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('$num',
              style: const TextStyle(
                  fontFamily: 'ReadexPro', color: Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontFamily: 'ReadexPro', fontSize: 15,
                fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0xFFE8FAF0), borderRadius: BorderRadius.circular(10)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Color(0xFF2ECA7D), size: 12),
              SizedBox(width: 3),
              Text('تمت الموافقة',
                  style: TextStyle(
                      fontFamily: 'ReadexPro', fontSize: 10,
                      color: Color(0xFF2ECA7D), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(String title, IconData icon, Color color,
      List<MapEntry<String, String>> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 17),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (int i = 0; i < entries.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: _field(entries[i].key, entries[i].value)),
                        if (i + 1 < entries.length)
                          Expanded(child: _field(entries[i + 1].key, entries[i + 1].value))
                        else
                          const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(fontFamily: 'ReadexPro', fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 3),
      Text(value.isNotEmpty ? value : '—',
          style: const TextStyle(
              fontFamily: 'ReadexPro', fontSize: 13,
              fontWeight: FontWeight.w600, color: Colors.black87)),
    ],
  );

  Widget _attachmentsCard(Map<String, String> images) {
    const labels = <String, String>{
      'idFront': 'بطاقة الهوية (أمامية)',
      'idBack': 'بطاقة الهوية (خلفية)',
      'bankAccount': 'كشف الحساب البنكي',
      'proofOfIncome': 'إثبات الدخل',
      'salarySlip': 'قسيمة الراتب',
    };
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4499).withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: const Color(0xFF4A4499).withOpacity(0.1))),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined, color: Color(0xFF4A4499), size: 17),
                const SizedBox(width: 10),
                const Text('المرفقات والمستندات',
                    style: TextStyle(
                        fontFamily: 'ReadexPro', fontSize: 13,
                        fontWeight: FontWeight.w700, color: Color(0xFF4A4499))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4A4499),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${images.length}',
                      style: const TextStyle(
                          fontFamily: 'ReadexPro', color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: images.entries.map((e) {
                final label = labels[e.key] ?? e.key;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => _FullscreenImagePage(
                          url: e.value,
                          title: label,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4499).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.insert_drive_file_outlined,
                              color: Color(0xFF4A4499), size: 17),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(label,
                              style: const TextStyle(
                                  fontFamily: 'ReadexPro', fontSize: 13,
                                  fontWeight: FontWeight.w600, color: Colors.black87)),
                        ),
                        const Icon(Icons.open_in_new, color: Color(0xFF4A4499), size: 15),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step-3 action bar ────────────────────────────────────────────────────────

  Widget _buildStep3Actions(BuildContext sheetCtx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat
            _iconBtn(
              icon: Icons.chat_bubble_outline,
              bg: Colors.white,
              fg: const Color(0xFF2A2375),
              onTap: () {
                final clientId = model.raw['userId'] ?? 'CUSTOMER-001';
                final clientName = model.name;
                Navigator.push(
                  sheetCtx,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsView(
                      client: ChatClient(id: clientId, name: clientName),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            // Reject
            _iconBtn(
              icon: Icons.delete_outline,
              bg: const Color(0xFFFFEBEB),
              fg: const Color(0xFFFF4B4B),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await cubit.rejectRequest(model);
                if (parentContext.mounted) {
                  Navigator.pop(parentContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('تم رفض الطلب وحذفه'),
                      backgroundColor: Color(0xFFFF4B4B),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 10),
            // تم دفع المبلغ
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await cubit.acceptRequest(model);
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم تأكيد دفع المبلغ وإتمام الطلب'),
                        backgroundColor: Color(0xFF2ECA7D),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECA7D), Color(0xFF17A85A)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECA7D).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('تم دفع المبلغ',
                          style: TextStyle(
                              fontFamily: 'ReadexPro',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required Color bg, required Color fg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: fg),
      ),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.grey.shade200),
  );
}

// ── Fullscreen Image Viewer ────────────────────────────────────────────────────

class _FullscreenImagePage extends StatefulWidget {
  final String url;
  final String title;

  const _FullscreenImagePage({required this.url, required this.title});

  @override
  State<_FullscreenImagePage> createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<_FullscreenImagePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformationController.value = _resetAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    if (_isZoomed) {
      // Reset to original
      _resetAnimation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      _animController.forward(from: 0);
      setState(() => _isZoomed = false);
    } else {
      // Zoom in to 2.5× centered on tap
      final pos = details.localPosition;
      final x = -pos.dx * 1.5;
      final y = -pos.dy * 1.5;
      final zoomed = Matrix4.identity()
        ..translateByDouble(x, y, 0, 1)
        ..scaleByDouble(2.5, 2.5, 1, 1);
      _resetAnimation = Matrix4Tween(
        begin: _transformationController.value,
        end: zoomed,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      _animController.forward(from: 0);
      setState(() => _isZoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'ReadexPro',
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: () {}, // required to trigger onDoubleTapDown
          child: Center(
            child: Hero(
              tag: widget.url,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.8,
                maxScale: 5.0,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'تعذّر تحميل الصورة',
                        style: TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'ReadexPro'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Bottom hint bar
        bottomNavigationBar: AnimatedOpacity(
          opacity: _isZoomed ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_in, color: Colors.white38, size: 16),
                SizedBox(width: 6),
                Text(
                  'انقر مرتين للتكبير • اسحب للتحريك',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontFamily: 'ReadexPro',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
