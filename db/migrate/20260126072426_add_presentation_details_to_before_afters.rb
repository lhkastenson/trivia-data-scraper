class AddPresentationDetailsToBeforeAfters < ActiveRecord::Migration[8.1]
  def change
    add_column :before_afters, :presentation_data, :jsonb, default: {}
    add_index :before_afters, :presentation_data, using: :gin
  end
end
