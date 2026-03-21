class ServiceProvider {
  final int id;
  final String title;
  final String permalink;
  final String? logoUrl;
  final String? bannerUrl;
  final String? mobileNumber;
  final String? whatsapp;
  final String? email;
  final String? website;

  ServiceProvider({
    required this.id,
    required this.title,
    required this.permalink,
    this.logoUrl,
    this.bannerUrl,
    this.mobileNumber,
    this.whatsapp,
    this.email,
    this.website,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    String? extractUrl(dynamic field) {
      if (field is Map) {
        if (field['url'] is String) {
          return field['url'];
        }
      }
      return null;
    }

    final acf = json['acf'] is Map ? json['acf'] as Map<String, dynamic> : <String, dynamic>{};

    return ServiceProvider(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'No Title',
      permalink: json['permalink'] as String? ?? '',
      logoUrl: extractUrl(acf['logo']),
      bannerUrl: extractUrl(acf['banner']),
      mobileNumber: acf['mobile_number'] as String?,
      whatsapp: acf['whatsapp'] as String?,
      email: acf['email'] as String?,
      website: acf['website'] as String?,
    );
  }
}
