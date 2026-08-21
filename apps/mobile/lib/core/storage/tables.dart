abstract final class NexusTableNames {
  static const cachedMissions = 'cached_missions';
  static const missionEvents = 'mission_events';
  static const missionDrafts = 'mission_drafts';
}

abstract final class NexusSchema {
  static const statements = <String>[
    '''
      CREATE TABLE cached_missions (
        id TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        cached_at_ms INTEGER NOT NULL,
        remote_version INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE mission_events (
        mission_id TEXT NOT NULL,
        sequence INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        PRIMARY KEY (mission_id, sequence)
      )
    ''',
    '''
      CREATE TABLE mission_drafts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        execution_target_id TEXT NOT NULL,
        updated_at_ms INTEGER NOT NULL,
        base_remote_version INTEGER NOT NULL,
        local_payload_json TEXT NOT NULL,
        conflict_remote_payload_json TEXT,
        conflict_remote_version INTEGER
      )
    ''',
  ];
}
