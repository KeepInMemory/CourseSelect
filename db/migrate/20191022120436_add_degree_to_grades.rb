class AddDegreeToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :isDegree, :boolean ,default: false
  end
end
