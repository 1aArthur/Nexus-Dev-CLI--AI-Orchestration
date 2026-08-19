import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';

class MasvsStaticAnalyzer {
  static MasvsScanResult analyzeSourceCode(String filePath, String codeSnippet) {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final findings = <SecurityFinding>[];
    final lines = codeSnippet.split('\n');
    
    _checkHardcodedSecrets(lines, findings, filePath);
    _checkSqlInjection(lines, findings, filePath);
    _checkInsecureFileModes(lines, findings, filePath);
    _checkCleartextHttp(lines, findings, filePath);
    _checkWeakCrypto(lines, findings, filePath);
    _checkInsecureRandom(lines, findings, filePath);
    _checkPathTraversal(lines, findings, filePath);
    _checkCommandInjection(lines, findings, filePath);
    _checkXss(lines, findings, filePath);
    _checkInsecurePermissions(lines, findings, filePath);
    
    final categories = _calculateCategories(findings);
    final complianceScore = _calculateComplianceScore(findings, lines.length);
    final complianceGrade = _getComplianceGrade(complianceScore);
    
    final criticalCount = findings.where((f) => f.severity == VulnerabilitySeverity.critical()).length;
    final highCount = findings.where((f) => f.severity == VulnerabilitySeverity.high()).length;
    final mediumCount = findings.where((f) => f.severity == VulnerabilitySeverity.medium()).length;
    final lowCount = findings.where((f) => f.severity == VulnerabilitySeverity.low()).length;
    
    final scanDuration = DateTime.now().millisecondsSinceEpoch - startTime;
    final scanId = 'MASVS-${DateTime.now().millisecondsSinceEpoch}';
    
    return MasvsScanResult(
      scanId: scanId,
      targetName: filePath,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      linesScanned: lines.length,
      complianceScore: complianceScore,
      complianceGrade: complianceGrade,
      totalVulnerabilities: findings.length,
      criticalCount: criticalCount,
      highCount: highCount,
      mediumCount: mediumCount,
      lowCount: lowCount,
      findings: findings,
      categories: categories,
      scanDurationMs: scanDuration,
      autoFixPatchesCount: findings.where((f) => f.autoFixAvailable).length,
    );
  }
  
