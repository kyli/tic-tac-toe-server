class TicTacToeController < ApplicationController
  def get
    b = Board.new()
    b.player1 = 'kaiyi'
    b.player2 = 'testRobot'

    response = { :response_type => 'in_channel', :text => 'New game', :attachment => [ b ] }
    render json: response
  end
end
