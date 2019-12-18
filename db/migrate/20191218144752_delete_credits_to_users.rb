class DeleteCreditsToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :credits
  end
end
