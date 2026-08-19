import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_module_spec.freezed.dart';
part 'native_module_spec.g.dart';

@freezed
abstract class NativeModuleSpec with _$NativeModuleSpec {
  const factory NativeModuleSpec({
    required String moduleName,
    @Default('C++20') String language,
    @Default('com.example.nativemodule') String packageName,
    @Default(['arm64-v8a', 'armeabi-v7a', 'x86_64']) List<String> targetArch,
    @Default([]) List<String> jniMethods,
    @Default('') String cppSource,
    @Default('') String headerSource,
    @Default('') String cmakeListsContent,
    @Default('') String kotlinWrapperCode,
    @Default('') String headerContent,
    @Default('') String implementationContent,
    @Default('') String cmakeContent,
    @Default('') String jniKotlinWrapper,
    @Default(false) bool isCompiled,
  }) = _NativeModuleSpec;

  factory NativeModuleSpec.fromJson(Map<String, dynamic> json) => _$NativeModuleSpecFromJson(json);
}
