// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../auth/application/auth_usecases.dart' as _i880;
import '../../auth/domain/repositories/auth_repository.dart' as _i937;
import '../../auth/domain/repositories/repositories.dart' as _i102;
import '../../auth/infrastructure/auth_repository_impl.dart' as _i971;
import '../../auth/presentation/bloc/auth/auth_bloc.dart' as _i622;
import '../../business/application/sales_usecases.dart' as _i1030;
import '../../business/domain/repositories/sales_repository.dart' as _i186;
import '../../business/infrastructure/sales_repository_impl.dart' as _i262;
import '../../business/presentation/bloc/sales/sales_bloc.dart' as _i87;
import '../../data/network/api_service.dart' as _i576;
import '../../data/repositories/sync_data.dart' as _i1004;
import '../../data/services/auth_service.dart' as _i117;
import '../../data/services/connectivity_service.dart' as _i761;
import '../../data/services/crop_service.dart' as _i311;
import '../../data/services/inventory_service.dart' as _i374;
import '../../data/services/knowledge_service.dart' as _i97;
import '../../data/services/sale_service.dart' as _i970;
import '../../data/services/weather_service.dart' as _i791;
import '../../farm_mgmt/application/animal_usecases.dart' as _i505;
import '../../farm_mgmt/application/breeding_usecases.dart' as _i202;
import '../../farm_mgmt/application/crop_usecases.dart' as _i614;
import '../../farm_mgmt/application/domain_event_subscribers.dart' as _i870;
import '../../farm_mgmt/application/feeding_usecases.dart' as _i1003;
import '../../farm_mgmt/application/get_overview.dart' as _i941;
import '../../farm_mgmt/application/production_usecases.dart' as _i839;
import '../../farm_mgmt/application/task_usecases.dart' as _i38;
import '../../farm_mgmt/domain/repositories/animal_repository.dart' as _i686;
import '../../farm_mgmt/domain/repositories/breeding_repository.dart' as _i951;
import '../../farm_mgmt/domain/repositories/crop_repository.dart' as _i42;
import '../../farm_mgmt/domain/repositories/feeding_repository.dart' as _i339;
import '../../farm_mgmt/domain/repositories/production_log_repository.dart'
    as _i984;
import '../../farm_mgmt/domain/repositories/repositories.dart' as _i681;
import '../../farm_mgmt/domain/repositories/task_repository.dart' as _i617;
import '../../farm_mgmt/infrastructure/animal_repository_impl.dart' as _i529;
import '../../farm_mgmt/infrastructure/breeding_repository_impl.dart' as _i494;
import '../../farm_mgmt/infrastructure/crop_repository_impl.dart' as _i324;
import '../../farm_mgmt/infrastructure/feeding_repository_impl.dart' as _i200;
import '../../farm_mgmt/infrastructure/production_log_repository_impl.dart'
    as _i430;
import '../../farm_mgmt/infrastructure/task_repository_impl.dart' as _i656;
import '../../farm_mgmt/presentation/bloc/animals/animals_bloc.dart' as _i149;
import '../../farm_mgmt/presentation/bloc/breeding/breeding_cubit.dart' as _i23;
import '../../farm_mgmt/presentation/bloc/crops/crops_bloc.dart' as _i278;
import '../../farm_mgmt/presentation/bloc/feeding/feeding_bloc.dart' as _i514;
import '../../farm_mgmt/presentation/bloc/navigation/farm_nav_cubit.dart'
    as _i971;
import '../../farm_mgmt/presentation/bloc/overview/overview_bloc.dart' as _i365;
import '../../farm_mgmt/presentation/bloc/production/production_log_cubit.dart'
    as _i942;
import '../../farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart' as _i975;
import '../../home/application/get_dashboard_data.dart' as _i167;
import '../../home/presentation/bloc/home/home_bloc.dart' as _i126;
import '../../inventory/application/inventory_usecases.dart' as _i516;
import '../../inventory/domain/repositories/inventory_repository.dart' as _i604;
import '../../inventory/domain/repositories/repositories.dart' as _i55;
import '../../inventory/infrastructure/inventory_repository_impl.dart' as _i630;
import '../../inventory/presentation/bloc/inventory/inventory_bloc.dart'
    as _i430;
