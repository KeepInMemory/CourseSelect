class AddHasGainCreditsToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :has_gain_credit, :boolean ,default: false
  end
end
