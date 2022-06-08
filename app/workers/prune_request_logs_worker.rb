class PruneRequestLogsWorker
  include Sidekiq::Worker
  include Sidekiq::Cronitor

  sidekiq_options queue: :cron, lock: :until_executed

  def perform
    accounts = Account.joins(:request_logs)
                      .where('request_logs.created_at < ?', 30.days.ago)
                      .group('accounts.id')
                      .having('count(request_logs.id) > 0')

    Keygen.logger.info "[workers.prune-request-logs] Starting: accounts=#{accounts.count}"

    accounts.find_each do |account|
      account_id = account.id
      batch = 0

      Keygen.logger.info "[workers.prune-request-logs] Pruning rows: account_id=#{account_id}"

      loop do
        logs = account.request_logs
                      .where('created_at < ?', 30.days.ago.beginning_of_day)
                      .limit(1_000)

        # Delete blobs
        account.request_log_blobs.where(request_log_id: logs.ids)
                                 .delete_all

        # Delete logs
        batch += 1
        count = logs.delete_all

        Keygen.logger.info "[workers.prune-request-logs] Pruned #{count} rows: account_id=#{account_id} batch=#{batch}"

        break if
          count == 0
      end
    end

    Keygen.logger.info "[workers.prune-request-logs] Done"
  end
end
