class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
