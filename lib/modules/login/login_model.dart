LoginModel? currentUser;

String apiUrl = '';

class LoginModel {
  LoginModel({
    this.loginToken = '',
    this.hotelId = 0,
    this.userName = '',
    this.tenantName = '',
    this.tenantLogoUrl = '',
    this.tenantEmail = '',
    this.tenantAddress = '',
    this.userCode = '',
    this.defaultCurrency = 'TRY',
    required this.tenancy,
  });

  String loginToken;
  int hotelId;
  String userName;
  String tenantName;
  String tenantLogoUrl;
  String tenantEmail;
  String tenantAddress;
  String userCode;
  String defaultCurrency;
  Tenancy tenancy;

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final rawTenancy = json["Tenancy"];

    final Map<String, dynamic>? tenancyJson = rawTenancy is Map ? Map<String, dynamic>.from(rawTenancy) : null;

    final dynamic rawHotelId = tenancyJson?["HOTELID"];
    final hotelIdVal = rawHotelId is int ? rawHotelId : (int.tryParse(rawHotelId?.toString() ?? '') ?? 0);

    final rawUsercode = json["Usercode"] ?? json["UserCode"] ?? tenancyJson?["USERCODE"];
    final userCodeVal = rawUsercode?.toString() ?? '';

    return LoginModel(
      loginToken: json["LoginToken"]?.toString() ?? '',
      hotelId: hotelIdVal,
      userName: tenancyJson?["USERNAME"]?.toString() ?? '',
      tenantName: tenancyJson?["TENANTNAME"]?.toString() ?? '',
      tenantLogoUrl: tenancyJson?["TENANTLOGOURL"]?.toString() ?? '',
      tenantEmail: tenancyJson?["TENANTEMAIL"]?.toString() ?? '',
      tenantAddress: tenancyJson?["TENANTADDRESS"]?.toString() ?? '',
      userCode: userCodeVal,
      defaultCurrency: tenancyJson?["DEFAULTCURRENCY"]?.toString() ?? 'TRY',
      tenancy: tenancyJson == null ? Tenancy.empty() : Tenancy.fromJson(tenancyJson),
    );
  }

  LoginModel clone() => LoginModel(
        loginToken: loginToken,
        hotelId: hotelId,
        userName: userName,
        tenantName: tenantName,
        tenantLogoUrl: tenantLogoUrl,
        tenantEmail: tenantEmail,
        tenantAddress: tenantAddress,
        userCode: userCode,
        defaultCurrency: defaultCurrency,
        tenancy: tenancy.clone(),
      );
}
class Tenancy {
  Tenancy({
    this.tenantName = '',
    this.tenantLogoUrl = '',
    this.tenantEmail = '',
    this.tenantAddress = '',
    this.phone = '',
    this.taxOffice = '',
    this.taxNumber = '',
    this.tenantUid = '',
    this.city = '',
    this.country = '',
    this.webAddress = '',
  });

  String tenantName;
  String tenantLogoUrl;
  String tenantEmail;
  String tenantAddress;
  String phone;
  String taxOffice;
  String taxNumber;
  String tenantUid;
  String city;
  String country;
  String webAddress;


  factory Tenancy.fromJson(Map<String, dynamic> json) => Tenancy(
        tenantName: json["TENANTNAME"]?.toString() ?? '',
        tenantLogoUrl: json["TENANTLOGOURL"]?.toString() ?? '',
        tenantEmail: json["TENANTEMAIL"]?.toString() ?? '',
        tenantAddress: json["TENANTADDRESS"]?.toString() ?? '',
        phone: json["PHONE"]?.toString() ?? '',
        taxOffice: json["TAXOFFICE"]?.toString() ?? '',
        taxNumber: json["TAXNUMBER"]?.toString() ?? '',
        tenantUid: json["TENANTUID"]?.toString() ?? '',
        city: json["CITY"]?.toString() ?? '',
        country: json["COUNTRY"]?.toString() ?? '',
        webAddress: json["WEBADDRESS"]?.toString() ?? '',
      );
  factory Tenancy.empty() => Tenancy();

  Tenancy clone() => Tenancy(
        tenantName: tenantName,
        tenantLogoUrl: tenantLogoUrl,
        tenantEmail: tenantEmail,
        tenantAddress: tenantAddress,
        phone: phone,
        taxOffice: taxOffice,
        taxNumber: taxNumber,
        tenantUid: tenantUid,
        city: city,
        country: country,
        webAddress: webAddress,
      );
}
