///
/// Dummy data sets for testing the Customer creation and management flows.
/// This provides sample input data you can use to pre-fill forms or pass to controllers
/// during the implementation.
///
library;

class SampleCustomerData {
  // ==========================================
  // 5 EXAMPLE CUSTOMERS
  // ==========================================

  static final List<Map<String, dynamic>> customers = [
    {
      'firstName': 'Lewis',
      'lastName': 'Litt',
      'phone': '0773332211',
      'nic': '198233322111',
      'email': 'lewis.l@litt.com',
      'notes': 'Wants to make sure the board is "mudged" properly.',
    },
    {
      'firstName': 'John',
      'lastName': 'Mike',
      'phone': '0771234567',
      'nic': '199012345678',
      'email': 'john.mike@example.com',
      'notes': 'Regular customer, prefers longboards.',
    },
    {
      'firstName': 'Mike',
      'lastName': 'Ross',
      'phone': '0755554444',
      'nic': '198855554444',
      'email': 'mike.ross@pearson.com',
      'notes': 'Advanced surfer, looking for high-performance boards.',
    },
    {
      'firstName': 'Samantha',
      'lastName': 'Wheeler',
      'phone': '0112223333',
      'nic': '199211122233',
      'email': 'samantha.w@law.com',
      'notes': 'Frequent visitor from UK.',
    },
    {
      'firstName': 'Harvey',
      'lastName': 'Specter',
      'phone': '0777777777',
      'nic': '198077777777',
      'email': 'harvey@specterlit.com',
      'notes': 'VIP customer, only the best boards.',
    },
  ];

  // ==========================================
  // SINGLE CUSTOMER MOCK (If needed individually)
  // ==========================================

  static final Map<String, dynamic> dummyCustomerDocument = {
    'id': 'dummy_cust_123',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '0771234567',
    'nic': '199012345678',
    'email': 'john.doe@example.com',
    'notes': 'Regular customer, prefers longboards.',
    'rentalsCount': 5,
    'lastRentalDate': '2026-03-20T10:00:00Z',
    'imageUrl': 'https://example.com/profiles/johndoe.jpg',
    'createdAt': '2026-01-01T08:00:00Z',
  };
}
