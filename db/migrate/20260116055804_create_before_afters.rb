class CreateBeforeAfters < ActiveRecord::Migration[8.1]
  def change
    create_table :before_afters do |t|
      # Polymorphic references for the two items
      t.references :item_one, polymorphic: true, null: false
      t.references :item_two, polymorphic: true, null: false

      t.string :connecting_word, null: false
      t.text :full_phrase, null: false

      t.string :format, null: false

      t.string :status, default: 'generated', null: false
      t.integer :quality_rating

      t.timestamps
    end
    add_index :before_afters, [ :item_one_type, :item_one_id ]
    add_index :before_afters, [ :item_two_type, :item_two_id ]
    add_index :before_afters, :status
    add_index :before_afters, :quality_rating
  end
end
