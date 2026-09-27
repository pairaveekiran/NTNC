class Permit {
  final String code;
  final String passport;
  final String firstName;
  final String midName;
  final String lastName;
  final String dob;
  final String gender;
  final String validFrom;
  final String validTo;
  final String receipt;
  final Country country;
  final IssuingOffice getIssuingOffice;
  final EntryExitPost getEntryPost;
  final EntryExitPost getExitPost;
  final List<CheckIn> checkIns;
  final List<Trek> treks;
  final String projectName;
  final String photo;

  Permit({
    required this.code,
    required this.passport,
    required this.firstName,
    required this.midName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.validFrom,
    required this.validTo,
    required this.receipt,
    required this.country,
    required this.getIssuingOffice,
    required this.getEntryPost,
    required this.getExitPost,
    required this.checkIns,
    required this.treks,
    required this.projectName,
    required this.photo,
  });

  factory Permit.fromJson(Map<String, dynamic> json) {
    return Permit(
      code: json['code'] ?? '',
      passport: json['passport'] ?? '',
      firstName: json['first_name'] ?? '',
      midName: json['mid_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      validFrom: json['valid_from'] ?? '',
      validTo: json['valid_to'] ?? '',
      receipt: json['receipt'] ?? '',
      country: Country.fromJson(json['country'] ?? {}),
      getIssuingOffice: IssuingOffice.fromJson(json['get_issuing_office'] ?? {}),
      getEntryPost: EntryExitPost.fromJson(json['get_entry_post'] ?? {}),
      getExitPost: EntryExitPost.fromJson(json['get_exit_post'] ?? {}),
      checkIns: (json['check_ins'] as List?)?.map((e) => CheckIn.fromJson(e)).toList() ?? [],
      treks: (json['treks'] as List?)?.map((e) => Trek.fromJson(e)).toList() ?? [],
      projectName: json['project']?['description'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class Country {
  final String nationality;

  Country({required this.nationality});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(nationality: json['nationality'] ?? json['name'] ?? '');
  }
}

class IssuingOffice {
  final String name;
  final String? phone;

  IssuingOffice({required this.name, this.phone});

  factory IssuingOffice.fromJson(Map<String, dynamic> json) {
    return IssuingOffice(
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}

class EntryExitPost {
  final String address;

  EntryExitPost({required this.address});

  factory EntryExitPost.fromJson(Map<String, dynamic> json) {
    return EntryExitPost(address: json['address'] ?? '');
  }
}

class CheckIn {
  final String loggedAt;
  final int direction;
  final CheckPost checkPost;

  CheckIn({
    required this.loggedAt,
    required this.direction,
    required this.checkPost,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      loggedAt: json['logged_at'] ?? '',
      direction: json['direction'] ?? 0,
      checkPost: CheckPost.fromJson(json['check_post'] ?? {}),
    );
  }
}

class CheckPost {
  final String name;

  CheckPost({required this.name});

  factory CheckPost.fromJson(Map<String, dynamic> json) {
    return CheckPost(name: json['name'] ?? '');
  }
}

class Trek {
  final TrekEntry trek;

  Trek({required this.trek});

  factory Trek.fromJson(Map<String, dynamic> json) {
    return Trek(trek: TrekEntry.fromJson(json['trek'] ?? {}));
  }
}

class TrekEntry {
  final String name;

  TrekEntry({required this.name});

  factory TrekEntry.fromJson(Map<String, dynamic> json) {
    return TrekEntry(name: json['name'] ?? '');
  }
}

// ─── V2 Permit Model (for /permits/V2 endpoint) ───────────────────────────
class PermitV2 {
  final int id;
  final String firstName;
  final String midName;
  final String lastName;
  final String dob;
  final String gender;
  final String code;
  final String receipt;
  final String photo;
  final String countryName;
  final String passport;
  final String projectName;
  final List<Trek> treks;

  PermitV2({
    required this.id,
    required this.firstName,
    required this.midName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.code,
    required this.receipt,
    required this.photo,
    required this.countryName,
    required this.passport,
    required this.projectName,
    required this.treks,
  });

  factory PermitV2.fromJson(Map<String, dynamic> json) {
    return PermitV2(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      midName: json['mid_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      code: json['code'] ?? '',
      receipt: json['receipt'] ?? '',
      photo: json['photo'] ?? '',
      countryName: json['country_name'] ?? json['country']?['nationality'] ?? json['country']?['name'] ?? '',
      passport: json['passport'] ?? '',
      projectName: json['project']?['description'] ?? '',
      treks: (json['treks'] as List?)?.map((e) => Trek.fromJson(e)).toList() ?? [],
    );
  }
}