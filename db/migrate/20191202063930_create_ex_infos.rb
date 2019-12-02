class CreateExInfos < ActiveRecord::Migration
  def change
    create_table :ex_infos do |t|
      t.string :name
      t.string :value

      t.timestamps null: false
    end
  end
end
