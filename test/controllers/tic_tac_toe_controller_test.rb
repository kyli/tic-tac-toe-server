require 'test_helper'

class TicTacToeControllerTest < ActionController::TestCase

  test "test check winner row" do
    winner = @controller.checkWinner('111000000', 'player1', 'player2')
    assert winner == 'player1'
  end

  test "test check winner column" do
    winner = @controller.checkWinner('122100102', 'player1', 'player2')
    assert winner == 'player1'
  end

  test "test check winner player2" do
    winner = @controller.checkWinner('222110100', 'player1', 'player2')
    assert winner == 'player2'
  end

  test "test check draw" do
    winner = @controller.checkWinner('212112121', 'player1', 'player2')
    assert !winner
  end
end
