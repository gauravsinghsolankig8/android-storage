import 'dart:async';
import 'dart:typed_data';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../core/app_config.dart';
import '../models/outfit_model.dart';
import '../models/mood_model.dart';

class ARService {
  static final ARService _instance = ARService._internal();
  factory ARService() => _instance;
  ARService._internal();

  // AR Managers
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  // AR State
  bool _isARInitialized = false;
  bool _isPlacingBuddy = false;
  bool _isBuddyPlaced = false;
  ARNode? _buddyNode;
  String? _currentOutfit;
  String? _currentAnimation;

  // Stream controllers
  final StreamController<bool> _arStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _animationController = StreamController<String>.broadcast();
  final StreamController<bool> _buddyPlacedController = StreamController<bool>.broadcast();

  // Getters
  Stream<bool> get arStatusStream => _arStatusController.stream;
  Stream<String> get animationStream => _animationController.stream;
  Stream<bool> get buddyPlacedStream => _buddyPlacedController.stream;
  bool get isARInitialized => _isARInitialized;
  bool get isBuddyPlaced => _isBuddyPlaced;
  bool get isPlacingBuddy => _isPlacingBuddy;

  // Initialize AR session
  Future<bool> initializeAR({
    required ARSessionManager arSessionManager,
    required ARObjectManager arObjectManager,
    required ARAnchorManager arAnchorManager,
  }) async {
    try {
      _arSessionManager = arSessionManager;
      _arObjectManager = arObjectManager;
      _arAnchorManager = arAnchorManager;

      // Configure AR session
      await _configureARSession();

      _isARInitialized = true;
      _arStatusController.add(true);
      return true;
    } catch (e) {
      print('AR initialization failed: $e');
      _isARInitialized = false;
      _arStatusController.add(false);
      return false;
    }
  }

