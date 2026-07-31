import 'package:get_it/get_it.dart';

import 'package:aquapark/core/storage/credential_storage_service.dart';
import 'package:aquapark/modules/login/login_service.dart';
import 'package:aquapark/modules/dashboard/dashboard_service.dart';
import 'package:aquapark/modules/dailysales/daily_sales_service.dart';

final getIt = GetIt.instance;

// Bağımlılıkların kurulduğu yer.
void setupLocator() {
  getIt.registerLazySingleton<LoginService>(() => LoginService());

  getIt.registerLazySingleton<DashboardService>(
        () => DashboardService(),
  );

  getIt.registerLazySingleton<DailySalesService>(
        () => DailySalesService(),
  );

  getIt.registerLazySingleton<CredentialStorageService>(
        () => CredentialStorageService(),
  );
}