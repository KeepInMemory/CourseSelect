class AlterCreditsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :credits, :float
    end
  end
end
