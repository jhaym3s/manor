class AccessCode {
  final int id;
  final String name;
  final String code;
  final String type; // 'permanent', 'recurring', 'one-time'
  final String? expires;

  AccessCode({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.expires,
  });

  AccessCode copyWith({
    int? id,
    String? name,
    String? code,
    String? type,
    String? expires,
  }) {
    return AccessCode(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      expires: expires ?? this.expires,
    );
  }

  static List<AccessCode> getSampleCodes() {
    return [
      AccessCode(
        id: 1,
        name: 'Family',
        code: '847291',
        type: 'permanent',
        expires: null,
      ),
      AccessCode(
        id: 2,
        name: 'Cleaner - Maria',
        code: '192847',
        type: 'recurring',
        expires: 'Every Tuesday',
      ),
      AccessCode(
        id: 3,
        name: 'Package Delivery',
        code: '563920',
        type: 'one-time',
        expires: 'Dec 18, 2024',
      ),
    ];
  }
}
