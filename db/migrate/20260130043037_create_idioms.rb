class CreateIdioms < ActiveRecord::Migration[8.1]
  def change
    create_table :idioms do |t|
      t.string :phrase
      t.text :definition

      t.timestamps
    end

    add_index :idioms, :phrase, unique: true
  end
end
