class CreateArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :spotify_id
      t.integer :popularity
      t.integer :followers
      t.jsonb :genres

      t.timestamps
    end
    add_index :artists, :spotify_id, unique: true
    add_index :artists, :popularity
  end
end
