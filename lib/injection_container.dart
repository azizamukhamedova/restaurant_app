import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// utils
import '/core/network/client.dart';
import '/core/network/network_info.dart';

/// services
import '/src/data/database/app_db.dart';
import '/src/domain/usecases/.usecases.dart';
import '/src/data/datasources/.datasources.dart';
import '/src/domain/repositories/.repositories.dart';
import '/src/presentation/controllers/.controllers.dart';

init() async {
  /// db
  final database = AppDatabase();
  Get.put(database, permanent: true);

  // core
  Get.put(addInterceptor(Dio()));
  Get.put(Connectivity(), permanent: true);
  Get.put(InternetConnectionChecker(), permanent: true);
  Get.put<NetworkInfo>(
    NetworkInfoImpl(
      connectivity: Get.find(),
      dataChecker: Get.find(),
    ),
    permanent: true,
  );

  // datasources
  Get.lazyPut<TableLocalDatasource>(
    () => TableLocalDatasourceImpl(db: database),
    fenix: true,
  );
  Get.put<TableRemoteDatasource>(
    TableRemoteDatasourceImpl(client: Get.find()),
  );

  // repositories
  Get.lazyPut<TableRepo>(
    () => TableRepoImpl(
      networkInfo: Get.find(),
      remoteDatasource: Get.find(),
      localDatasource: Get.find(),
    ),
    fenix: true,
  );

  // usecases
  Get.lazyPut(() => GetTables(repo: Get.find()), fenix: true);
  Get.lazyPut(() => ChangeStatusOfTable(repo: Get.find()), fenix: true);

  // controllers
  Get.put<HomePageControllerImpl>(
    HomePageControllerImpl(
      getTablesUsecase: Get.find(),
      changeStatusOfTableUsecase: Get.find(),
    ),
  );
}
