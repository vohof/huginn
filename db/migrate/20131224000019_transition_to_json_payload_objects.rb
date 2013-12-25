class TransitionToJsonPayloadObjects < ActiveRecord::Migration
  FIELDS = {
    'agents' => 'memory',
    'events' => 'payload'
  }

  def up
    quoted_json_table_name = ActiveRecord::Base.connection.quote_table_name("json_payloads")
    quoted_json_column_names = %w[associate_id associate_type payload created_at updated_at].map { |f| ActiveRecord::Base.connection.quote_column_name(f) }

    FIELDS.each do |table, field|
      quoted_table_name = ActiveRecord::Base.connection.quote_table_name(table)
      quoted_field_name = ActiveRecord::Base.connection.quote_column_name(field)

      rows = ActiveRecord::Base.connection.select_rows("SELECT id, #{quoted_field_name} FROM #{quoted_table_name}")
      rows.each do |row|
        id, json = row

        insert_sql = "INSERT INTO #{quoted_json_table_name} (#{quoted_json_column_names.join(", ")}) VALUES (?, ?, ?, ?, ?)"

        sanitized_update_sql = ActiveRecord::Base.send :sanitize_sql_array, [insert_sql, id, table.classify, json, Time.now, Time.now]

        ActiveRecord::Base.connection.execute sanitized_update_sql
      end
    end

    remove_column :agents, :memory
    remove_column :events, :payload
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
