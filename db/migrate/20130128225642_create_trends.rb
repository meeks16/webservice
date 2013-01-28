class CreateTrends < ActiveRecord::Migration
  def change
    create_table :trends do |t|
      t.string :term
      t.string :socialnetwork
      t.string :url

      t.timestamps
    end
  end
end