import '../../knowledge/application/knowledge_usecases.dart' as _i1073;
import '../../knowledge/domain/repositories/knowledge_repository.dart' as _i469;
import '../../knowledge/infrastructure/knowledge_repository_impl.dart' as _i74;
import '../../knowledge/presentation/bloc/knowledge/knowledge_cubit.dart'
    as _i550;
import '../../marketplace/application/marketplace_usecases.dart' as _i181;
import '../../marketplace/domain/repositories/marketplace_repository.dart'
    as _i340;
import '../../marketplace/domain/repositories/repositories.dart' as _i882;
import '../../marketplace/infrastructure/marketplace_repository_impl.dart'
    as _i493;
import '../../marketplace/presentation/bloc/marketplace/marketplace_bloc.dart'
    as _i819;
import '../../onboarding/presentation/bloc/onboarding/onboarding_cubit.dart'
    as _i725;
import '../../profile/application/profile_usecases.dart' as _i833;
import '../../profile/domain/repositories/profile_repository.dart' as _i715;
import '../../profile/domain/repositories/repositories.dart' as _i863;
import '../../profile/infrastructure/profile_repository_impl.dart' as _i607;
import '../../profile/presentation/bloc/profile/audit_events_cubit.dart'
    as _i421;
import '../../profile/presentation/bloc/profile/profile_bloc.dart' as _i951;
import '../../weather/application/weather_usecases.dart' as _i27;
import '../../weather/domain/repositories/weather_repository.dart' as _i869;
import '../../weather/infrastructure/weather_repository_impl.dart' as _i344;
import '../../weather/presentation/bloc/weather/weather_cubit.dart' as _i564;
import '../domain/events/domain_event_bus.dart' as _i468;
import '../domain/repositories/farm_summary_repository.dart' as _i873;
import '../infrastructure/farm_summary_repository_impl.dart' as _i3;
import '../network/token_manager.dart' as _i374;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i971.FarmNavCubit>(() => _i971.FarmNavCubit());
    gh.factory<_i725.OnboardingCubit>(() => _i725.OnboardingCubit());
    gh.lazySingleton<_i374.TokenManager>(() => _i374.TokenManager());
    gh.lazySingleton<_i576.ApiService>(() => _i576.ApiService());
    gh.lazySingleton<_i1004.SyncData>(() => _i1004.SyncData());
    gh.lazySingleton<_i761.ConnectivityService>(
        () => _i761.ConnectivityService());
    gh.lazySingleton<_i311.CropService>(() => _i311.CropService());
    gh.lazySingleton<_i970.SaleService>(() => _i970.SaleService());
    gh.lazySingleton<_i468.DomainEventBus>(
      () => _i468.DomainEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i617.TaskRepository>(
        () => _i656.TaskRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i873.FarmSummaryRepository>(
        () => _i3.FarmSummaryRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i941.GetOverview>(
        () => _i941.GetOverview(gh<_i873.FarmSummaryRepository>()));
    gh.lazySingleton<_i339.FeedingRepository>(
        () => _i200.FeedingRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i984.ProductionLogRepository>(
        () => _i430.ProductionLogRepositoryImpl());
    gh.lazySingleton<_i340.MarketplaceRepository>(
        () => _i493.MarketplaceRepositoryImpl());
    gh.lazySingleton<_i42.CropRepository>(
        () => _i324.CropRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i97.KnowledgeService>(
        () => _i97.KnowledgeService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i791.WeatherService>(
        () => _i791.WeatherService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i374.InventoryService>(
        () => _i374.InventoryService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i951.BreedingRepository>(
        () => _i494.BreedingRepositoryImpl());
    gh.lazySingleton<_i1003.GetFeedingSchedules>(
        () => _i1003.GetFeedingSchedules(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.GetFeedingLogs>(
        () => _i1003.GetFeedingLogs(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.AddFeedingSchedule>(
        () => _i1003.AddFeedingSchedule(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.UpdateFeedingSchedule>(
        () => _i1003.UpdateFeedingSchedule(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.DeleteFeedingSchedule>(
        () => _i1003.DeleteFeedingSchedule(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.AddFeedingLog>(
        () => _i1003.AddFeedingLog(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.UpdateFeedingLog>(
        () => _i1003.UpdateFeedingLog(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i1003.DeleteFeedingLog>(
        () => _i1003.DeleteFeedingLog(gh<_i339.FeedingRepository>()));
    gh.lazySingleton<_i186.SalesRepository>(
        () => _i262.SalesRepositoryImpl(gh<_i970.SaleService>()));
    gh.lazySingleton<_i686.AnimalRepository>(
        () => _i529.AnimalRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i202.AddBreedingRecord>(() => _i202.AddBreedingRecord(
          gh<_i951.BreedingRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i870.DomainEventSubscribers>(
      () => _i870.DomainEventSubscribers(
        gh<_i468.DomainEventBus>(),
        gh<_i617.TaskRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i117.AuthService>(() => _i117.AuthService(
          gh<_i576.ApiService>(),
          gh<_i374.TokenManager>(),
        ));
    gh.lazySingleton<_i614.AddCrop>(() => _i614.AddCrop(
          gh<_i681.CropRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i614.UpdateCrop>(() => _i614.UpdateCrop(
          gh<_i681.CropRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i614.GetCrops>(
        () => _i614.GetCrops(gh<_i681.CropRepository>()));
    gh.lazySingleton<_i614.DeleteCrop>(
        () => _i614.DeleteCrop(gh<_i681.CropRepository>()));
    gh.lazySingleton<_i505.GetAnimals>(
        () => _i505.GetAnimals(gh<_i681.AnimalRepository>()));
    gh.lazySingleton<_i505.AddAnimal>(
        () => _i505.AddAnimal(gh<_i681.AnimalRepository>()));
    gh.lazySingleton<_i505.UpdateAnimal>(
        () => _i505.UpdateAnimal(gh<_i681.AnimalRepository>()));
    gh.lazySingleton<_i505.DeleteAnimal>(
        () => _i505.DeleteAnimal(gh<_i681.AnimalRepository>()));
    gh.factory<_i278.CropsBloc>(() => _i278.CropsBloc(
          gh<_i614.GetCrops>(),
          gh<_i614.AddCrop>(),
          gh<_i614.UpdateCrop>(),
          gh<_i614.DeleteCrop>(),
        ));
    gh.lazySingleton<_i839.GetProductionLogs>(
        () => _i839.GetProductionLogs(gh<_i984.ProductionLogRepository>()));
    gh.lazySingleton<_i839.AddProductionLog>(
        () => _i839.AddProductionLog(gh<_i984.ProductionLogRepository>()));
    gh.lazySingleton<_i839.DeleteProductionLog>(
        () => _i839.DeleteProductionLog(gh<_i984.ProductionLogRepository>()));
    gh.factory<_i942.ProductionLogCubit>(() => _i942.ProductionLogCubit(
          gh<_i839.GetProductionLogs>(),
          gh<_i839.AddProductionLog>(),
          gh<_i839.DeleteProductionLog>(),
        ));
    gh.lazySingleton<_i38.GetTasks>(
        () => _i38.GetTasks(gh<_i681.TaskRepository>()));
    gh.lazySingleton<_i38.AddTask>(
        () => _i38.AddTask(gh<_i681.TaskRepository>()));
    gh.lazySingleton<_i38.DeleteTask>(
        () => _i38.DeleteTask(gh<_i681.TaskRepository>()));
    gh.factory<_i365.OverviewBloc>(
        () => _i365.OverviewBloc(gh<_i941.GetOverview>()));
    gh.lazySingleton<_i38.UpdateTask>(() => _i38.UpdateTask(
          gh<_i681.TaskRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.factory<_i514.FeedingBloc>(() => _i514.FeedingBloc(
          gh<_i1003.GetFeedingSchedules>(),
          gh<_i1003.GetFeedingLogs>(),
          gh<_i505.GetAnimals>(),
          gh<_i1003.UpdateFeedingSchedule>(),
          gh<_i1003.AddFeedingLog>(),
          gh<_i1003.DeleteFeedingLog>(),
        ));
    gh.lazySingleton<_i869.WeatherRepository>(
        () => _i344.WeatherRepositoryImpl(gh<_i791.WeatherService>()));
    gh.lazySingleton<_i1030.GetSales>(
        () => _i1030.GetSales(gh<_i186.SalesRepository>()));
    gh.lazySingleton<_i1030.AddSale>(
        () => _i1030.AddSale(gh<_i186.SalesRepository>()));
    gh.lazySingleton<_i1030.UpdateSale>(
        () => _i1030.UpdateSale(gh<_i186.SalesRepository>()));
    gh.lazySingleton<_i1030.DeleteSale>(
        () => _i1030.DeleteSale(gh<_i186.SalesRepository>()));
    gh.lazySingleton<_i469.KnowledgeRepository>(
        () => _i74.KnowledgeRepositoryImpl(gh<_i97.KnowledgeService>()));
    gh.lazySingleton<_i604.InventoryRepository>(
        () => _i630.InventoryRepositoryImpl(
              gh<_i374.InventoryService>(),
              gh<_i761.ConnectivityService>(),
            ));
    gh.factory<_i975.TasksBloc>(() => _i975.TasksBloc(
          gh<_i38.GetTasks>(),
          gh<_i38.AddTask>(),
          gh<_i38.UpdateTask>(),
          gh<_i38.DeleteTask>(),
        ));
    gh.lazySingleton<_i27.GetWeather>(
        () => _i27.GetWeather(gh<_i869.WeatherRepository>()));
    gh.lazySingleton<_i181.GetProducts>(
        () => _i181.GetProducts(gh<_i882.MarketplaceRepository>()));
    gh.lazySingleton<_i181.AddProduct>(
        () => _i181.AddProduct(gh<_i882.MarketplaceRepository>()));
    gh.lazySingleton<_i181.UpdateProduct>(
        () => _i181.UpdateProduct(gh<_i882.MarketplaceRepository>()));
    gh.lazySingleton<_i181.DeleteProduct>(
        () => _i181.DeleteProduct(gh<_i882.MarketplaceRepository>()));
    gh.lazySingleton<_i181.SubmitMarketplaceInquiry>(() =>
        _i181.SubmitMarketplaceInquiry(gh<_i882.MarketplaceRepository>()));
    gh.factory<_i564.WeatherCubit>(
        () => _i564.WeatherCubit(gh<_i27.GetWeather>()));
    gh.factory<_i149.AnimalsBloc>(() => _i149.AnimalsBloc(
          gh<_i505.GetAnimals>(),
          gh<_i505.AddAnimal>(),
          gh<_i505.UpdateAnimal>(),
          gh<_i505.DeleteAnimal>(),
        ));
    gh.lazySingleton<_i202.GetBreedingRecords>(
        () => _i202.GetBreedingRecords(gh<_i951.BreedingRepository>()));
    gh.lazySingleton<_i202.DeleteBreedingRecord>(
        () => _i202.DeleteBreedingRecord(gh<_i951.BreedingRepository>()));
    gh.factory<_i23.BreedingCubit>(() => _i23.BreedingCubit(
          gh<_i202.GetBreedingRecords>(),
          gh<_i202.AddBreedingRecord>(),
          gh<_i202.DeleteBreedingRecord>(),
        ));
    gh.lazySingleton<_i937.AuthRepository>(() => _i971.AuthRepositoryImpl(
          gh<_i117.AuthService>(),
          gh<_i374.TokenManager>(),
        ));
    gh.lazySingleton<_i167.GetDashboardData>(() => _i167.GetDashboardData(
          gh<_i873.FarmSummaryRepository>(),
          gh<_i27.GetWeather>(),
        ));
    gh.lazySingleton<_i1073.GetKnowledgeTopics>(
        () => _i1073.GetKnowledgeTopics(gh<_i469.KnowledgeRepository>()));
    gh.lazySingleton<_i516.GetInventory>(
        () => _i516.GetInventory(gh<_i55.InventoryRepository>()));
    gh.lazySingleton<_i516.DeleteInventoryItem>(
        () => _i516.DeleteInventoryItem(gh<_i55.InventoryRepository>()));
    gh.lazySingleton<_i516.ResolveInventoryConflictKeepLocal>(() =>
        _i516.ResolveInventoryConflictKeepLocal(
            gh<_i55.InventoryRepository>()));
    gh.lazySingleton<_i516.ResolveInventoryConflictUseServer>(() =>
        _i516.ResolveInventoryConflictUseServer(
            gh<_i55.InventoryRepository>()));
    gh.factory<_i819.MarketplaceBloc>(() => _i819.MarketplaceBloc(
          gh<_i181.GetProducts>(),
          gh<_i181.AddProduct>(),
          gh<_i181.UpdateProduct>(),
          gh<_i181.DeleteProduct>(),
        ));
    gh.factory<_i87.SalesBloc>(() => _i87.SalesBloc(
          gh<_i1030.GetSales>(),
          gh<_i1030.AddSale>(),
          gh<_i1030.UpdateSale>(),
          gh<_i1030.DeleteSale>(),
        ));
    gh.factory<_i126.HomeBloc>(
        () => _i126.HomeBloc(gh<_i167.GetDashboardData>()));
    gh.lazySingleton<_i516.AddInventoryItem>(() => _i516.AddInventoryItem(
          gh<_i55.InventoryRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i516.UpdateInventoryItem>(() => _i516.UpdateInventoryItem(
          gh<_i55.InventoryRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i715.ProfileRepository>(() => _i607.ProfileRepositoryImpl(
          gh<_i117.AuthService>(),
          gh<_i937.AuthRepository>(),
          gh<_i576.ApiService>(),
        ));
    gh.lazySingleton<_i880.SignIn>(
        () => _i880.SignIn(gh<_i102.AuthRepository>()));
    gh.lazySingleton<_i880.Register>(
        () => _i880.Register(gh<_i102.AuthRepository>()));
    gh.lazySingleton<_i880.SignOut>(
        () => _i880.SignOut(gh<_i102.AuthRepository>()));
    gh.lazySingleton<_i880.GetCurrentUser>(
        () => _i880.GetCurrentUser(gh<_i102.AuthRepository>()));
    gh.lazySingleton<_i880.CheckAuthStatusUseCase>(
        () => _i880.CheckAuthStatusUseCase(gh<_i102.AuthRepository>()));
    gh.factory<_i550.KnowledgeCubit>(
        () => _i550.KnowledgeCubit(gh<_i1073.GetKnowledgeTopics>()));
    gh.factory<_i622.AuthBloc>(() => _i622.AuthBloc(
          gh<_i880.SignIn>(),
          gh<_i880.Register>(),
          gh<_i880.SignOut>(),
          gh<_i880.CheckAuthStatusUseCase>(),
          gh<_i880.GetCurrentUser>(),
        ));
    gh.factory<_i430.InventoryBloc>(() => _i430.InventoryBloc(
          gh<_i516.GetInventory>(),
          gh<_i516.AddInventoryItem>(),
          gh<_i516.UpdateInventoryItem>(),
          gh<_i516.DeleteInventoryItem>(),
          gh<_i516.ResolveInventoryConflictKeepLocal>(),
          gh<_i516.ResolveInventoryConflictUseServer>(),
        ));
    gh.lazySingleton<_i833.GetProfile>(
        () => _i833.GetProfile(gh<_i863.ProfileRepository>()));
    gh.lazySingleton<_i833.Logout>(
        () => _i833.Logout(gh<_i863.ProfileRepository>()));
    gh.lazySingleton<_i833.GetAuditEvents>(
        () => _i833.GetAuditEvents(gh<_i863.ProfileRepository>()));
    gh.factory<_i951.ProfileBloc>(() => _i951.ProfileBloc(
          gh<_i833.GetProfile>(),
          gh<_i833.Logout>(),
        ));
    gh.factory<_i421.AuditEventsCubit>(
        () => _i421.AuditEventsCubit(gh<_i833.GetAuditEvents>()));
    return this;
  }
}
