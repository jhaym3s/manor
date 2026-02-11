class Bill {
  final int id;
  final String name;
  final double amount;
  final String due;
  final String status; // 'pending', 'overdue', 'upcoming', 'paid'
  final String icon;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.due,
    required this.status,
    required this.icon,
  });

  Bill copyWith({
    int? id,
    String? name,
    double? amount,
    String? due,
    String? status,
    String? icon,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      due: due ?? this.due,
      status: status ?? this.status,
      icon: icon ?? this.icon,
    );
  }

  static List<Bill> getSampleBills() {
    return [
      Bill(
        id: 1,
        name: 'Estate Service Charge',
        amount: 450.00,
        due: 'Dec 20',
        status: 'pending',
        icon: '🏛️',
      ),
      Bill(
        id: 2,
        name: 'Security Levy',
        amount: 120.00,
        due: 'Dec 15',
        status: 'overdue',
        icon: '🛡️',
      ),
      Bill(
        id: 3,
        name: 'Waste Management',
        amount: 35.00,
        due: 'Jan 5',
        status: 'upcoming',
        icon: '♻️',
      ),
      Bill(
        id: 4,
        name: 'Water Bill',
        amount: 78.50,
        due: 'Dec 28',
        status: 'pending',
        icon: '💧',
      ),
    ];
  }
}
