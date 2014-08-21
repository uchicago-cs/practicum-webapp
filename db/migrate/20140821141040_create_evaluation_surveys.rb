class CreateEvaluationSurveys < ActiveRecord::Migration
  def change
    create_table :evaluation_surveys do |t|

      t.timestamps
    end
  end
end
