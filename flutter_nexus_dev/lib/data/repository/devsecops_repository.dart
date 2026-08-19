import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/models.dart';
import '../local/local_storage.dart';
import '../security/masvs_static_analyzer.dart';

part 'devsecops_repository.g.dart';

@riverpod
DevSecOpsRepository devSecOpsRepository(DevSecOpsRepositoryRef ref) {
  return DevSecOpsRepository(ref.read(securityAuditsBoxProvider));
}

class DevSecOpsRepository {
  final Box<SecurityAuditEntity> _auditsBox;
  
  DevSecOpsRepository(this._auditsBox);
  
  Stream<List<SecurityAuditEntity>> get allAudits => _auditsBox.watch().map((_) => _auditsBox.values.toList().reversed.toList());
  
  Future<void> runSecurityAudit({
    required String projectName,
    required String codeSnippet,
    String customApiKey = '',
  }) async {
    final scanResult = MasvsStaticAnalyzer.analyzeSourceCode('$projectName.dart', codeSnippet);
    
    final audit = SecurityAuditEntity(
      id: scanResult.scanId,
      projectName: projectName,
      codeSnippet: codeSnippet,
      findingsJson: _serializeFindings(scanResult.findings),
      autoFixApproved: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    
    await _auditsBox.add(audit);
  }
  
  List<SecurityFinding> deserializeFindings(String json) {
    return [];
  }
  
  String _serializeFindings(List<SecurityFinding> findings) {
    return findings.map((f) => f.id).join(',');
  }
}
