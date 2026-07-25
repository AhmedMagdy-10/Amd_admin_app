import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed, immutable representation of a single financing request.
///
/// All Firestore normalization lives here:
///   - `eligibilityData` sub-map is flattened into typed fields
///   - `images` sub-map is safely cast regardless of Firestore return type
///   - Firestore [Timestamp] → readable date string
///   - `jobType` code → Arabic label
///   - `firstName` + `lastName` → full display name
class RequestModel {
  final String id;           // Firestore document ID
  final String collection;   // Source collection name
  final String name;
  final String requestId;    // Display ID (e.g. "#REQ-10255")
  final String date;
  final String status;
  final int currentStep;
  final String jobType;
  final String email;
  final String phone;
  final String nationalId;
  final String nationality;
  final String birthdate;
  final String dependents;
  final String amount;
  final String duration;
  final String netSalary;
  final String lastSalaryDate;
  final String joiningDate;
  final bool hasCurrentLoans;
  final String currentLoanInstallment;
  final String remainingMonths;
  final Map<String, String> images; // key → URL
  final Map<String, dynamic> raw;   // full raw data (for write-back operations)

  const RequestModel({
    required this.id,
    required this.collection,
    required this.name,
    required this.requestId,
    required this.date,
    required this.status,
    required this.currentStep,
    required this.jobType,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.nationality,
    required this.birthdate,
    required this.dependents,
    required this.amount,
    required this.duration,
    required this.netSalary,
    required this.lastSalaryDate,
    required this.joiningDate,
    required this.hasCurrentLoans,
    required this.currentLoanInstallment,
    required this.remainingMonths,
    required this.images,
    required this.raw,
  });

  // ── Factory ──────────────────────────────────────────────────────────────────

  factory RequestModel.fromFirestore(
    String docId,
    Map<String, dynamic> data,
    String collectionName,
  ) {
    // Safely extract nested eligibilityData map
    final eligibility = _safeMap(data['eligibilityData']);

    // Safely extract images map (lives inside eligibilityData for FinancingRequests)
    final rawImages = eligibility['images'] ?? data['images'];
    final images = _safeStringMap(rawImages);

    // Helper: read from eligibility first, fall back to root
    String field(String key) {
      final v = eligibility[key] ?? data[key];
      return v?.toString().trim() ?? '';
    }

    // Full name
    final firstName = field('firstName');
    final lastName  = field('lastName');
    final name = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : field('name').isNotEmpty
            ? field('name')
            : (data['fullName'] ?? data['clientName'] ?? 'بدون اسم').toString();

    // Date — handles Firestore Timestamp or plain string
    final date = _parseDate(data['createdAt'] ?? data['date']);

    // Loan amount
    final loanAmountRaw = eligibility['loanAmount'] ?? data['loanAmount'] ?? data['amount'];
    final amount = _formatAmount(loanAmountRaw, data['amount']);

    // Loan duration
    final loanDurationRaw = eligibility['loanDuration'] ?? data['loanDuration'] ?? data['duration'];
    final duration = _formatDuration(loanDurationRaw, data['duration']);

    // Job type code → Arabic
    final jobTypeCode = field('jobType');
    final jobType = _localizeJobType(jobTypeCode);

    return RequestModel(
      id:                     docId,
      collection:             collectionName,
      name:                   name,
      requestId:              field('requestId').isNotEmpty ? field('requestId') : docId,
      date:                   date,
      status:                 (data['status'] ?? 'eligibility_pending').toString(),
      currentStep:            _parseInt(data['currentStep'] ?? data['step'], 1),
      jobType:                jobType,
      email:                  field('email'),
      phone:                  field('phoneNumber').isNotEmpty ? field('phoneNumber') : field('phone'),
      nationalId:             field('nationalId').isNotEmpty ? field('nationalId') : field('identityNumber'),
      nationality:            field('nationality'),
      birthdate:              field('birthDate').isNotEmpty ? field('birthDate') : field('birthdate'),
      dependents:             field('dependentsCount').isNotEmpty ? field('dependentsCount') : field('dependents'),
      amount:                 amount,
      duration:               duration,
      netSalary:              field('netSalary'),
      lastSalaryDate:         field('lastSalaryDate'),
      joiningDate:            field('joinDate').isNotEmpty ? field('joinDate') : field('joiningDate'),
      hasCurrentLoans:        (eligibility['hasCurrentLoans'] ?? data['hasCurrentLoans']) == true,
      currentLoanInstallment: field('currentLoanInstallments').isNotEmpty
                                ? field('currentLoanInstallments')
                                : field('currentLoanInstallment'),
      remainingMonths:        field('remainingMonths'),
      images:                 images,
      raw: {
        ...data,
        'id':          docId,
        '_collection': collectionName,
      },
    );
  }

