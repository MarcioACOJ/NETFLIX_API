class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table(:movies) do |t|
      t.string(:title)
      t.string(:genre)
      t.string(:year)
      t.string(:country)
      t.string(:published_at)
      t.string(:description)

      t.timestamps
    end
  end
end
