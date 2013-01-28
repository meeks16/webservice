class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :url
      t.date :publishdate
      t.string :thumbnailurl
      t.integer :view

      t.timestamps
    end
  end
end
