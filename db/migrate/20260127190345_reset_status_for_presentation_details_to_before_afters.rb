class ResetStatusForPresentationDetailsToBeforeAfters < ActiveRecord::Migration[8.1]
  def up
    count = BeforeAfter.where(status: "approved")
      .where("presentation_data = '{}'::jsonb")
      .update_all(status: "generated")

    puts "Reset #{count} approved puzzles to generated (missing presentation data)"
  end

  def down
    puts "Cannot reverse this migration - data change only"
  end
end
