class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :tmdb_id
      t.integer :year
      t.float :popularity
      t.integer :vote_count
      t.bigint :revenue
      t.float :vote_average
      t.text :overview
      t.jsonb :genres
      t.string :poster_path

      t.timestamps
    end
    add_index :movies, :tmdb_id, unique: true
    add_index :movies, :vote_count
    add_index :movies, :year
  end
end
