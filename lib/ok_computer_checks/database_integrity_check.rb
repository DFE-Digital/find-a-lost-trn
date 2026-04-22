module OkComputerChecks
  class DatabaseIntegrityCheck < OkComputer::ActiveRecordCheck
    def check
      if tables_missing_for_models?
        mark_failure
        mark_message "Database tables missing for some models"
      else
        mark_message "Database tables correctly loaded"
      end
    end

    private

    def tables_missing_for_models?
      ActiveRecord::Base.descendants.map(&method(:table_present_for_model?)).include?(false)
    end

    def table_present_for_model?(model)
      ActiveRecord::Base.connection.data_source_exists? model.table_name
    end
  end
end
