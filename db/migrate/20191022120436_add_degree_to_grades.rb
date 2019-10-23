class AddDegreeToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :degree, :string ,default: "是"
  end
end
