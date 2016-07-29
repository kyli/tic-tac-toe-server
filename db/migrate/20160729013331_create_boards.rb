class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :channel
      t.string :player1
      t.string :player2
      t.string :state
      t.string :next

      t.timestamps null: false
    end
  end
end