  // Configure AR session settings
  Future<void> _configureARSession() async {
    if (_arSessionManager == null) return;

    try {
      // Configure plane detection
      await _arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        customPlaneTexturePath: "assets/images/triangle.png",
        showWorldOrigin: false,
        handlePans: true,
        handleRotation: true,
      );
    } catch (e) {
      print('AR session configuration failed: $e');
    }
  }

  // Place buddy in AR space
  Future<bool> placeBuddy({
    required OutfitModel outfit,
    vector.Vector3? position,
    vector.Vector3? scale,
  }) async {
    if (!_isARInitialized || _arObjectManager == null) return false;

    try {
      _isPlacingBuddy = true;

      // Remove existing buddy if placed
      if (_isBuddyPlaced && _buddyNode != null) {
        await removeBuddy();
      }

      // Create buddy node
      final buddyPosition = position ?? vector.Vector3(0, 0, -1);
      final buddyScale = scale ?? vector.Vector3.all(AppConfig.arScale);

      final newNode = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: outfit.modelUrl,
        scale: buddyScale,
        position: buddyPosition,
        rotation: vector.Vector4(0, 0, 0, 0),
      );

      // Add node to AR scene
      bool nodeAdded = await _arObjectManager!.addNode(newNode);
      
      if (nodeAdded) {
        _buddyNode = newNode;
        _currentOutfit = outfit.id;
        _isBuddyPlaced = true;
        _isPlacingBuddy = false;
        _buddyPlacedController.add(true);
        return true;
      } else {
        _isPlacingBuddy = false;
        return false;
      }
    } catch (e) {
      print('Error placing buddy: $e');
      _isPlacingBuddy = false;
      return false;
    }
  }

  // Remove buddy from AR scene
  Future<void> removeBuddy() async {
    if (!_isBuddyPlaced || _buddyNode == null || _arObjectManager == null) return;

    try {
      await _arObjectManager!.removeNode(_buddyNode!);
      _buddyNode = null;
      _currentOutfit = null;
      _currentAnimation = null;
      _isBuddyPlaced = false;
      _buddyPlacedController.add(false);
    } catch (e) {
      print('Error removing buddy: $e');
    }
  }

  // Change buddy outfit
  Future<bool> changeBuddyOutfit(OutfitModel newOutfit) async {
    if (!_isBuddyPlaced || _buddyNode == null) return false;

    try {
      // Store current position and scale
      final currentPosition = _buddyNode!.position;
      final currentScale = _buddyNode!.scale;
      final currentRotation = _buddyNode!.rotation;

      // Remove current buddy
      await removeBuddy();

      // Place new buddy with same transform
      await Future.delayed(const Duration(milliseconds: 100));
      
      return await placeBuddy(
        outfit: newOutfit,
        position: currentPosition,
        scale: currentScale,
      );
    } catch (e) {
      print('Error changing buddy outfit: $e');
      return false;
    }
  }

  // Play animation on buddy
  Future<void> playAnimation(String animationName) async {
    if (!_isBuddyPlaced || _buddyNode == null) return;

    try {
      // TODO: Implement animation playback
      // This would require integration with the 3D model's animation system
      _currentAnimation = animationName;
      _animationController.add(animationName);
      
      // Simulate animation duration
      Timer(const Duration(seconds: 3), () {
        _currentAnimation = 'idle';
        _animationController.add('idle');
      });
    } catch (e) {
      print('Error playing animation: $e');
    }
  }

  // Move buddy to new position
  Future<void> moveBuddy(vector.Vector3 newPosition) async {
    if (!_isBuddyPlaced || _buddyNode == null || _arObjectManager == null) return;

    try {
      _buddyNode!.position = newPosition;
      await _arObjectManager!.removeNode(_buddyNode!);
      await _arObjectManager!.addNode(_buddyNode!);
    } catch (e) {
      print('Error moving buddy: $e');
    }
  }

  // Scale buddy
  Future<void> scaleBuddy(double scaleFactor) async {
    if (!_isBuddyPlaced || _buddyNode == null || _arObjectManager == null) return;

    try {
      final newScale = vector.Vector3.all(scaleFactor);
      _buddyNode!.scale = newScale;
      await _arObjectManager!.removeNode(_buddyNode!);
      await _arObjectManager!.addNode(_buddyNode!);
    } catch (e) {
      print('Error scaling buddy: $e');
    }
  }

  // Rotate buddy
  Future<void> rotateBuddy(vector.Vector4 rotation) async {
    if (!_isBuddyPlaced || _buddyNode == null || _arObjectManager == null) return;

    try {
      _buddyNode!.rotation = rotation;
      await _arObjectManager!.removeNode(_buddyNode!);
      await _arObjectManager!.addNode(_buddyNode!);
    } catch (e) {
      print('Error rotating buddy: $e');
    }
  }

  // Handle tap on buddy
  Future<void> onBuddyTapped() async {
    if (!_isBuddyPlaced) return;

    try {
      // Play random interaction animation
      final interactionAnimations = ['wave', 'jump', 'spin', 'dance'];
      final randomIndex = DateTime.now().millisecondsSinceEpoch % interactionAnimations.length;
      await playAnimation(interactionAnimations[randomIndex]);
    } catch (e) {
      print('Error handling buddy tap: $e');
    }
  }

  // Get buddy position
  vector.Vector3? getBuddyPosition() {
    return _buddyNode?.position;
  }

  // Get buddy scale
  vector.Vector3? getBuddyScale() {
    return _buddyNode?.scale;
  }

  // Get buddy rotation
  vector.Vector4? getBuddyRotation() {
    return _buddyNode?.rotation;
  }

  // Check if point is on plane
  Future<bool> isPointOnPlane(vector.Vector2 screenPoint) async {
    if (_arSessionManager == null) return false;

    try {
      // Perform hit test
      final hitTestResults = await _arSessionManager!.onHitTestForPlane(screenPoint);
      return hitTestResults.isNotEmpty;
    } catch (e) {
      print('Error checking plane: $e');
      return false;
    }
  }

  // Get plane hit test results
  Future<List<ARHitTestResult>> getPlaneHitTest(vector.Vector2 screenPoint) async {
    if (_arSessionManager == null) return [];

    try {
      return await _arSessionManager!.onHitTestForPlane(screenPoint);
    } catch (e) {
      print('Error getting hit test results: $e');
      return [];
    }
  }

  // Place buddy at screen point
  Future<bool> placeBuddyAtScreenPoint({
    required vector.Vector2 screenPoint,
    required OutfitModel outfit,
  }) async {
    try {
      final hitTestResults = await getPlaneHitTest(screenPoint);
      
      if (hitTestResults.isNotEmpty) {
        final hit = hitTestResults.first;
        final position = vector.Vector3(
          hit.worldTransform[12],
          hit.worldTransform[13],
          hit.worldTransform[14],
        );
        
        return await placeBuddy(outfit: outfit, position: position);
      }
      
      return false;
    } catch (e) {
      print('Error placing buddy at screen point: $e');
      return false;
    }
  }

  // Take AR screenshot
  Future<Uint8List?> takeScreenshot() async {
    if (_arSessionManager == null) return null;

    try {
      return await _arSessionManager!.snapshot();
    } catch (e) {
      print('Error taking AR screenshot: $e');
      return null;
    }
  }

  // Start idle animations
  void startIdleAnimations() {
    if (!_isBuddyPlaced) return;

    Timer.periodic(Duration(seconds: AppConfig.idleAnimationInterval), (timer) {
      if (!_isBuddyPlaced) {
        timer.cancel();
        return;
      }

      if (_currentAnimation == 'idle' || _currentAnimation == null) {
        final idleAnimations = ['breathe', 'look_around', 'stretch', 'yawn'];
        final randomIndex = DateTime.now().millisecondsSinceEpoch % idleAnimations.length;
        playAnimation(idleAnimations[randomIndex]);
      }
    });
  }

  // Stop idle animations
  void stopIdleAnimations() {
    // Implementation would stop the periodic timer
  }

  // Apply mood-based lighting
  Future<void> applyMoodLighting(MoodModel mood) async {
    if (!_isBuddyPlaced) return;

    try {
      // TODO: Implement mood-based lighting effects
      // This would modify the AR scene lighting based on the mood
      print('Applying ${mood.name} mood lighting');
    } catch (e) {
      print('Error applying mood lighting: $e');
    }
  }

  // Create particle effects
  Future<void> createParticleEffect(String effectType) async {
    if (!_isBuddyPlaced || _buddyNode == null) return;

    try {
      // TODO: Implement particle effects around the buddy
      // This would create effects like sparkles, hearts, fire, etc.
      print('Creating $effectType particle effect');
    } catch (e) {
      print('Error creating particle effect: $e');
    }
  }

  // Pause AR session
  Future<void> pauseAR() async {
    try {
      await _arSessionManager?.onPause();
    } catch (e) {
      print('Error pausing AR: $e');
    }
  }

  // Resume AR session
  Future<void> resumeAR() async {
    try {
      await _arSessionManager?.onResume();
    } catch (e) {
      print('Error resuming AR: $e');
    }
  }

  // Dispose AR resources
  Future<void> dispose() async {
    try {
      if (_isBuddyPlaced) {
        await removeBuddy();
      }
      
      await _arSessionManager?.dispose();
      _arStatusController.close();
      _animationController.close();
      _buddyPlacedController.close();
      
      _isARInitialized = false;
    } catch (e) {
      print('Error disposing AR service: $e');
    }
  }
}