  static void _checkHardcodedSecrets(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final secretPatterns = [
      RegExp(r'(api[_-]?key|secret|password|token|private[_-]?key)\s*[:=]\s*["\'][^"\']{8,}["\']', caseSensitive: false),
      RegExp(r'(sk|pk)_(live|test)_[a-zA-Z0-9]{20,}'),
      RegExp(r'["\'][A-Za-z0-9+/]{40,}={0,2}["\']'),
      RegExp(r'AIza[0-9A-Za-z\-_]{35}'),
      RegExp(r'ya29\.[0-9A-Za-z\-_]+'),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in secretPatterns) {
        final match = pattern.firstMatch(lines[i]);
        if (match != null) {
          findings.add(SecurityFinding(
            id: 'MASVS-STORAGE-${findings.length + 1}',
            title: 'Hardcoded Secret Detected',
            severity: VulnerabilitySeverity.critical(),
            cwe: 'CWE-798',
            masvsRef: 'MASVS-STORAGE-1',
            masvsCategory: 'Storage',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'Sensitive credentials hardcoded in source code',
            recommendation: 'Move secrets to secure storage (Keystore/Keychain) or environment variables',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: _generateSecretPatch(lines[i]),
            remediationPatch: _generateSecretPatch(lines[i]),
            confidence: 0.95,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkSqlInjection(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final sqlPatterns = [
      RegExp(r'["\']SELECT\s+.*\s+WHERE\s+.*\s*\+\s*', caseSensitive: false),
      RegExp(r'["\']INSERT\s+INTO\s+.*\s+VALUES\s*\(.*\s*\+\s*', caseSensitive: false),
      RegExp(r'["\']UPDATE\s+.*\s+SET\s+.*\s*\+\s*', caseSensitive: false),
      RegExp(r'["\']DELETE\s+FROM\s+.*\s+WHERE\s+.*\s*\+\s*', caseSensitive: false),
      RegExp(r'rawQuery\s*\(.*\+', caseSensitive: false),
      RegExp(r'execSQL\s*\(.*\+', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in sqlPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-CODE-${findings.length + 1}',
            title: 'Potential SQL Injection',
            severity: VulnerabilitySeverity.high(),
            cwe: 'CWE-89',
            masvsRef: 'MASVS-CODE-1',
            masvsCategory: 'Code Quality',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'String concatenation used in SQL query - vulnerable to injection',
            recommendation: 'Use parameterized queries or prepared statements',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: _generateSqlInjectionPatch(lines[i]),
            remediationPatch: _generateSqlInjectionPatch(lines[i]),
            confidence: 0.90,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkInsecureFileModes(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final fileModePatterns = [
      RegExp(r'MODE_WORLD_READABLE', caseSensitive: false),
      RegExp(r'MODE_WORLD_WRITEABLE', caseSensitive: false),
      RegExp(r'openFileOutput\s*\([^)]*,\s*\d+\)'),
      RegExp(r'getSharedPreferences\s*\([^)]*,\s*\d+\)'),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in fileModePatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-STORAGE-${findings.length + 1}',
            title: 'Insecure File Storage Mode',
            severity: VulnerabilitySeverity.high(),
            cwe: 'CWE-276',
            masvsRef: 'MASVS-STORAGE-2',
            masvsCategory: 'Storage',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'File created with world-readable/writable permissions',
            recommendation: 'Use MODE_PRIVATE (default) for app-private files',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: lines[i].replaceAll(RegExp(r'MODE_WORLD_(READABLE|WRITEABLE)'), 'MODE_PRIVATE'),
            remediationPatch: lines[i].replaceAll(RegExp(r'MODE_WORLD_(READABLE|WRITEABLE)'), 'MODE_PRIVATE'),
            confidence: 0.85,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkCleartextHttp(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final httpPatterns = [
      RegExp(r'["\']http://[^"\']+["\']'),
      RegExp(r'HttpURLConnection'),
      RegExp(r'HttpClient'),
      RegExp(r'OkHttpClient.*http://', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in httpPatterns) {
        if (pattern.hasMatch(lines[i]) && !lines[i].contains('https://')) {
          findings.add(SecurityFinding(
            id: 'MASVS-NETWORK-${findings.length + 1}',
            title: 'Cleartext HTTP Communication',
            severity: VulnerabilitySeverity.high(),
            cwe: 'CWE-319',
            masvsRef: 'MASVS-NETWORK-1',
            masvsCategory: 'Network',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'Network communication over unencrypted HTTP',
            recommendation: 'Use HTTPS with certificate pinning',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: lines[i].replaceAll('http://', 'https://'),
            remediationPatch: lines[i].replaceAll('http://', 'https://'),
            confidence: 0.88,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkWeakCrypto(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final weakCryptoPatterns = [
      RegExp(r'Cipher\.getInstance\s*\(\s*["\']DES["\']', caseSensitive: false),
      RegExp(r'Cipher\.getInstance\s*\(\s*["\']RC4["\']', caseSensitive: false),
      RegExp(r'Cipher\.getInstance\s*\(\s*["\']AES/ECB["\']', caseSensitive: false),
      RegExp(r'MessageDigest\.getInstance\s*\(\s*["\']MD5["\']', caseSensitive: false),
      RegExp(r'MessageDigest\.getInstance\s*\(\s*["\']SHA1["\']', caseSensitive: false),
      RegExp(r'SecureRandom.*SHA1PRNG', caseSensitive: false),
      RegExp(r'KeyGenerator.*DES', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in weakCryptoPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-CRYPTO-${findings.length + 1}',
            title: 'Weak Cryptographic Algorithm',
            severity: VulnerabilitySeverity.high(),
            cwe: 'CWE-327',
            masvsRef: 'MASVS-CRYPTO-1',
            masvsCategory: 'Cryptography',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'Use of deprecated or weak cryptographic algorithms',
            recommendation: 'Use AES-256-GCM, ChaCha20-Poly1305, or SHA-256/384/512',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: _generateCryptoPatch(lines[i]),
            remediationPatch: _generateCryptoPatch(lines[i]),
            confidence: 0.92,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkInsecureRandom(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final randomPatterns = [
      RegExp(r'new\s+Random\s*\(', caseSensitive: false),
      RegExp(r'Math\.random\s*\(', caseSensitive: false),
      RegExp(r'ThreadLocalRandom\.current\(\)', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in randomPatterns) {
        if (pattern.hasMatch(lines[i]) && !lines[i].contains('SecureRandom')) {
          findings.add(SecurityFinding(
            id: 'MASVS-CRYPTO-${findings.length + 1}',
            title: 'Insecure Random Number Generation',
            severity: VulnerabilitySeverity.medium(),
            cwe: 'CWE-338',
            masvsRef: 'MASVS-CRYPTO-2',
            masvsCategory: 'Cryptography',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'Use of predictable random number generator for security-sensitive operations',
            recommendation: 'Use SecureRandom for cryptographic operations',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: lines[i].replaceAll('Random', 'SecureRandom').replaceAll('Math.random', 'SecureRandom'),
            remediationPatch: lines[i].replaceAll('Random', 'SecureRandom').replaceAll('Math.random', 'SecureRandom'),
            confidence: 0.75,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkPathTraversal(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final pathPatterns = [
      RegExp(r'new\s+File\s*\([^)]*\.\.[\\/]', caseSensitive: false),
      RegExp(r'File\s*\([^)]*user\.input', caseSensitive: false),
      RegExp(r'getAbsolutePath\s*\(\s*\)', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in pathPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-STORAGE-${findings.length + 1}',
            title: 'Path Traversal Vulnerability',
            severity: VulnerabilitySeverity.high(),
            cwe: 'CWE-22',
            masvsRef: 'MASVS-STORAGE-3',
            masvsCategory: 'Storage',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'User input used in file path without validation',
            recommendation: 'Validate and sanitize file paths, use canonical paths',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: _generatePathTraversalPatch(lines[i]),
            remediationPatch: _generatePathTraversalPatch(lines[i]),
            confidence: 0.80,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkCommandInjection(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final cmdPatterns = [
      RegExp(r'Runtime\.getRuntime\(\)\.exec\s*\(', caseSensitive: false),
      RegExp(r'ProcessBuilder\s*\(', caseSensitive: false),
      RegExp(r'sh\s+-c\s*.*\+', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in cmdPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-CODE-${findings.length + 1}',
            title: 'Command Injection Risk',
            severity: VulnerabilitySeverity.critical(),
            cwe: 'CWE-78',
            masvsRef: 'MASVS-CODE-2',
            masvsCategory: 'Code Quality',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'User input passed to system command execution',
            recommendation: 'Avoid dynamic command execution; use safe APIs',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: '// REMOVED: Dynamic command execution\n// Use safe platform APIs instead',
            remediationPatch: '// REMOVED: Dynamic command execution\n// Use safe platform APIs instead',
            confidence: 0.85,
            autoFixAvailable: false,
          ));
        }
      }
    }
  }
  
  static void _checkXss(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final xssPatterns = [
      RegExp(r'loadData\s*\([^)]*text/html', caseSensitive: false),
      RegExp(r'loadDataWithBaseURL\s*\([^)]*text/html', caseSensitive: false),
      RegExp(r'WebView.*setJavaScriptEnabled\s*\(\s*true\s*\)', caseSensitive: false),
      RegExp(r'evaluateJavascript\s*\(', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in xssPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-PLATFORM-${findings.length + 1}',
            title: 'Potential XSS in WebView',
            severity: VulnerabilitySeverity.medium(),
            cwe: 'CWE-79',
            masvsRef: 'MASVS-PLATFORM-1',
            masvsCategory: 'Platform',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'WebView configured to execute JavaScript or load HTML with user data',
            recommendation: 'Disable JavaScript if not needed; sanitize HTML content; use Content Security Policy',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: _generateXssPatch(lines[i]),
            remediationPatch: _generateXssPatch(lines[i]),
            confidence: 0.70,
            autoFixAvailable: true,
          ));
        }
      }
    }
  }
  
  static void _checkInsecurePermissions(List<String> lines, List<SecurityFinding> findings, String filePath) {
    final permPatterns = [
      RegExp(r'android:permission\s*=\s*["\'][^"\']*["\']', caseSensitive: false),
      RegExp(r'<uses-permission\s+android:name\s*=\s*["\']android\.permission\.(WRITE_EXTERNAL_STORAGE|READ_SMS|READ_CONTACTS|CAMERA|RECORD_AUDIO|ACCESS_FINE_LOCATION)["\']', caseSensitive: false),
    ];
    
    for (int i = 0; i < lines.length; i++) {
      for (final pattern in permPatterns) {
        if (pattern.hasMatch(lines[i])) {
          findings.add(SecurityFinding(
            id: 'MASVS-PLATFORM-${findings.length + 1}',
            title: 'Excessive Permission Request',
            severity: VulnerabilitySeverity.medium(),
            cwe: 'CWE-250',
            masvsRef: 'MASVS-PLATFORM-2',
            masvsCategory: 'Platform',
            component: filePath,
            line: i + 1,
            lineNumber: i + 1,
            filePath: filePath,
            description: 'App requests sensitive permissions that may not be needed',
            recommendation: 'Follow principle of least privilege; remove unused permissions',
            originalSnippet: lines[i].trim(),
            vulnerableCodeSnippet: lines[i].trim(),
            patchSnippet: '// REVIEW: Remove if not strictly required',
            remediationPatch: '// REVIEW: Remove if not strictly required',
            confidence: 0.65,
            autoFixAvailable: false,
          ));
        }
      }
    }
  }
  
  static String _generateSecretPatch(String line) {
    return line.replaceAllMapped(
      RegExp(r'(api[_-]?key|secret|password|token|private[_-]?key)\s*[:=]\s*["\'][^"\']+["\']', caseSensitive: false),
      (match) => '${match.group(1)} = getSecureStorage().get("${match.group(1)}")',
    );
  }
  
  static String _generateSqlInjectionPatch(String line) {
    return line.replaceAllMapped(
      RegExp(r'["\']([^"\']*)\s*\+\s*([^"\']*)["\']'),
      (match) => '"${match.group(1)} ? ${match.group(2)}" // Use parameterized query',
    );
  }
  
  static String _generateCryptoPatch(String line) {
    return line
      .replaceAll('DES', 'AES/GCM/NoPadding')
      .replaceAll('RC4', 'ChaCha20-Poly1305')
      .replaceAll('AES/ECB', 'AES/GCM/NoPadding')
      .replaceAll('MD5', 'SHA-256')
      .replaceAll('SHA1', 'SHA-256');
  }
  
  static String _generatePathTraversalPatch(String line) {
    return line.replaceAllMapped(
      RegExp(r'new\s+File\s*\(([^)]+)\)'),
      (match) => 'File(${match.group(1)}).canonicalFile // Validated path',
    );
  }
  
  static String _generateXssPatch(String line) {
    return line
      .replaceAll('setJavaScriptEnabled(true)', 'setJavaScriptEnabled(false) // Disabled for security')
      .replaceAll('loadData(', 'loadDataWithBaseURL(null, sanitizeHtml(');
  }
  
  static List<MasvsCategoryMetric> _calculateCategories(List<SecurityFinding> findings) {
    final categoryMap = <String, MasvsCategoryMetric>{};
    
    for (final finding in findings) {
      final key = finding.masvsCategory.isEmpty ? 'General' : finding.masvsCategory;
      final existing = categoryMap[key];
      
      final maxSeverity = existing == null 
        ? finding.severity 
        : (finding.severity.priority > existing.maxSeverity.priority ? finding.severity : existing.maxSeverity);
      
      categoryMap[key] = MasvsCategoryMetric(
        categoryCode: finding.masvsRef.isEmpty ? 'GENERAL' : finding.masvsRef.split('-')[0],
        categoryName: key,
        findingsCount: (existing?.findingsCount ?? 0) + 1,
        maxSeverity: maxSeverity,
        isCompliant: maxSeverity == VulnerabilitySeverity.clean() || maxSeverity == VulnerabilitySeverity.low(),
      );
    }
    
    return categoryMap.values.toList();
  }
  
  static int _calculateComplianceScore(List<SecurityFinding> findings, int totalLines) {
    if (totalLines == 0) return 100;
    
    double penalty = 0;
    for (final finding in findings) {
      switch (finding.severity) {
        case VulnerabilitySeverity.critical(): penalty += 25; break;
        case VulnerabilitySeverity.high(): penalty += 15; break;
        case VulnerabilitySeverity.medium(): penalty += 8; break;
        case VulnerabilitySeverity.low(): penalty += 3; break;
        case VulnerabilitySeverity.clean(): break;
      }
    }
    
    final score = (100 - penalty).clamp(0, 100).toInt();
    return score;
  }
  
  static String _getComplianceGrade(int score) {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
  
  static String applyVerifiedPatches(String code, List<SecurityFinding> findings) {
    var patchedCode = code;
    for (final finding in findings) {
      if (finding.autoFixAvailable && finding.patchSnippet.isNotEmpty) {
        patchedCode = patchedCode.replaceAll(finding.originalSnippet, finding.patchSnippet);
      }
    }
    return patchedCode;
  }
}
