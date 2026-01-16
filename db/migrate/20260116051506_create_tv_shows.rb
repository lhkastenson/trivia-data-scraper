class CreateTvShows < ActiveRecord::Migration[8.1]
  def change
    create_table :tv_shows do |t|
      t.string :title
      t.integer :tmdb_id
      t.integer :year
      t.float :popularity
      t.integer :vote_count
      t.float :vote_average
      t.text :overview
      t.jsonb :genres
      t.string :poster_path

      t.timestamps
    end
    add_index :tv_shows, :tmdb_id, unique: true
    add_index :tv_shows, :vote_count
    add_index :tv_shows, :year  
  end
end
