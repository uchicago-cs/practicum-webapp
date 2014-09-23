class AddNewColsToEvalTemplates < ActiveRecord::Migration
  def change
    add_column :evaluation_templates, :name,       :string, default: ""
    add_column :evaluation_templates, :quarter_id, :integer
    add_column :evaluation_templates, :active,     :boolean, default: false
  end
end