  // ── View map (backward-compatible for existing UI tiles) ─────────────────────

  /// Returns a flat [Map<String, dynamic>] that the existing UI widgets read.
  /// All data is already normalized — no further processing needed in widgets.
  Map<String, dynamic> toViewMap() => {
    'id':                     id,
    '_collection':            collection,
    'name':                   name,
    'requestId':              requestId,
    'date':                   date,
    'status':                 status,
    'currentStep':            currentStep,
    'job':                    jobType,
    'jobType':                jobType,
    'email':                  email,
    'phone':                  phone,
    'identityNumber':         nationalId,
    'nationalId':             nationalId,
    'nationality':            nationality,
    'birthdate':              birthdate,
    'dependents':             dependents,
    'amount':                 amount,
    'duration':               duration,
    'netSalary':              netSalary,
    'lastSalaryDate':         lastSalaryDate,
    'joiningDate':            joiningDate,
    'hasCurrentLoans':        hasCurrentLoans,
    'currentLoanInstallment': currentLoanInstallment,
    'remainingMonths':        remainingMonths,
    'images':                 images,
    // Preserve all original fields for any UI keys not yet mapped
    ...raw,
  };

  // ── Step-specific data helpers ────────────────────────────────────────────────

  /// Flat display map for Step 1 (eligibility / personal info).
  Map<String, String> get step1DisplayData {
    final map = <String, String>{};
    void put(String label, String value) {
      if (value.isNotEmpty) map[label] = value;
    }
    put('الاسم الكامل', name);
    put('البريد الإلكتروني', email);
    put('رقم الجوال', phone);
    put('رقم الهوية', nationalId);
    put('الجنسية', nationality);
    put('تاريخ الميلاد', birthdate);
    put('عدد المعالين', dependents);
    put('نوع الوظيفة', jobType);
    put('الراتب الصافي', netSalary);
    put('تاريخ آخر راتب', lastSalaryDate);
    put('تاريخ الانضمام للعمل', joiningDate);
    put('مبلغ القرض المطلوب', amount);
    put('مدة القرض', duration);
    map['يوجد قروض حالية'] = hasCurrentLoans ? 'نعم' : 'لا';
    put('قسط القرض الحالي', currentLoanInstallment);
    put('الأشهر المتبقية', remainingMonths);
    return map;
  }

  /// Raw data submitted by the client in Step 2 (stored under requestData sub-map).
  Map<String, dynamic> get step2RawData {
    final v = raw['requestData'] ?? raw['step2Data'] ?? raw['step2'];
    return _safeMap(v);
  }

  /// Raw data submitted by the client in Step 3 (stored under transferData sub-map).
  Map<String, dynamic> get step3RawData {
    final v = raw['transferData'] ?? raw['step3Data'] ?? raw['step3'];
    return _safeMap(v);
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  static Map<String, dynamic> _safeMap(dynamic raw) {
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return {};
  }

  static Map<String, String> _safeStringMap(dynamic raw) {
    if (raw is Map) {
      return Map.fromEntries(
        raw.entries
            .where((e) => e.value != null && e.value.toString().isNotEmpty)
            .map((e) => MapEntry(e.key.toString(), e.value.toString())),
      );
    }
    return {};
  }

  static String _parseDate(dynamic raw) {
    if (raw == null) return '';
    if (raw is Timestamp) {
      final dt = raw.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    // Try dynamic .toDate() for cases where type isn't imported
    try {
      final dt = (raw as dynamic).toDate() as DateTime;
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }

  static String _formatAmount(dynamic raw, dynamic fallback) {
    if (raw == null) return fallback?.toString() ?? '';
    final n = num.tryParse(raw.toString());
    if (n != null && n != 0) return '${n.toStringAsFixed(0)} ر.س';
    return fallback?.toString() ?? '';
  }

  static String _formatDuration(dynamic raw, dynamic fallback) {
    if (raw == null) return fallback?.toString() ?? '';
    final n = num.tryParse(raw.toString());
    if (n != null && n != 0) return '${n.toStringAsFixed(0)} شهر';
    return fallback?.toString() ?? '';
  }

  static String _localizeJobType(String code) {
    const map = {'gov': 'حكومي', 'private': 'خاص', 'military': 'عسكري', 'retired': 'متقاعد'};
    return map[code] ?? code;
  }

  static int _parseInt(dynamic raw, int fallback) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? fallback;
  }
}
