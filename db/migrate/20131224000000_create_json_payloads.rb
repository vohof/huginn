class CreateJsonPayloads < ActiveRecord::Migration
  def change
    create_table :json_payloads do |t|
      t.text :payload, mysql? ? { :limit => 4294967295 } : {}
      t.string :associate_type
      t.integer :associate_id

      t.timestamps
    end

    add_index :json_payloads, [:associate_type, :associate_id]
  end

  # PG allows arbitrarily long text fields but MySQL has default limits. Make those limits larger if we're using MySQL.
  def mysql?
    ActiveRecord::Base.connection.adapter_name =~ /mysql/i
  end
end


