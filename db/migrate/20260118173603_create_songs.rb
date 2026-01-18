class CreateSongs < ActiveRecord::Migration[8.1]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :spotify_id
      t.bigint :artist_id
      t.integer :popularity
      t.date :release_date
      t.string :album_name

      t.timestamps
    end
    add_index :songs, :spotify_id, unique: true
    add_index :songs, :artist_id
    add_index :songs, :popularity

    add_foreign_key :songs, :artists
  end
end
