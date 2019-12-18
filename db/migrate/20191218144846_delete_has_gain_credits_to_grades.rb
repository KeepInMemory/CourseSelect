class DeleteHasGainCreditsToGrades < ActiveRecord::Migration
  def change
    remove_column :grades, :has_gain_credit
  end
end
