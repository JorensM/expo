#import <EXDevMenu/DevClientAppDelegate.h>

#import <React/RCTBundleURLProvider.h>
#import <React/RCTCxxBridgeDelegate.h>
#if __has_include(<React_RCTAppDelegate/RCTAppSetupUtils.h>)
// for importing the header from framework, the dash will be transformed to underscore
#import <React_RCTAppDelegate/RCTAppSetupUtils.h>
#else
#import <React-RCTAppDelegate/RCTAppSetupUtils.h>
#endif

#import <memory>

#import <React/CoreModulesPlugins.h>
#import <React/RCTComponentViewFactory.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>
#import <ReactCommon/RCTContextContainerHandling.h>
#import <ReactCommon/RCTHost.h>
#import <ReactCommon/RCTTurboModuleManager.h>
#import <react/config/ReactNativeConfig.h>

#import <react/renderer/runtimescheduler/RuntimeScheduler.h>
#import <react/renderer/runtimescheduler/RuntimeSchedulerCallInvoker.h>

@interface DevClientAppDelegate () <
    RCTTurboModuleManagerDelegate,
    RCTCxxBridgeDelegate,
    RCTComponentViewFactoryComponentProvider,
    RCTContextContainerHandling> {
  std::shared_ptr<const facebook::react::ReactNativeConfig> _reactNativeConfig;
  facebook::react::ContextContainer::Shared _contextContainer;
  std::shared_ptr<facebook::react::RuntimeScheduler> _runtimeScheduler;
}
@end

@interface RCTAppDelegate (DevClientAppDelegate)

- (void)unstable_registerLegacyComponents;

@end

@implementation DevClientAppDelegate {
  RCTHost *_reactHost;
}

- (instancetype)init
{
  if (self = [super init]) {
    _contextContainer = std::make_shared<facebook::react::ContextContainer const>();
    _reactNativeConfig = std::make_shared<facebook::react::EmptyReactNativeConfig const>();
    _contextContainer->insert("ReactNativeConfig", _reactNativeConfig);
  }
  return self;
}

- (RCTBridge *)createBridgeAndSetAdapterWithLaunchOptions:(NSDictionary * _Nullable)launchOptions {
  self.bridge = [self createBridgeWithDelegate:self launchOptions:launchOptions];

  // bridgeless mode is not yet supported in expo-dev-client
  assert(!self.bridgelessEnabled);

  self.bridgeAdapter = [[RCTSurfacePresenterBridgeAdapter alloc] initWithBridge:self.bridge
                                                               contextContainer:_contextContainer];
  self.bridge.surfacePresenter = self.bridgeAdapter.surfacePresenter;

  [RCTComponentViewFactory currentComponentViewFactory].thirdPartyFabricComponentsProvider = self;

  return self.bridge;
}

#pragma mark - RCTCxxBridgeDelegate

- (std::unique_ptr<facebook::react::JSExecutorFactory>)jsExecutorFactoryForBridge:(RCTBridge *)bridge
{
  _runtimeScheduler = std::make_shared<facebook::react::RuntimeScheduler>(RCTRuntimeExecutorFromBridge(bridge));
  std::shared_ptr<facebook::react::CallInvoker> callInvoker =
      std::make_shared<facebook::react::RuntimeSchedulerCallInvoker>(_runtimeScheduler);
  RCTTurboModuleManager *turboModuleManager = [[RCTTurboModuleManager alloc] initWithBridge:bridge
                                                                                   delegate:self
                                                                                  jsInvoker:callInvoker];
  _contextContainer->erase("RuntimeScheduler");
  _contextContainer->insert("RuntimeScheduler", _runtimeScheduler);
  return RCTAppSetupDefaultJsExecutorFactory(bridge, turboModuleManager, _runtimeScheduler);
}

@end
