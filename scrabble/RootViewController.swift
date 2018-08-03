import UIKit

class RootViewController: UIViewController, RootProtocol {
    // MARK: - Features

    // features should be listed in order such that their dependencies are fulfilled by previous features in the list
    private var features: [FeatureName: Feature] = [
        .Camera: Feature(
            logic: CameraLogic(),
            dependencies: nil,
            view: nil,
            viewOrder: 1
        ),
        .HomeScreen: Feature(
            logic: HomeScreenLogic(),
            dependencies: [.StartGameScreen, .JoinGameScreen, .TutorialScreen, .SettingsScreen],
            view: nil,
            viewOrder: 2
        ),
        .StartGameScreen: Feature(
            logic: StartGameScreenLogic(),
            dependencies: [.HomeScreen, .GameScreen],
            view: nil,
            viewOrder: 3
        ),
        .JoinGameScreen: Feature(
            logic: JoinGameScreenLogic(),
            dependencies: [.HomeScreen, .GameScreen],
            view: nil,
            viewOrder: 4
        ),
        .TutorialScreen: Feature(
            logic: TutorialScreenLogic(),
            dependencies: [.HomeScreen],
            view: nil,
            viewOrder: 5
        ),
        .SettingsScreen: Feature(
            logic: SettingsScreenLogic(),
            dependencies: [.HomeScreen, .ChangeNameScreen],
            view: nil,
            viewOrder: 6
        ),
        .ChangeNameScreen: Feature(
            logic: ChangeNameScreenLogic(),
            dependencies: [.SettingsScreen],
            view: nil,
            viewOrder: 6
        ),
        .GameScreen: Feature(
            logic: GameScreenLogic(),
            dependencies: [.HomeScreen, .EndGameScreen, .Camera, .ObjectRecognizer],
            view: nil,
            viewOrder: 7
        ),
        .EndGameScreen: Feature(
            logic: EndGameScreenLogic(),
            dependencies: [.HomeScreen],
            view: nil,
            viewOrder: 8
        ),
        .ObjectRecognizer: Feature(
            logic: ObjectRecognizerLogic(),
            dependencies: nil,
            view: nil,
            viewOrder: 0
        )
     ]

    // views are separated from feature initialization above because we destroy views
    // when resources are low (backgrounded, etc),
    // and re-initialize when resources are available (app foregrounded)

    private let views: [FeatureName: (FeatureLogicProtocol) -> FeatureViewProtocol] = [
        .Camera: { featureLogic in CameraView(featureLogic) },
        .HomeScreen: { featureLogic in HomeScreenView(featureLogic) },
        .StartGameScreen: { featureLogic in StartGameScreenView(featureLogic) },
        .JoinGameScreen: { featureLogic in JoinGameScreenView(featureLogic) },
        .TutorialScreen: { featureLogic in TutorialScreenView(featureLogic) },
        .SettingsScreen: { featureLogic in SettingsScreenView(featureLogic) },
        .ChangeNameScreen: { featureLogic in ChangeNameScreenView(featureLogic) },
        .GameScreen: { featureLogic in GameScreenView(featureLogic) },
        .EndGameScreen: { featureLogic in EndGameScreenView(featureLogic) }
    ]

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.willAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.willDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log.warning("MEMORY WARNING")
        self.dispose()
    }

    // MARK: - RootProtocol conformance

    // Initialization of all features (not very performant, known issue)
    // Done in 2 phases so that when calling feature.logic.initialize,
    // all feature's views are already initialized and added to screen
    func initialize() {
        log.verbose("Initializing root view controller")
        // Phase 1: Initialize feature.view for all features
        for featureName in features.keys {
            if let createView = views[featureName],
                let feature = features[featureName] {
                log.verbose("Creating feature view for \(featureName)")
                let view = createView(feature.logic)
                // should not do feature.view = view, because that won't
                // update the dictionary
                features[featureName]?.view = view
                if let featureView = view as? UIView {
                    log.verbose("Adding feature view for \(featureName)")
                    self.view.addSubview(featureView)
                    if let viewOrder = feature.viewOrder {
                        featureView.layer.zPosition = CGFloat(viewOrder)
                    } else {
                        log.warning("No viewOrder specified for \(featureName)")
                    }
                } else {
                    log.error("Invalid feature view for \(featureName)")
                }
            }
        }
        // Phase 2: Call feature.logic.initialize with dependencies
        for (featureName, feature) in features {
            var featureDeps = [FeatureName: FeatureLogicProtocol]()
            if let dependencies = feature.dependencies {
                for depName in dependencies {
                    featureDeps[depName] = features[depName]?.logic
                }
            }
            log.verbose("Initializing feature logic for \(featureName)")
            feature.logic.initialize(root: self, view: feature.view, dependencies: featureDeps)
        }
    }

    func willAppear(_ animated: Bool) {
        log.verbose("Showing root view controller")
        for (_, feature) in features {
            feature.logic.willAppear(animated)
        }
    }

    func willDisappear(_ animated: Bool) {
        log.verbose("Disappearing root view controller")
        for (_, feature) in features {
            feature.logic.willDisappear(animated)
        }
    }
    
    func applicationDidEnterBackground() {
        log.verbose("Application entering background")
        for (_, feature) in features {
            feature.logic.applicationDidEnterBackground()
        }
    }

    func applicationWillEnterForeground() {
        log.verbose("Application entering foreground")
        for (_, feature) in features {
            feature.logic.applicationDidEnterForeground()
        }
    }
    
    func dispose() {
        log.verbose("Disposing root view controller")
        for featureName in features.keys {
            let f = features[featureName]
            log.verbose("Disposing feature \(featureName)")
            f?.logic.dispose()
            f?.view?.removeFromSuperview()
            // cannot do: f?.view = nil (that does nothing to features)
            features[featureName]?.view = nil
        }
    }
}
