---
# snapshots flink-manager.sh -P crons
cron::job::multiple:
  snapshots_fm:
    jobs:
      - {
          minute: '0-50/10',
          user: snapshots,
          command: 'flink-manager.sh -i 01 -P',
      }
