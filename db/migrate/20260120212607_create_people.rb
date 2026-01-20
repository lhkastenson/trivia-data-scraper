class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.string :name
      t.integer :birth_year
      t.integer :death_year
      t.text :bio_snippet
      t.string :nationality
      t.string :source_type
      t.string :source_id
      t.integer :popularity_score
      t.jsonb :metadata

      t.timestamps
    end

    add_index :people, [:source_type, :source_id], unique: true
    add_index :people, :name
    add_index :people, :popularity_score
  end
end
