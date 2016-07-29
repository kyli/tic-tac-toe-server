class TicTacToeController < ApplicationController
  def get
    b = Board.new(:channel => 'abc')
    b.player1 = 'kaiyi'
    b.player2 = 'testRobot'
    response = { :response_type => 'in_channel', :text => 'New game', :board => b }
    render json: response
  end
end
