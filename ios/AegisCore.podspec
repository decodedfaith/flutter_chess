Pod::Spec.new do |s|
  s.name             = 'AegisCore'
  s.version          = '0.0.1'
  s.summary          = 'Aegis C++ Engine'
  s.source_files     = '../../aegiscore/core/**/*.{hpp,cpp,h,c}'
  s.public_header_files = '../../aegiscore/core/sdk/AegisFlutterSDK.h'
  s.pod_target_xcconfig = { 
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/../../aegiscore/core"'
  }
end
