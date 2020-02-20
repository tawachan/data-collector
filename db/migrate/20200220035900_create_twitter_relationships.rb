class CreateTwitterRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :twitter_relationships do |t|

      t.timestamps
    end
  end
end
